library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library modelsim_lib; -- spies
use modelsim_lib.util.all; 

library work;
use work.pack_test_spi.all;

entity test_top is
end entity;

architecture test of test_top is
  signal nRst:        std_logic;
  signal clk:         std_logic;

  signal MSB_1st:     std_logic;
  signal mode_3_4_h:  std_logic;
  signal str_sgl_ins: std_logic;
  signal add_up:      std_logic;

  signal SDIO:        std_logic;
  signal SDO:         std_logic;


  signal tic_tecla:   std_logic;
  signal tecla:       std_logic_vector(3 downto 0);

  signal seg:         std_logic_vector(7 downto 0);
  signal mux_disp:    std_logic_vector(7 downto 0); 

  signal nCS:      std_logic;
  signal info_disp: std_logic_vector(2 downto 0);
  signal reg_tx:    std_logic_vector(15 downto 0); 


  constant Tclk: time := 5 ns;

begin 
  process
  begin
    clk <= '0';
    wait for Tclk/2;
 
    clk <= '1';
    wait for Tclk/2;

  end process;

dut: entity work.top_sim(struct)
     generic map (fdc_timer_2_5ms => 2, fdc_timer_0_5s => 8)

     port map(clk         => clk,
              nRst        => nRst,
              MSB_1st     => MSB_1st,
              mode_3_4_h  => mode_3_4_h,
              str_sgl_ins => str_sgl_ins,
              add_up      => add_up,
              tic_tecla   => tic_tecla,
              tecla       => tecla,
              SDIO_m      => SDIO,
              SDIO_s      => SDIO,
              SDO_m       => SDO,
              SDO_s       => SDO,
              seg         => seg,
              mux_disp    => mux_disp); 

process
begin

    -- Inicializacion de los spies 
    init_signal_spy("/test_top/dut/nCS", "/nCS");
    init_signal_spy("/test_top/dut/info_disp", "/info_disp");
    init_signal_spy("/test_top/dut/reg_tx", "/reg_tx");


  nRst <= '1';
  wait until clk'event and clk = '1';
  nRst <= '0';

-- CTRL_MS
  tic_tecla <= '0';
  tecla <= (others => '0');

  wait until clk'event and clk = '1';
  nRst <= '1';

  wait for 5* Tclk;
  wait until clk'event and clk = '1';

  -- Esclavo lee el registro de conf 0 ->  * MODO SINGLE INSTRUCTION
  report "Esclavo lee el registro de conf 1 ->";

-- CONF
  add_up <= '0';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"1", X"80", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

  -- Lectura de los 2 registros de op -> EN SINGLE INTRUCTION *
  report "Lectura de los 2 registros de op ->";

-- CONF
  add_up <= '0';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '1';

-- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"5678", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

  -- Escritura al master de los 2 registros de op -> *
  report "Escritura al master de los 2 registros de op ->";
  
-- CONF
  add_up      <= '0';
  MSB_1st     <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer 

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

  -- Cambiar autoincremento ascendente
  report "Cambiar autoincremento ascendente";

-- CONF
  add_up <= '0';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"24", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
--ESCRIBIR EN EL REGISTRO DE CONFIGURACION EN MODO 4 HILOS, ASCENSION, STREAMING Y MSB-FIRST
-- X"3C" => ASCENSION, 4 HILOS, MSB-FIRST
-- CONF
  add_up <= '1';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"3C", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

 -- ESCRIBIR EN LOS REGISTROS DE OPERACION ASCENSION 4 HILOS MSB-FIRST STREAMING                                            
-- CONF
  add_up <= '1';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"AA55", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

 wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';


--ESCRIBIR EN EL REGISTRO DE CONFIGURACION EN MODO 4 HILOS, ASCENSION, STREAMING Y LSB-FIRST
-- X"7E" => ASCENSION, 4 HILOS, LSB-FIRST

-- CONF
  add_up <= '1';
  MSB_1st <= '1';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"7E", clk); 
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';



--OPERACION: ASCENDENTE 4 HILOS LSB-FIRST STREAMING 

  add_up <= '1';
  MSB_1st <= '1';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"5678", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

 wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
-- CONFIGURACION EN MODO 4 HILOS, DESCENDENTE, STREAMING Y MSB-FIRST
                                             
-- CONF
  add_up <= '0';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"18", clk); 
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CONFIGURACION EN MODO 4 HILOS, ASCENSION, 4 HILOS Y MSB-FIRST

-- CONF
  add_up <= '1';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"3C", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CONFIGURACION 01 PARA MODO SINGLE INSTRUCCTION

-- CONF
  add_up <= '1';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '1';

-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"1", X"80", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
-- OPERACION ASCENSION 4 HILOS MSB-FIRST SINGLE                                           
-- CONF
  add_up <= '1';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '1';

-- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"2345", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

 wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
-- CONFIGURACION EN MODO 4 HILOS, ASCENDENTE, SINGLE Y MSB-FIRST


-- X"18" => DESCENSION, 4 HILOS, MSB-FIRST
-- CONF
  add_up <= '1';
  MSB_1st <= '1';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '1';

-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"7E", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';


-- OPERACION ASCENSION 4 HILOS MSB-FIRST SINGLE 

-- CONF
  add_up <= '1';
  MSB_1st <= '1';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '1';

-- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"6789", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

 wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
wait for 50* Tclk;
  wait until clk'event and clk = '1';
wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"2" , clk);  --Leer
  
  wait for 50* Tclk;
  pulsar(tic_tecla, tecla, X"1" , clk);  --Leer 
  wait for 50* Tclk;
  add_up <= '1';
  MSB_1st <= '1';
  mode_3_4_h  <= '0';
  str_sgl_ins <= '1';
  
  wait for 50* Tclk;
  pulsar(tic_tecla, tecla, X"2" , clk);  --Leer 
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

   assert false
  report "Fin del test"
  severity failure;
end process;
end test;





