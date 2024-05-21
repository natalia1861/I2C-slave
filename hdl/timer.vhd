-- Temporizadores
--
-- Genera las señales de temporizacion para el resto de circuitos. Todas son tics de un periodo
-- de reloj:
-- tic_2_5ms
-- tic_5ms
-- tic_0_5s


-- Genericos:
---- DIV_2_5ms (divisor para generar tics de 2,5 ms a partir del reloj de 50 MHz)
---- Los valores por defecto son para sintesis
--
--    Designer: DTE
--    Versión: 1.0
--    Fecha: 24-11-2016

library ieee;
use ieee.std_logic_1164.all;

use ieee.std_logic_unsigned.all;

entity timer is 

port(
    clk           : in std_logic;
    nRst          : in std_logic;
    tic_2_5ms     : buffer std_logic;
	 tic_5ms       : buffer std_logic;
    tic_0_5s      : buffer std_logic
    
    );  
end entity;

architecture rtl of timer is
  
  signal cnt_div_2_5ms : std_logic_vector(16 downto 0);  -- 125000 bin = 11110100001001000
	signal cnt_div_5ms: std_logic_vector(1 downto 0);  -- 2 veces el de 2.5ms
  signal cnt_div_0_5s : std_logic_vector(6 downto 0); -- 2 bin = 10
	 
  constant fdc_timer_2_5ms: natural := 124999;
	constant fdc_timer_5ms: natural :=1; 
  constant fdc_timer_0_5s: natural :=99;
  
begin
  
 -- generacion tic 2,5ms
 divisor_2_5ms: process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_div_2_5ms <= (others => '0');
    elsif clk'event and clk = '1' then
      if tic_2_5ms = '1' then
        cnt_div_2_5ms <= (others => '0');
      else
        cnt_div_2_5ms <= cnt_div_2_5ms + 1;
      end if;
    end if;
  end process divisor_2_5ms;
  tic_2_5ms <= '1' when cnt_div_2_5ms = fdc_timer_2_5ms else '0';

 -- generación del tic de 5 ms
 divisor_5ms: process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_div_5ms <= (others => '0');
    elsif clk'event and clk = '1' then
      if tic_5ms = '1' then
        cnt_div_5ms <= (others => '0');
      elsif tic_2_5ms = '1' then
        cnt_div_5ms <= cnt_div_5ms + 1;
      end if;
    end if;
  end process divisor_5ms;
  tic_5ms <= '1' when cnt_div_5ms = fdc_timer_5ms and tic_2_5ms = '1' else 
				 '0';
 
  -- generacion tic 0,5s
 divisor_0_5s: process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_div_0_5s <= (others => '0');
    elsif clk'event and clk = '1' then
      if tic_0_5s = '1' then
        cnt_div_0_5s <= (others => '0');
      elsif tic_5ms = '1' then
        cnt_div_0_5s <= cnt_div_0_5s + 1;
      end if;
    end if;
  end process divisor_0_5s;
  tic_0_5s <= '1' when cnt_div_0_5s = fdc_timer_0_5s and tic_5ms = '1' else '0';

end rtl;