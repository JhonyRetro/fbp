library IEEE;
use IEEE.std_logic_1164.all;

library work;

entity encoder is
    port(
        E : in std_logic_vector(3 downto 0);
        Sel : in std_logic_vector(1 downto 0);
        S : out std_logic
    );
end entity encoder;

architecture behavior of encoder is
signal helper : std_logic_vector(7 downto 0);
begin
    mux_1 : entity work.mux
                port map(
                    ent1 => E(0),
                    ent2 => E(1),
                    sel => Sel(0),
                    S => helper(0)
                );
    mux_2 : entity work.mux
                port map(
                    ent1 => E(2),
                    ent2 => E(3),
                    sel => Sel(0),
                    S => helper(1)
                );
    mux_3 : entity work.mux
                port map(
                    ent1 => helper(0),
                    ent2 => helper(1),
                    sel => Sel(1),
                    S => S
                );
end architecture behavior;