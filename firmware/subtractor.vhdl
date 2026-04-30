library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Subtractor is
    port (
        X     : in  std_logic;
        Y     : in  std_logic;
        B_in  : in  std_logic;
        D     : out std_logic;
        B_out : out std_logic
    );
end entity Subtractor;

architecture Structural of Subtractor is
begin
    D <= x xor y xor B_in;
    B_out <= ((not x) and B_in) or ((not x) and y) or (y and B_in);
end architecture Structural;
