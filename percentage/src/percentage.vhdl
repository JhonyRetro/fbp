library ieee;
use ieee.std_logic_1164.all;

entity percent is
    port (
        length : in  integer;
        i      : in  integer;
        result : out integer
    );
end entity percent;

architecture rtl of percent is
    signal j : integer := 0;
begin
    process(all)
    begin
        if length > 0 then
            j <= (i * 100) / length;
            if j < 100 then
                if j > 0 then
                    result <= j;
                else
                    result <= 0;
                end if;
            else
                result <= 0;
            end if;
        else
            result <= 0;
        end if;
    end process;
end architecture rtl;
