-- DESCRIPCION: Modulo del controlador del esclavo spi
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control_slave is

port(clk: 		 in std_logic;
	   nRst: 		 in std_logic;
	   nCS:			 in std_logic;				-- Chip select a nivel bajo
	   SPC:      in std_logic;				-- sclk	 	

--conexion con reg_in
 
		 MSB_LSB: buffer     std_logic;     -- 0 -> modo MSB First, 1 -> modo LSB First
	 	 leer_dir:		buffer std_logic;			-- Habilita la captura de la direccion
	 	 leer_dato_reg:		buffer std_logic; 			-- Habilita la captura del dato
	 	 escribir_dato_reg:	buffer std_logic;			-- Habilita la escritura del dato 
	 	 reset_regs_SDIO:	buffer std_logic;			-- Habilita el reset de los registros que guardar el muestreo de los datos leidos
		 
		 instruccion: in  std_logic_vector(15 downto 0);       --direccion del registro
--conexion con reg_out

	 	 ctrl:		buffer std_logic;			-- Controla la lectura y escritura en la linea MOSI
		
		 dato_out: 	buffer std_logic_vector(7 downto 0);
		 dato_reg:	in std_logic_vector(7 downto 0);
		 load: buffer std_logic;

--conexion con ambas

		SPC_posedge: buffer std_logic;
  	SPC_negedge: buffer std_logic;
	  registros_s: buffer std_logic_vector(3 downto 0);
		desplaza_bit: buffer std_logic	;
	  mode_3_4_h: buffer std_logic		 -- 0 -> modo 3 hilos, 1 -> modo 4 hilos

);
end entity;

architecture rtl of control_slave is
  -- Estados
  type t_estado is (reposo,leer_instruccion, leer_dato, escrbir_registro, enviar_registro,change_dir, cargar_registro);
  signal estado: t_estado;
	
  -- Contador del numero de pulsos y bit de una transferencia
  signal cnt_pulsos: 				std_logic_vector(5 downto 0);
  signal cnt_neg: 				std_logic_vector(3 downto 0);
	
--Conformador de pulsos
	signal SPC_t1: 				std_logic;

--senales de control
	
	signal add_up:      			std_logic;	   -- 0 -> modo descenso de dir, 1 -> modo ascenso de dir 
	signal str_sgl_ins:  			std_logic;	  -- 0 -> modo streaming, 1 -> modo single instruction	
	signal fin_rd:		  		std_logic;
	signal op_nWR:		  		std_logic;				-- Indica la operacion (lectura o escritura)	

	
--constantes
	constant add_size: 			natural := 16;	
	constant data_size: 			natural := 8;	
			
--senales para banco de registros
	signal WE: 				std_logic;
	signal dato_wr: 			std_logic_vector(7 downto 0);	 -- Es el dato_reg de reg in
	signal dir_reg: 			std_logic_vector(15 downto 0);
	signal reg0:  				std_logic_vector(7 downto 0);
	signal reg1:  				std_logic_vector(7 downto 0);
	signal reg16:  				std_logic_vector(7 downto 0);
	signal reg17:  				std_logic_vector(7 downto 0);


begin

--Asignacion de modos

	MSB_LSB <= reg0(1);    
	add_up  <= reg0(2);     
	mode_3_4_h  <= reg0(3);
	str_sgl_ins  <= reg1(7);
			
  registros_s <= str_sgl_ins & add_up & MSB_LSB & mode_3_4_h;
--Conformador de pulsos (generacion de posedge negedge)
--Diferencia los flancos de subida (posedge) y de bajada del reloj (negedge) SCLK

  process(nRst, clk)
	begin
    if nRst = '0' then
      SPC_t1 <= '0';
    elsif clk'event and clk='1' then
      SPC_t1 <= SPC;
    end if;
  end process;

  SPC_posedge<= '1' when SPC_t1 = '0' and SPC = '1' else
                '0';
  SPC_negedge<= '1' when SPC_t1 = '1' and SPC = '0' else
                '0';

 op_nWR <= instruccion(15);

