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
    signal j : integer := 0;
begin
    j <= (i * 100) / length
        when length > 0
        else 0;

    result <= 0
        when (length <= 0)
        or (j < 1)
        or (j > 99)
        else j;
end architecture rtl;
