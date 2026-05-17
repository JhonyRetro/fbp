library ieee;
use ieee.std_logic_1164.all;

entity percentage is
    port (
        clk    : in  std_logic;
        length : in  integer;
        i      : in  integer;
        result : out integer
    );
end entity percentage;

architecture rtl of percentage is
begin
    result <= (i * 100) / length
        when (length > 0)
        and (((i * 100) / length) >= 1)
        and (((i * 100) / length) <= 99)
        else 0;
end architecture rtl;
