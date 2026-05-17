library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end entity testbench;

architecture test of testbench is
    signal   length : integer := 100;
    signal   i      : integer := 0;
    signal   seg    : std_logic_vector(6 downto 0) := (others => '0');
    signal   an     : std_logic_vector(3 downto 0) := (others => '0');

    constant period : time := 10 ns;
begin
    uut: entity work.controller
        port map (
            length => length,
            i      => i,
            seg    => seg,
            an     => an
        );

    stimulus: process
    begin
        wait for 10 ns;
        i <= i + 1;
    end process;

    stop: process
    begin
        wait for 2 us;
        assert false report "END" severity failure;
    end process;
end architecture test;
