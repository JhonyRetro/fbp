library ieee;
use ieee.std_logic_1164.all;

entity enc7seg is
    port (
        clk : in  std_logic;
        num : in  integer;
        seg : out std_logic_vector(6 downto 0);
        an  : out std_logic_vector(3 downto 0)
    );
end entity enc7seg;

architecture rtl of enc7seg is
    function encode(d: integer) return std_logic_vector is
    begin
        case d is
            when 0      => return "0000001";
            when 1      => return "1001111";
            when 2      => return "0010010";
            when 3      => return "0000110";
            when 4      => return "1001100";
            when 5      => return "0100100";
            when 6      => return "0100000";
            when 7      => return "0001111";
            when 8      => return "0000000";
            when 9      => return "0000100";
            when others => return "1111111";
        end case;
    end function encode;

    signal lhs : integer := 0;
    signal rhs : integer := 0;
begin
    process(clk)
    begin
        if num < 0 or num > 99 then
            lhs <= 0;
            rhs <= 0;
        else
            lhs <= num / 10;
            rhs <= num mod 10;
        end if;
    end process;

    update_lhs: process(clk)
    begin
        if falling_edge(clk) then
            an  <= "1011";
            seg <= encode(lhs);
        end if;
    end process update_lhs;

    update_rhs: process(clk)
    begin
        if rising_edge(clk) then
            an  <= "1101";
            seg <= encode(rhs);
        end if;
    end process update_rhs;
end architecture rtl;
