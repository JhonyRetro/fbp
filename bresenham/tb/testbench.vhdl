library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end entity testbench;

architecture test of testbench is
    signal clk : std_logic := '0';
    signal x0  : integer   := 0;
    signal y0  : integer   := 0;
    signal x1  : integer   := 0;
    signal y1  : integer   := 0;
    signal d   : integer   := 0;
    signal i   : integer   := 0;

    constant period : time := 10 ns;
    constant max    : time := 2 us;
begin
    uut: entity work.bresenham
        port map (
            clk => clk,
            x0  => x0,
            y0  => y0,
            x1  => x1,
            y1  => y1,
            d   => d
        );

    clock: process
    begin
        while true loop
            clk <= '0';
            wait for period;
            clk <= '1';
            wait for period;
        end loop;
    end process clock;

    stimulus: process(clk)
    begin
        if falling_edge(clk) then
            i <= (i + 1) mod 4;
        end if;
        case i is
            when 0      => x0  <= x0 + 1;
            when 1      => y0  <= y0 + 1;
            when 2      => x1  <= x1 + 1;
            when 3      => y1  <= y1 + 1;
            when others => null;
        end case;
    end process stimulus;

    stop: process
    begin
        wait for max;
        assert false report "END" severity failure;
    end process stop;
end architecture test;
