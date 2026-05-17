library ieee;
use ieee.std_logic_1164.all;

entity bcd7seg is
    port (
        clk : in  std_logic;
        bcd : in  std_logic_vector(9 downto 0);
        seg : out std_logic_vector(6 downto 0)
    );
end entity bcd7seg;

architecture rtl of bcd7seg is
begin
    process(clk)
    begin
        case bcd is
            when "0000000001" => seg <= "1111110";
            when "000000001-" => seg <= "0110000";
            when "00000001--" => seg <= "1101101";
            when "0000001---" => seg <= "1111001";
            when "000001----" => seg <= "0110011";
            when "00001-----" => seg <= "1011011";
            when "0001------" => seg <= "1011111";
            when "001-------" => seg <= "1110000";
            when "01--------" => seg <= "1111111";
            when "1---------" => seg <= "1111011";
            when others       => seg <= "0000000";
        end case;
    end process;
end architecture rtl;
