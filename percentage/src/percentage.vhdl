library ieee;
use ieee.std_logic_1164.all;

entity percentage is
    port (
        length : in  integer;
        i      : in  integer;
        result : out integer
    );
end entity percentage;

architecture rtl of percentage is
begin
    process(length, i)
        variable j : integer;
    begin
        if length > 0 then
            j := (i * 100) / length;
            if j < 1 then
                result <= 0;
            elsif j > 99 then
                result <= 0;
            else
                result <= j;
            end if;
        else
            result <= 0;
        end if;
    end process;
end architecture rtl;
