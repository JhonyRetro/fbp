library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.Subtractor;

entity Subtractor8Bit is
    port (
        X     : in  std_logic_vector(7 downto 0);
        Y     : in  std_logic_vector(7 downto 0);
        B_in  : in  std_logic;
        D     : out std_logic_vector(7 downto 0);
        B_out : out std_logic
    );
end entity Subtractor8Bit;

architecture Structural of Subtractor8Bit is
    component Subtractor
        port (
            X     : in  std_logic;
            Y     : in  std_logic;
            B_in  : in  std_logic;
            D     : out std_logic;
            B_out : out std_logic
        );

    signal B : std_logic_vector(7 downto 0) := (others => '0');
begin
    S0 : Subtractor port map (
        X     => X(0)
        Y     => Y(0)
        B_in  => B_in,
        D     => D(0),
        B_out => B(0)
    );

    Subtractors1To7: for i in 1 to 7 generate
    begin
        S : Subtractor port map
            X     => X(i),
            Y     => Y(i),
            B_in  => B(i-1),
            D     => D(i),
            B_out => B(i)
        );
    end generate Subtractors1To7;

    B_out <= B(7);
end architecture Structural;
