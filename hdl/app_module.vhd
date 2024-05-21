library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity app_module is
port(nRst:           in     std_logic;              -- Reset asíncrono
     clk:            in     std_logic;              -- 50 MHz

     -- Interfaz teclado:
     tic_tecla:      in     std_logic;              -- Indica que se ha pulsado un tecla en el teclado (debe tener 1 ciclo de reloj de duración)
     tecla:          in     std_logic_vector(3 downto 0);     -- Código que identifica la tecla que ha sido pulsada

     -- Interfaz master:
     start:          buffer std_logic;                -- Orden de ejecucion (hacia el master SPI)
     no_bytes:       buffer std_logic_vector(2 downto 0);     -- Numero de bytes totales en la transferencia (incluyendo direccion) (hacia el master SPI)
     dato_wr:        buffer std_logic_vector(47 downto 0);      -- dato de entrada (alineado a la izquierda) (hacia el master SPI)
     dato_rd:        in     std_logic_vector(7 downto 0);       -- valor del byte leido (desde el master SPI)
     ena_rd:         in     std_logic;              -- valida a nivel alto a dato_rd  (desde el master SPI)           
     rdy:            in     std_logic;              -- unidad preparada para aceptar start (desde el master SPI) 

    -- Interfaz esclavo
    registros_s:     in std_logic_vector(3 downto 0); --solo necesitamos saber los modos
     
     -- Interfaz display:
     info_disp:      buffer std_logic_vector(2 downto 0);     -- bits(1 downto 0) -> display que está siendo editado, bit(2) -> modo de edición de registros de configuracion (0) o de operacion (1)
     reg_tx:         buffer std_logic_vector(15 downto 0);      -- Información para los cuatro dígitos hexadecimales ( uno por display)

     -- Status
     MSB_1st: 			in std_logic;
     mode_3_4_h: 		in std_logic;
     str_sgl_ins:    in std_logic;                  -- 0 -> modo streaming, 1 -> modo single instruction
     add_up:         in std_logic;  

     --Comunicacion con presentacion
     check_mode: buffer std_logic;                -- 0 -> modo decremento de dirección, 1 -> modo incremento de direccion

     --leds
     tic_2_5ms: in std_logic;
     LEDn: buffer std_logic_vector(2 downto 0);
     Bn: buffer std_logic_vector(2 downto 0));

end entity;

architecture rtl of app_module is
  type   t_estado is (reg_op_st, 
                      to_reg_op_st, 
                      reg_conf_st,
                      to_reg_conf_st,
          modo_chequeo);

  signal estado: t_estado;

  signal tx:           std_logic;
  signal rx:           std_logic;
  signal cambiar_modo: std_logic;
  signal shift:        std_logic;
  signal inc:          std_logic;
  signal dec:          std_logic;

  signal idx:          std_logic_vector(1 downto 0);
  
  signal change_check_mode: std_logic;
  signal change_trans_mode: std_logic;

  signal LED_rojo: std_logic;
  signal LED_verde: std_logic;
  signal LED_naranja: std_logic;

  

begin

 tx <= rdy and tic_tecla when estado = reg_op_st   and tecla = X"E"                                                                    else
       rdy and tic_tecla when estado = reg_conf_st and tecla = X"E" and reg_tx(11 downto 8) /= 0                                       else
       rdy and tic_tecla when estado = reg_conf_st and tecla = X"E" and reg_tx(7 downto 4) = (reg_tx(0)&reg_tx(1)&reg_tx(2)&reg_tx(3)) else
       '0';

 rx <= rdy and tic_tecla when tecla = X"F" else
       '0';

 cambiar_modo <= tic_tecla when tecla = X"C" else
                 '0';

 shift <= tic_tecla when (estado = reg_op_st or estado = reg_conf_st) and tecla = X"D" else
          '0';

 inc   <= tic_tecla and rdy when (estado = reg_op_st or estado = reg_conf_st) and tecla = X"A" else
          '0';

 dec   <= tic_tecla and rdy when (estado = reg_op_st or estado = reg_conf_st) and tecla = X"B" else
          '0';

 check_mode <= '1' when estado = modo_chequeo else
    '0';
	 
 change_check_mode <= '1' when tic_tecla = '1' and tecla = X"2" else
							 '0';

 change_trans_mode <= '1' when tic_tecla = '1' and tecla = X"1" else
							'0';

  --proceso para los leds


Bn <= not(LED_verde & LED_naranja & LED_rojo) when estado = modo_chequeo else
	"111";

LEDn <= "111" when estado = modo_chequeo else
	"000";

LED_verde <= '1' when (str_sgl_ins & add_up & MSB_1st & mode_3_4_h) = registros_s and estado = modo_chequeo else
             '0';

