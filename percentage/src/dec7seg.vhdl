library ieee;
use ieee.std_logic_1164.all;

entity dec7seg is
    port (
        num : in  integer;
        seg : out std_logic_vector(6 downto 0)
    );
end entity dec7seg;

architecture rtl of dec7seg is
begin
    process(num)
    begin
        case num is
            when 0      => seg <= "0000001";
            when 1      => seg <= "1001111";
            when 2      => seg <= "0010010";
            when 3      => seg <= "0000110";
            when 4      => seg <= "1001100";
            when 5      => seg <= "0100100";
            when 6      => seg <= "0100000";
            when 7      => seg <= "0001111";
            when 8      => seg <= "0000000";
            when 9      => seg <= "0000100";
            when others => seg <= "1111111";
        end case;
    end process;
end architecture rtl;
