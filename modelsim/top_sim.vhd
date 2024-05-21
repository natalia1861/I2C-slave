-- FECHA: 25/04/2023
-- DESCRIPCION: Top del SPI

library ieee;
use ieee.std_logic_1164.all;

entity top_sim is
--generic(
--    fdc_timer_2_5ms : natural :=124999;
--		fdc_timer_0_5s: natural :=99
--   );
port(

-- teclado
		clk: in std_logic;
		nRst: in std_logic;
		tic_tecla: in std_logic;
		tecla: in std_logic_vector(3 downto 0);
	
		--columna: in std_logic_vector(3 downto 0);
		fila: buffer std_logic_vector(3 downto 0);
		seg: in std_logic_vector(7 downto 0);   --EN LAS ESPECIFICACIONES PONE 6:0
		disp: buffer std_logic_vector(7 downto 0);
		
		SDIO_m: inout std_logic; 
		SDIO_s: inout std_logic; 
		SDO_m: in std_logic;
		SDO_s: out std_logic;

		mux_disp: buffer std_logic_vector(7 downto 0);  -- salida mux disp

	--swithces
		MSB_1st: in std_logic;							  -- 0 -> modo MSB First, 1 -> modo LSB First
      mode_3_4_h: in std_logic;							  -- 0 -> modo 3 hilos, 1 -> modo 4 hilos
      str_sgl_ins: in std_logic;							  -- 0 -> modo streaming, 1 -> modo single instruction
		add_up:   in std_logic;	   -- 0 -> modo descenso de dir, 1 -> modo ascenso de dir
		
	-- leds
	LEDn: buffer std_logic_vector(2 downto 0);
	Bn: buffer std_logic_vector(2 downto 0)
);
end entity;

architecture struct of top_sim is

--senales timer
  signal tic_2_5ms: std_logic;
  signal tic_0_5s: std_logic;
  signal tic_5ms: std_logic;
	
--senales master

  signal start: std_logic;                       -- Orden de ejecucion (si rdy = 1 ) => rdy  <= 0 hasta fin, cuando rdy <= 1
  signal no_bytes: std_logic_vector(2 downto 0);    -- Numero de bytes totales en la transferencia (incluyendo direccion) 
  signal dato_in: std_logic_vector(47 downto 0);   -- dato de entrada (alineado a la izquierda)
  signal dato_rd: std_logic_vector(7 downto 0);    -- valor del byte leido
  signal ena_rd: std_logic;                       -- valida a nivel alto a dato_rd -> Ignorar en operacion de escritura
  signal rdy: std_logic;                       -- unidad preparada para aceptar start

  signal nCS:  std_logic;                      -- chip select
  signal SPC:  std_logic;                      -- clock SPI (25 MHz) 
  signal SDI:  std_logic;                      -- Master Data input (connected to slave SDO)

--senales presentacion
  signal info_disp: std_logic_vector(2 downto 0);  -- bits(1 downto 0) -> display que est� siendo editado, bit(2) -> modo de edici�n de registros de configuracion (0) o de operacion (1)
  signal reg_tx:    std_logic_vector(15 downto 0);  -- Informaci�n para los cuatro d�gitos hexadecimales ( uno por display)
  signal check_mode: std_logic;
--senales app_module
  signal dato_wr: std_logic_vector(47 downto 0);
  signal registros_s: std_logic_vector(3 downto 0);

  --signal tic_tecla: std_logic;
  --signal tecla: std_logic_vector(3 downto 0);

begin

--control_tec: entity work.ctrl_tec(rtl)
--port map(
--	clk => clk,
--	nRst => nRst,
--	tic => tic_5ms,
--	columna => columna,
--	fila => fila,
--	tecla_pulsada => tic_tecla,
--	tecla => tecla
--	);
 
TIMER: entity work.timer(rtl) 
--generic map(
		--fdc_timer_2_5ms => fdc_timer_2_5ms
  --  )
port map(
    clk         => clk,
    nRst        => nRst,
    tic_2_5ms   => tic_2_5ms,
    tic_0_5s    => tic_0_5s,
    tic_5ms      => tic_5ms
    
    );
MASTER: entity work.master_spi_3_4_hilos(rtl)
port map(
		        
     clk 		=>  clk,
     nRst 		=>  nRst,      
     -- Config
     MSB_1st		=>  MSB_1st,
     mode_3_4_h		=>  mode_3_4_h,
     str_sgl_ins	=>  str_sgl_ins,

     -- Ctrl_SPI
     start		=>    start,  
     no_bytes		=>    no_bytes, 
     dato_in		=>    dato_in,
     dato_rd		=>    dato_rd,
     ena_rd	        =>    ena_rd,
     rdy		=>    rdy,     

     -- bus SPI
     nCS		=>   nCS,      
     SPC		=>   SPC,      
     SDI		=>   SDO_m,      
     SDIO		=>   SDIO_m     
    
);

SLAVE: entity work.interfaz_slave_SPI(struct)
port map(

     clk => clk,
     nRst => nRst,
     SPC => SPC,
     nCS => nCs,
     SDO => SDO_s,
     SDIO => SDIO_s,				 -- slave data input  (connected to Master SDO)
     registros_s => registros_s	
);

PRESENTACION: entity work.presentacion(rtl)
port map(
		
     clk 	=> clk,           
     nRst 	=> nRst,         
     tic_2_5ms 	=> tic_2_5ms,  
     tic_0_5s 	=> tic_0_5s,     
     info_disp  => info_disp,   
     reg_tx 	=> reg_tx,
     check_mode => check_mode,            
     mux_disp 	=> mux_disp
     --seg => seg
		
);

APP_MODULE: entity work.app_module(rtl)
port map(
			
		clk  => clk,
		nRst => nRst,
		tic_tecla => tic_tecla,
		tecla => tecla,
		start => start,
		no_bytes => no_bytes,
		dato_wr => dato_in,
		dato_rd => dato_rd,
		ena_rd => ena_rd,
		rdy => rdy,
		info_disp => info_disp,
		reg_tx => reg_tx,
		MSB_1st => MSB_1st,
		mode_3_4_h => mode_3_4_h,
		str_sgl_ins => str_sgl_ins,
		add_up => add_up,
     		check_mode => check_mode,
		registros_s => registros_s,
		tic_2_5ms => tic_2_5ms,
		LEDn => LEDn,
		Bn => Bn
   
);


end struct;
