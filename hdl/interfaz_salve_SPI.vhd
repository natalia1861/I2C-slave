-- DESCRIPCION: Top de la jerarquia del slave SPI

library ieee;
use ieee.std_logic_1164.all;

entity interfaz_slave_SPI is
port(clk:       in     std_logic;
     nRst:      in     std_logic;
     SPC:       in 		 std_logic;                      -- clock SPI (25 MHz)
     nCS:       in 		 std_logic;
     SDO:       buffer std_logic;                      -- slave data output (connected to Master SDI)
     SDIO:      inout  std_logic;	
     registros_s: buffer std_logic_vector(3 downto 0)										 -- slave data input  (connected to Master SDO)
		
    );
end entity;

architecture struct of interfaz_slave_SPI is

	signal leer_bit_op: std_logic;
	signal leer_dir: std_logic;
	signal leer_dato_reg: std_logic;
	signal reset_regs_SDIO: std_logic;
	signal escribir_dato_reg: std_logic;
	signal MSB_LSB: std_logic;
	signal instruccion: std_logic_vector(15 downto 0);
	signal dato_reg: std_logic_vector(7 downto 0);
	signal dato_in: std_logic_vector(7 downto 0);
	signal ctrl: std_logic;
	signal reg0: std_logic_vector(7 downto 0);
	signal reg1: std_logic_vector(7 downto 0);
	signal reg16: std_logic_vector(7 downto 0);
	signal reg17: std_logic_vector(7 downto 0);
  signal SPC_posedge: std_logic;
	signal SPC_negedge: std_logic;
	signal load: std_logic;
  signal WE: std_logic;
  signal mode_3_4_h: std_logic;
	signal dir_reg:  std_logic_vector(14 downto 0);
	signal dato_wr:  std_logic_vector(7 downto 0);	 -- Es el dato_reg de reg in
	signal dato_rd:  std_logic_vector(7 downto 0);
	signal desplaza_bit: std_logic;
	

begin

CONTROL_SLAVE: entity work.control_slave(rtl)
 
  port map(
  clk => clk,
  nRst   => nRst,
  nCS	=> nCS, 
  SPC => SPC,
  MSB_LSB => MSB_LSB,
  SPC_posedge => SPC_posedge,
  SPC_negedge => SPC_negedge,
  leer_dir => leer_dir,
  leer_dato_reg => leer_dato_reg,
  reset_regs_SDIO => reset_regs_SDIO,
  escribir_dato_reg => escribir_dato_reg,
  instruccion => instruccion,
  dato_out=>dato_in,
  dato_reg => dato_reg,
  load=>load,
  desplaza_bit => desplaza_bit,
  mode_3_4_h => mode_3_4_h,
  ctrl => ctrl,
  registros_s => registros_s
);

REG_IN: entity work.reg_in(rtl)

  port map(
  clk => clk,
  nRst   => nRst, 
	SPC_posedge => SPC_posedge,
  SPC_negedge => SPC_negedge,
  leer_dir => leer_dir,
  leer_dato_reg => leer_dato_reg,
  reset_regs_SDIO => reset_regs_SDIO,
	MSB_LSB => MSB_LSB,
	SDIO => SDIO,
  instruccion => instruccion,
  dato_reg => dato_reg
);

REG_OUT: entity work.reg_out(rtl)
port map(
	clk => clk,
	nRst =>nRst,
	SPC_posedge => SPC_posedge,
  SPC_negedge => SPC_negedge,
  MSB_LSB => MSB_LSB,
  escribir_dato_reg => escribir_dato_reg,
	dato_in => dato_in,
	load=>load,
	ctrl => ctrl,
	SDO => SDO,
	desplaza_bit=>desplaza_bit,
  mode_3_4_h => mode_3_4_h,
	SDIO => SDIO
  );

end struct;
