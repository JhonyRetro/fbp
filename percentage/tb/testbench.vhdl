library ieee;
use ieee.std_logic_1164.all;

library work;
use work.all;

entity testbench is
end entity testbench;

architecture test of testbench is
    signal   clk    : std_logic := '0';
    signal   length : integer := 0;
    signal   i      : integer := 0;
    signal   seg    : std_logic_vector(6 downto 0);
    signal   an     : std_logic_vector(3 downto 0);
    constant period : time := 10 ns;
begin
    ctl: entity work.controller
        port map (
            clk    => clk,
            length => length,
            i      => i,
            seg    => seg,
            an     => an
        );

    clock: process
    begin
        while true loop
            clk <= '0';
            wait for period;
            clk <= '1';
            wait for period;
        end loop;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            i <= i + 1;
        end if;
    end process;
end architecture test;
