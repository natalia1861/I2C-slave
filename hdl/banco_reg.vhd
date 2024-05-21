--DESCRIPCION: Banco de registros del SPI para guardar datos en direcciones

library ieee;
use ieee.std_logic_1164.all;

entity banco_reg is
port(

			clk:  in std_logic;
			nRst: in std_logic;
			WE: 		in std_logic;
	 		fin_tx:	in std_logic;
	 		dir_reg: 	in std_logic_vector(14 downto 0);  -- Es la senal dir de reg in. Tenemos en cuenta que solo se puede leer y escribir a la vez entonces tenemos una sola direccion de r/w
	 		dato_wr: 	in std_logic_vector(7 downto 0);	 -- Es el dato_reg de reg in
	 		dato_rd: 	buffer std_logic_vector(7 downto 0);
			reg0: buffer std_logic_vector(7 downto 0);
			reg1: buffer std_logic_vector(7 downto 0);
			reg16: buffer std_logic_vector(7 downto 0);
			reg17: buffer std_logic_vector(7 downto 0)
);

end entity;

architecture rtl of banco_reg is

--	signal reg0: std_logic_vector(7 downto 0);
--	signal reg1: std_logic_vector(7 downto 0);
--	signal reg16: std_logic_vector(7 downto 0);
--	signal reg17: std_logic_vector(7 downto 0);

begin

--Banco de registros
  process(nRst,clk)
  begin
    if nRst = '0' then
	  reg0 <= (others => '0');
	  reg1 <= (others => '0');
  	reg16 <= (others => '0');
  	reg17 <= (others => '0');
	elsif clk'event and clk = '1' then
	 -- if WE = '1' and fin_tx = '1' then  --	De momento lo comentamos porque en modo streaming puedes recibir dos datos
																				 -- y tener que guardarlos a la vez en dos registros diferentes
																				 -- implementacion: WE se activa cada vez que queramos escribir en un registro sin tener en cuenta el fin de la transmision
		if WE = '1' then										 --	Pensamos que se puede escribir dos datos a la vez en dos registros diferentes			 
	    case dir_reg is
	      when "000000000000000" =>
		    	reg0 <= dato_wr;
		  	when "000000000000001" =>
		    	reg1 <= dato_wr;
		  	when "000000000000010" =>
		    	reg16 <= dato_wr;
		  	when "000000000000011" =>
		    	reg17 <= dato_wr;
		  	when others =>
		    	null;
        end case;
      end if;
	end if;
  end process;
  

  dato_rd <= reg0  when dir_reg = "000000000000000" else
						 reg1  when dir_reg = "000000000000001" else
						 reg16 when dir_reg = "000000000000010" else
					   reg17 when dir_reg = "000000000000011" else
						 "XXXXXXXX";

end rtl;
