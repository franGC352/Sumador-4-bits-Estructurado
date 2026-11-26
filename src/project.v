/*
 * Copyright (c) 2025 Francisco García C
 */

library ieee;
use ieee.std_logic_1164.all;
entity tb_Adder4 is
end tb_Adder4;
architecture sim of tb_Adder4 is
 -- Declaramos el componente a probar
 component Adder4
 port(
 A, B : in bit_vector(3 downto 0);
 Ci : in bit;
 S : out bit_vector(3 downto 0);
 Co : out bit
 );
 end component;
 -- Señales internas para conectar al DUT (Device Under Test)
 signal A_tb, B_tb : bit_vector(3 downto 0);
 signal Ci_tb : bit;
 signal S_tb : bit_vector(3 downto 0);
 signal Co_tb : bit;
begin
 -- Instanciamos el diseño bajo prueba
 DUT: Adder4
 port map(
 A => A_tb,
 B => B_tb,
 Ci => Ci_tb,
 S => S_tb,
 Co => Co_tb
 );
 -- Proceso de estimulación
 stim_proc: process
 begin
 -- Caso 1: 0000 + 0000 + Cin=0
 A_tb <= "0000";
 B_tb <= "0000";
 Ci_tb <= '0';
 wait for 2 ns;

-- Caso 2: 0101 (5) + 0011 (3) + Cin=0
 A_tb <= "0101";
 B_tb <= "0011";
 Ci_tb <= '0';
 wait for 2 ns;
 -- Caso 3: 1111 (15) + 0001 (1) + Cin=0 -> debería dar 10000
 A_tb <= "1111";
 B_tb <= "0001";
 Ci_tb <= '0';
 wait for 2 ns;
 -- Caso 4: 1010 (10) + 0101 (5) + Cin=1
 A_tb <= "1010";
 B_tb <= "0101";
 Ci_tb <= '1';
 wait for 2 ns;
 -- Caso 5: 1111 + 1111 + Cin=1 -> prueba de overflow
 A_tb <= "1111";
 B_tb <= "1111";
 Ci_tb <= '1';
 wait for 2 ns;
 -- Finaliza la simulación
 wait;
 end process;
end sim;