--AUTOMATA
	process(nRst, clk)
	begin
		if nRst = '0' then

		 estado <= reposo;
	   cnt_pulsos <= (others => '0');
		 cnt_neg <= (others => '0');

		elsif clk'event and clk = '1' then
		  if nCS = '1' then
		    estado <= reposo;
		  else
	  	case estado is
			-- ESTADO TRAS RESET O FIN TRANSFERENCIA

			when reposo =>
			   cnt_pulsos <= (others => '0');
		 	   cnt_neg <= (others => '0');
			   estado <= leer_instruccion;

			when leer_instruccion =>
			    if  cnt_pulsos = add_size then
				cnt_pulsos <= (others => '0');
				dir_reg <= '0' & instruccion(14 downto 0);
				if op_nWR='0'then
				  estado <= leer_dato;
				else
				  estado <= cargar_registro;
			        end if;
			    elsif SPC_posedge= '1' then
			      cnt_pulsos <= cnt_pulsos + 1;
		            end if;

	  --ESTADO DE LECTURA DEL DATO
			when leer_dato =>
			  if cnt_pulsos = data_size then
			    cnt_pulsos <= (others => '0');
			    estado<=escrbir_registro;
			  elsif SPC_posedge = '1' then
			    cnt_pulsos <= cnt_pulsos + 1;
			  end if;	

		--ESTADO DE ESCRITURA DEL DATO
			when escrbir_registro=>
			  if str_sgl_ins = '0' then
				if add_up='0' then -- default case descending
				  dir_reg <= dir_reg - 1;
				  estado <= leer_dato;
				else 
				  dir_reg <= dir_reg + 1;
				  estado <= leer_dato;
				end if;
			  else
			    estado <=leer_instruccion;
			  end if;

			when cargar_registro=>
			  estado <= enviar_registro;

			when enviar_registro =>
			  if str_sgl_ins = '0' then
			    if cnt_neg = data_size then
			      cnt_neg <= (others => '0');
			      estado <= change_dir;
			    elsif SPC_negedge = '1' then
			      cnt_neg <= cnt_neg + 1;
			    end if;	
		   	  else--ELSE DEL SINGLE INSTRUCTION
			    if cnt_neg = data_size and SPC_posedge = '1' then --se mira SPC_negedge para anadir retardo y respetar el tiempo de hold
			      cnt_neg <= (others => '0');
			      estado <= leer_instruccion;
			    elsif SPC_negedge = '1' then
			      cnt_neg <= cnt_neg + 1;
			    end if;	
			end if;

			when change_dir =>
			    if add_up='0' then -- default case descending
			      dir_reg <= dir_reg - 1;
			      estado <= cargar_registro;
			    else 
			      dir_reg <= dir_reg + 1;
			      estado <= cargar_registro;
			    end if;
		end case;
	    end if;
	  end if;
	end process;
				-- Ordena la captura de la direccion y el tipo de operacion 
	
  -- Ordena la captura de la direccion del banco de registros
  leer_dir <= '1' when estado = leer_instruccion and cnt_pulsos<add_size else
			  '0';
					  
  -- Ordena la captura del dato 
  leer_dato_reg <= '1' when estado = leer_dato else
				   '0';
					   
  -- Ordena la captura del dato 
  escribir_dato_reg <= '1' when estado = enviar_registro or (estado = leer_instruccion and op_nWR='1')	 else
				   '0';

  reset_regs_SDIO <= '1' when nCS = '0' and estado = reposo else
					 '0';

  WE <= '1' when estado = escrbir_registro else
        '0';	

  fin_rd <= '1' when cnt_neg=8 and SPC_negedge='1' else --dependia de fin_tx
  	    '0';

  load <= '1' when estado = cargar_registro else
          '0';

  desplaza_bit <= '1' when estado = enviar_registro and SPC_negedge = '1'  and cnt_neg > 0 else
	  '0';

  ctrl <= '0' when estado = enviar_registro or estado = change_dir else
	  '1';

--Banco de registros
  process(nRst,clk)
  begin
    if nRst = '0' then
	  reg0 <= "00011000"; --Por defecto 18 desc,str,4h,msb
	  reg1 <= "00000000";
  	  reg16 <= (others => '0');
  	  reg17 <= (others => '0');
	elsif clk'event and clk = '1' then
		if WE = '1' then		  			
			case dir_reg is
	      when x"0000" =>
		    	reg0 <= dato_reg(7 downto 0);
		  	when x"0001" =>
		    	reg1 <= dato_reg(7 downto 0);
		  	when x"0010" =>
		    	reg16 <= dato_reg(7 downto 0);
		  	when x"0011" =>
		    	reg17 <= dato_reg(7 downto 0);
		  	when others =>
		    	null;
        end case;
      end if;
	end if;
  end process;
  

  dato_out <= 	reg0  when dir_reg = x"0000" and estado = cargar_registro else
		reg1  when dir_reg = x"0001" and estado = cargar_registro else
		reg16 when dir_reg = x"0010" and estado = cargar_registro else
		reg17 when dir_reg = x"0011" and estado = cargar_registro else
		(others=>'0');



end rtl;