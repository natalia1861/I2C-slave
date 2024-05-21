-- REGISTRO SALIDA:
-- Modulo encargado de la transimision de los datos de 8 bits mediante un registro 
-- paralelo-serie. El modulo de control es el encargado de ofrecer la informacion en el
-- modo de corresponda dada la configuracion del escalo SPI.

--FECHA : 02-05-2023

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reg_out is
  port(    
	clk:				in std_logic;
	nRst:				in std_logic;
	 
	SPC_posedge:			in std_logic;				-- Indica la activacion de flanco de subida de CL
	SPC_negedge:			in std_logic;				-- Indica la activacion de flanco de bajada de CL
	escribir_dato_reg: 		in std_logic;				-- Habilita la escritura del dato
	 
	dato_in	:			in std_logic_vector(7 downto 0);	-- Dato a transmitir
	MSB_LSB: 			in std_logic;
	ctrl:				in std_logic;				-- Controla la lectura y escritura en la linea MOSI
	load: 				in std_logic;
	desplaza_bit: 			in std_logic;
  mode_3_4_h: in std_logic;		 -- 0 -> modo streaming, 1 -> modo single instruction	
	
	SDO :				out std_logic;
	SDIO:				inout std_logic				-- Dato SPI en linea
  );
end entity;

architecture rtl of reg_out is
  signal dato_out: std_logic_vector(7 downto 0);

begin
--Registro de salida paralelo-serie
  process(clk,nRst)
  begin
    if nrst ='0' then
     dato_out<=(others=>'0');
    elsif clk'event and clk = '1' then
     if load ='1' then
      dato_out <=dato_in;
     elsif desplaza_bit = '1' then 
      if MSB_LSB = '0' then
        dato_out<=dato_out(6 downto 0)&'0';
      else
        dato_out<= '0'&dato_out(7 downto 1);
      end if;
     end if;
    end if;
  end process;
  
 
  
--Escritura en la linea SDIO

  SDIO <= dato_out(7) when ctrl = '0' and MSB_LSB = '0' and mode_3_4_h = '0' else -- mas tarde se impondra que dependa del modo 3 o 4 hilos
         dato_out(0) when ctrl = '0' and MSB_LSB = '1'  and mode_3_4_h = '0' else
        'Z';

  
	SDO <= dato_out(7) when ctrl = '0' and MSB_LSB = '0'  and mode_3_4_h = '1' else -- mas tarde se impondra que dependa del modo 3 o 4 hilos
         dato_out(0) when ctrl = '0' and MSB_LSB = '1'  and mode_3_4_h = '1' else
        'Z';

end rtl;