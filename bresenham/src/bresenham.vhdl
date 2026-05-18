library ieee;
use ieee.std_logic_1164.all;

entity bresenham is
    port (
        clk : in    std_logic;
        x0  : in    integer;
        y0  : in    integer;
        x1  : in    integer;
        y1  : in    integer;
        d   : inout integer
    );
end entity bresenham;

architecture rtl of bresenham is
begin
    process(clk)
        variable dx : integer := 0;
        variable dy : integer := 0;
        variable dd : integer := 0;
        variable y  : integer := 0;
    begin
        dx := x1 - x0;
        dy := y1 - y0;
        dd := 2 * dy - dx;
        y  := y0;
        for x in x0 to (x1 - 1) loop
            if dd > 0 then
                y  := y + 1;
                dd := dd + 2 * (dy - dx);
            else
                dd := dd + 2 * dy;
            end if;
        end loop;
        d <= dd;
    end process;
end architecture rtl;
