--    Fecha: 15-03-2023 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ctrl_tec is
generic(
    TICS_2s : natural := 400
   );
port(clk:           in std_logic;
     nRst:          in std_logic;
     columna:       in std_logic_vector(3 downto 0);                    
     tic:           in std_logic;                                        
     fila:          buffer std_logic_vector(3 downto 0);                  
     tecla:         buffer std_logic_vector(3 downto 0);               
     tecla_pulsada: buffer std_logic;                           
     pulso_largo:   buffer std_logic);                            
end entity;

architecture rtl of ctrl_tec is
 
  signal cnt_2s:   std_logic_vector(8 downto 0);
  signal fdc_2s: std_logic;
  --constant TIEMPO_2s: natural := 400;
 
  signal col_reg:   std_logic_vector(11 downto 0);
  signal col_sinrebotes:   std_logic_vector(3 downto 0);

  signal cont_filas:   std_logic_vector(1 downto 0);
  signal muestreo_fila : std_logic;

  signal pulsacion  : std_logic;
  signal pulsacion_nueva : std_logic;
  signal pulso_corto : std_logic;
  signal pulsacion_aux : std_logic;
  signal tecla_pulsada_aux : std_logic;
  signal tecla_aux:   std_logic_vector(3 downto 0);

begin
-- Registro metaestabilidad (equivale a 3 flip-flops)
process(clk,nRst)
  begin     
    if nRst = '0' then
      col_reg <=( others => '1');
			
    elsif clk'event and clk = '1' then
      col_reg(11 downto 0) <= col_reg(7 downto 0) & columna;
			
    end if;
end process;

-- Eliminación de rebotes
process(clk,nRst)
  begin
           
    if nRst = '0' then
      col_sinrebotes <= (others => '1');
			
    elsif clk'event and clk = '1' then
      if tic = '1' then
        col_sinrebotes <= col_reg(11 downto 8);
			
      end if;	
    end if;
end process;

-- contador de 2 bits para el desplazamiento cíclico de las filas
process(clk,nRst)
  begin
    if nRst = '0' then
      cont_filas <= (others => '0');
			
    elsif clk'event and clk = '1' then
      if tic = '1' and  muestreo_fila = '1' then
        cont_filas <= cont_filas +1;
			
				
      end if;
    end if;
end process;
	 
muestreo_fila <= '1' when col_reg(11 downto 8) = "1111" else -- meter columna con rebotes para evitar el desfase de los 20ns
                 '0';
pulsacion <= '0' when col_sinrebotes = "1111" else 
             '1';

--decoficador  del desplazamiento de las filas
	fila <= "1110" when cont_filas = "00" else 
	        "1101" when cont_filas = "01" else
                "1011" when cont_filas = "10" else
                "0111";

--conformador pulsos                 
process(nRst,clk)
  begin
    if nRst = '0' then
      pulsacion_aux <= '0';
      tecla_pulsada_aux <= '0';
		    
    elsif clk'event and clk = '1' then
      pulsacion_aux <= pulsacion;
      tecla_pulsada_aux <= pulso_corto;
 		
    end if;
end process; 
	
pulsacion_nueva <= '1' when pulsacion = '1' and pulsacion_aux = '0' else
	           '0'; 

--contador para determinar si es una pulsacion larga o corta
process(nRst,clk)
  begin
    if nRst = '0' then
    cnt_2s <= (others => '0');
		
    elsif clk'event and clk = '1' then
      if pulsacion = '1' and pulsacion_nueva = '1' then
        cnt_2s <= (0 => '1', others => '0');

      elsif pulsacion = '0' then
        cnt_2s <= (others => '0');

      elsif fdc_2s = '0' then
        if tic = '1'  then  --se quita para la simulacion, para comprobar que llega a 2s            
          if cnt_2s /= TICS_2s then 
            cnt_2s <= cnt_2s +1;
              
          else
            cnt_2s <= (others => '0');

          end if;
       end if;
      end if;
    end if;
end process;

-- Fin de cuenta de 2s
fdc_2s <= '1' when cnt_2s = TICS_2s  else 
		      '0';

-- Generacion de pulso corto	   
pulso_corto <= '1' when pulsacion = '0' and cnt_2s > 0 and cnt_2s < TICS_2s else
	       '0'; 


-- Generacion de pulso largo			  
pulso_largo <= '1' when pulsacion = '1' and cnt_2s = TICS_2s  else 
               '0';

-- Generacion de pulso corto de 1 CLK
tecla_pulsada <= '1' when pulso_corto = '1' and tecla_pulsada_aux = '0' else
	         '0';

-- Decodificador de la tecla pulsada
tecla_aux <=  "0000" when fila = "0111" and col_sinrebotes = "1101" else --0
              "0001" when fila = "1110" and col_sinrebotes = "1110" else --1
              "0010" when fila = "1110" and col_sinrebotes = "1101" else --2
              "0011" when fila = "1110" and col_sinrebotes = "1011" else --3
              "0100" when fila = "1101" and col_sinrebotes = "1110" else --4
              "0101" when fila = "1101" and col_sinrebotes = "1101" else --5
              "0110" when fila = "1101" and col_sinrebotes = "1011" else --6
              "0111" when fila = "1011" and col_sinrebotes = "1110" else --7
              "1000" when fila = "1011" and col_sinrebotes = "1101" else --8
              "1001" when fila = "1011" and col_sinrebotes = "1011" else --9
              "1010" when fila = "0111" and col_sinrebotes = "1110" else --A
              "1011" when fila = "0111" and col_sinrebotes = "1011" else --B
              "1100" when fila = "0111" and col_sinrebotes = "0111" else --C
              "1110" when fila = "1101" and col_sinrebotes = "0111" else --E
              "1101" when fila = "1011" and col_sinrebotes = "0111" else --D
              "1111" when fila = "1110" and col_sinrebotes = "0111" else --F
              "XXXX";   

-- Registro de tecla
process(nRst,clk)
  begin
    if nRst = '0' then
      tecla<="XXXX";
		  
    elsif clk'event and clk = '1' then
      if pulsacion = '1' then
        tecla<=tecla_aux;
      end if;
    end if;
end process;

end rtl; 
