library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.Subtractor;

entity Subtractor8Bit is
    port (
        X     : in  std_logic_vector(7 downto 0);
        Y     : in  std_logic_vector(7 downto 0);
        B_in  : in  std_logic_vector(7 downto 0);
        D     : out std_logic_vector(7 downto 0);
        B_out : out std_logic_vector(7 downto 0)
    );
end entity Subtractor8Bit;

architecture Behavioural of Subtractor8Bit is
    component Subtractor
        port (
            X     : in  std_logic;
            Y     : in  std_logic;
            B_in  : in  std_logic;
            D     : out std_logic;
            B_out : out std_logic
        );
    --signal TODO;
begin
    S0: Subtractor port map ();
    S1: Subtractor port map ();
    S2: Subtractor port map ();
    S3: Subtractor port map ();
    S4: Subtractor port map ();
    S5: Subtractor port map ();
    S6: Subtractor port map ();
    S7: Subtractor port map ();
end architecture Behavioural;
