library IEEE;
use IEEE.std_logic_1164.all;

library work;

entity mux is
    port(
        ent1 : in std_logic;
        ent2 : in std_logic;
        sel : in std_logic;
        S : out std_logic
    );
end entity;

architecture behavior of mux is
begin
    S <= ent1 and not sel;
    S <= ent2 and sel;
end architecture behavior;