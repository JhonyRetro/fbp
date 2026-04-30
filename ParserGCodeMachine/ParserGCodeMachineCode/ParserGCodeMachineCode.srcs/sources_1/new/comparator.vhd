library IEEE;
use IEEE.std_logic_1164.all;

library work;

entity comparator_1bit is
    port(
        E : in std_logic_vector(1 downto 0);
        G : out std_logic;
        Eq : out std_logic;
        L : out std_logic
    );
end entity comparator_1bit;

architecture behavior of comparator_1bit is
signal helper : std_logic;
begin
    helper <= E(1) xor E(0);
    G <= E(1) and helper;
    Eq <= not helper;
    L <= E(0) and helper;
end architecture behavior;