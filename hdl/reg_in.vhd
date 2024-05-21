-- REGISTRO ENTRADA: 
--Se trata de un registro serie-paralelo que se encarga de serializar los bits para su posterior lectura o escritura.
--Para la sincronizacion de los datos y evitar glitches se ha disenado un doble flip-flop con objetivo sincronizar la entrada.

--FECHA : 02-05-2023


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reg_in is
  port(
    clk:		in std_logic;		--50 MHz (20ns)
    nRst:		in std_logic;

     -- bus SPI 
   
    SDIO:         	in std_logic;        -- Master Data Output (connected to slave SDI)
     	
    SPC_posedge:  	in std_logic;		--Senal que indica cuando se produce un flanco ascendente del reloj del bus spi
    SPC_negedge:  	in std_logic;		--Senal que indica cuando se produce un flanco descendente del reloj del bus spi
																											
    leer_dir:		in std_logic;	 	--Senal que indica cuando el slave puede leer de la linea SDIO los bits de direccion transmitidos por el master
    leer_dato_reg:	in std_logic; 	 	--Senal que indica cuando el slave puede leer de la linea SDIO los bits de datos transmitidos por el master 
    reset_regs_SDIO:	in std_logic; 	 	--Senal que indica el reset de los registros de lectura de cada transferencia

    MSB_LSB: in std_logic;
  --Stream_mode: 	in std_logic

    dato_reg:		buffer std_logic_vector(7 downto 0);  	--Salida que contiene el dato leido por parte del slave spi y que va a escribir en el banco de registros
    instruccion: 	buffer std_logic_vector(15 downto 0)   --Salida que contiene la direccion del banco de registros a la que accede el slave SPI para escribir o leer el dato correspondiente
		 																									-- Dato_reg se va a dividir en 1 bit de operacion r/w y 15 bites de la direccion del registro donde vamos a leer o escribir
    
 );

end entity;

architecture rtl of reg_in is

 signal SDIO_syn, SDIO_meta: std_logic; 


begin
-- CAMBIOS: hemos comentado SDI aparte de porque no esta creada
--Registro de entradas por doble flip flop (para sincronizacion)
  process(nRst, clk)
  begin
    if nRst = '0' then
      SDIO_syn <= '0';
      SDIO_meta <= '0';

    elsif clk'event and clk = '1' then  
      SDIO_meta <= SDIO; 
      SDIO_syn <= SDIO_meta; 
      end if;
   end process;
			     
--Registro serie paralelo
--Los primeros 16 bits son de instruccion: Siendo el primer bit de lectura 1 o escritura 0
--Los datos de transmitiran de 8 bits en 8 bits

  process(nRst,clk)
  begin
    if nRst = '0' then

      instruccion <= (others => '0'); 		--Direccion destino
      dato_reg <= (others => '0');

    elsif clk'event and clk = '1' then 
      if SPC_posedge = '1' then--and fin_tx = '1'
        if reset_regs_SDIO = '1' then
	  			instruccion <= (others => '0');
          dato_reg <= (others => '0');			
      			
      	elsif leer_dir = '1' then	
      			if MSB_LSB = '0' then						
      	  			instruccion <= instruccion(14 downto 0)&SDIO_syn;		
      				else
      					instruccion <= SDIO_syn & instruccion(15 downto 1);
      				end if;
      	elsif leer_dato_reg = '1' then	
      		if MSB_LSB = '0' then					
      	  		dato_reg <= dato_reg(6 downto 0)&SDIO_syn;
      		else 
              dato_reg <= SDIO_syn & dato_reg(7 downto 1);
      		end if; 
        end  if;
      end if;
     end if;
  end process;
 

end rtl;
