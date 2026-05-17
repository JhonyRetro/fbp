library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Percentage is
    port (
        length : in integer
    );
end entity percentage;

architecture RTL of Percentage is
    signal selector : std_logic_vector(3 downto 0) := (others => '0');
    signal segments : std_logic_vector(6 downto 0) := (others => '0');
    signal pulse    : std_logic := '0';
    signal i        : integer := 0;
begin
    process(pulse)
    begin
        i <= i + 1;
    end process;
end architecture RTL;
