library IEEE;
use IEEE.std_logic_1164.all;

library work;

entity decoder_8_bit is
    port (
        E : in std_logic;
        S : out std_logic_vector(7 downto 0);
        Sel : in std_logic_vector(2 downto 0)
    );
end entity decoder_8_bit;

architecture behavior of decoder_8_bit is
signal helper : std_logic_vector(15 downto 0);
begin
    mux_1 : entity work.decoder
                port map(
                    E => E,
                    Sel => Sel(2),
                    S => helper(1 downto 0)
                ); 
    mux_2 : entity work.decoder
                port map(
                    E => helper(0),
                    Sel => Sel(1),
                    S => helper(3 downto 2)
                );
    mux_3 : entity work.decoder
                port map(
                    E => helper(1),
                    Sel => Sel(1),
                    S => helper(5 downto 4)
                ); 
    mux_4 : entity work.decoder
                port map(
                    E => helper(2),
                    Sel => Sel(0),
                    S => S(1 downto 0)
                ); 
    mux_5 : entity work.decoder
                port map(
                    E => helper(3),
                    Sel => Sel(0),
                    S => S(3 downto 2)
                ); 
    mux_6 : entity work.decoder
                port map(
                    E => helper(3),
                    Sel => Sel(0),
                    S => S(5 downto 4)
                ); 
    mux_7 : entity work.decoder
                port map(
                    E => helper(4),
                    Sel => Sel(0),
                    S => S(7 downto 6)
                );
end architecture behavior;