LED_rojo <= not LED_verde when estado = modo_chequeo else
            '0';

LED_naranja <= '1' when registros_s(0) = '0' and estado = modo_chequeo else
               '0';


  process(clk, nRst)
  begin
    if nRst = '0' then
      estado <= reg_op_st;
      start <= '0';
      no_bytes <="000";
      dato_wr <= (others => '0');
      reg_tx  <= (others => '0');
      idx <= "00";

    elsif clk'event and clk = '1' then
      if shift = '1' then
        if info_disp(2) = '1' and idx = 2 then
          idx <= "00";

        else
          idx <= idx + 1;

        end if;

      elsif inc = '1' then
        case idx is
          when "00" => 
            reg_tx(3 downto 0) <= reg_tx(3 downto 0)+ 1; 

          when "01" => 
            reg_tx(7 downto 4) <= reg_tx(7 downto 4)+ 1;

          when "10" =>
            if info_disp(2) = '0' then  
              reg_tx(11 downto 8) <= reg_tx(11 downto 8)+ 1;

            else
              reg_tx(8) <= not reg_tx(8);

            end if;

          when "11" => 
            reg_tx(15 downto 12) <= reg_tx(15 downto 12)+ 1;

          when others => null;
        end case;

      elsif dec = '1' then
        case idx is
          when "00" => 
            reg_tx(3 downto 0) <= reg_tx(3 downto 0) - 1; 

          when "01" => 
            reg_tx(7 downto 4) <= reg_tx(7 downto 4) - 1;

          when "10" => 
            if info_disp(2) = '0' then  
              reg_tx(11 downto 8) <= reg_tx(11 downto 8) - 1;

            else
              reg_tx(8) <= not reg_tx(8);

            end if;

          when "11" => 
            reg_tx(15 downto 12) <= reg_tx(15 downto 12) - 1;

          when others => null;
        end case;

      elsif ena_rd = '1' then
        if info_disp(2) = '0' then  
          reg_tx <= reg_tx(7 downto 0) & dato_rd;

        else
          reg_tx(7 downto 0) <= dato_rd;              

        end if;


      else
        case estado is
    when modo_chequeo =>
      reg_tx(3 downto 0) <= registros_s; 
      if change_trans_mode = '1' then
		  estado <= reg_op_st;
      end if;
      
      --controlar_master y slave estan en el mismo modo();
          when reg_op_st =>
            if tx ='1' then
              idx <= "00";
              estado <= to_reg_op_st;
              start <= '1';
              if str_sgl_ins = '0' then
                no_bytes <= "100";
                if add_up = '1' then 
                  dato_wr(47 downto 16) <= X"0010"&reg_tx;

                else
                  dato_wr(47 downto 16) <= X"0011"&reg_tx;

                end if;

              else
                no_bytes <= "110";
                dato_wr  <= X"0010"&reg_tx(15 downto 8)& X"0011"&reg_tx(7 downto 0);

              end if;

            elsif rx = '1' then
              idx <= "00";
              estado <= to_reg_op_st;
              start <= '1';
              if str_sgl_ins = '0' then
                no_bytes <= "100";
                if add_up = '1' then 
                  dato_wr(47 downto 32) <= X"8010";

                else
                  dato_wr(47 downto 32) <= X"8011";

                end if;

              else
                no_bytes <= "110";
                dato_wr  <= X"8010"&X"00"&X"8011"&X"00";

              end if;

            elsif cambiar_modo = '1' then
              estado <= reg_conf_st;
              reg_tx  <= (others => '0');
              idx <= "00";

				elsif change_check_mode = '1' then
					estado <= modo_chequeo;

            end if;

          when to_reg_op_st =>
            start <= '0';
            estado <= reg_op_st;

          when reg_conf_st =>
            if tx = '1' then
              estado <= to_reg_conf_st;
              start  <= '1';
              no_bytes <= "011";
              dato_wr(47 downto 24) <= X"000"&reg_tx(11 downto 0);

            elsif rx = '1' then
              estado <= to_reg_conf_st;
              start <= '1';
              no_bytes <= "011";
              dato_wr(47 downto 32) <= X"800"&reg_tx(11 downto 8);

            elsif cambiar_modo = '1' then
              estado <= reg_op_st;
              reg_tx  <= (others => '0');
              idx <= "00";

				elsif change_check_mode = '1' then
					estado <= modo_chequeo;
            end if;

          when to_reg_conf_st =>
            start <= '0';
            estado <= reg_conf_st;

        end case;
      end if;
    end if;
  end process;

  info_disp <= '0'&idx when estado = reg_op_st or estado = to_reg_op_st  else
               '1'&idx;

end rtl;


