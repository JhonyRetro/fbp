library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;

entity decoder is
    port(
        E : in std_logic;
        Sel : in std_logic;
        S : out std_logic_vector(1 downto 0)
    );
end entity decoder;


architecture behavior of decoder is
begin
    S(0) <= E when Sel = '0';
    S(1) <= E when Sel = '1';
end architecture behavior;