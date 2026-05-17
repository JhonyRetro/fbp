library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity BresenhamLineAlgorithm is
    generic (
        N : integer := 16 -- Word length
    );

    port (
        x0 : in  unsigned(N-1 downto 0);
        y0 : in  unsigned(N-1 downto 0);
        x1 : in  unsigned(N-1 downto 0);
        y1 : in  unsigned(N-1 downto 0);
        D  : out unsigned(N-1 downto 0)
    );
end entity BresenhamLineAlgorithm;

architecture Behavioural of BresenhamLineAlgorithm is
    signal dx : unsigned(N-1 downto 0) := (others => '0');
    signal dy : unsigned(N-1 downto 0) := (others => '0');
    signal y  : unsigned(N-1 downto 0) := (others => '0');
begin
    process(all)
    begin
        dx <= x1 - x0;
        dy <= y1 - y0;
        D <= 2 * dy - dx;
        y <= y0;

        for x in to_integer(x0) to to_integer(x1)-1 loop
            -- plot(x, y);
            if D > 0 then
                y <= y + 1;
                D <= D + 2 * (dy - dx);
            else
                D <= D + 2 * dy;
            end if;
        end loop;
    end process;
end architecture Behavioural;
