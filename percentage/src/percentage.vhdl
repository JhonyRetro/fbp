library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity Percentage is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        pulse  : in  std_logic;
        length : in  unsigned(31 downto 0);

        seg    : out std_logic_vector(6 downto 0);
        an     : out std_logic_vector(3 downto 0)
    );
end entity Percentage;

architecture RTL of Percentage is
    signal i       : unsigned(31 downto 0) := (others => '0');
    signal percent : unsigned(31 downto 0) := (others => '0');

    signal digit0  : unsigned(3 downto 0) := (others => '0');
    signal digit1  : unsigned(3 downto 0) := (others => '0');

    signal refresh : unsigned(3 downto 0) := (others => '0');
    signal sel     : std_logic_vector(1 downto 0) := "01";

    signal clk_div : unsigned(23 downto 0) := (others => '0');
    signal pulse_d : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                i <= (others => '0');
                percent <= (others => '0');
            else
                if length > 0 then
                    percent <= (i * 100) / length;
                else
                    percent <= (others => '0');
                end if;

                if percent > 99 then
                    percent <= to_unsigned(99, percent'length);
                end if;
            end if;
        end if;
    end process;

    digit0 <= percent(3 downto 0) mod 10;
    digit1 <= (percent / 10)(3 downto 0);

    process(clk)
    begin
        if rising_edge(clk) then
            refresh <= refresh + 1;
        end if;
    end process;

    sel <= refresh(16 downto 15);

    function decode_seg(digit : unsigned(3 downto 0)) return std_logic_vector is
    begin
        case to_integer(digit) is
            when 0 => return "0000001";
            when 1 => return "1001111";
            when 2 => return "0010010";
            when 3 => return "0000110";
            when 4 => return "1001100";
            when 5 => return "0100100";
            when 6 => return "0100000";
            when 7 => return "0001111";
            when 8 => return "0000000";
            when 9 => return "0000100";
        end case;
    end function;

    process(sel, digit0, digit1)
    begin
        case sel is
            when "00" =>
                an  <= "1111";
                seg <= "1111111";
            when "01" =>
                an  <= "1101";
                seg <= decode_seg(digit0);
            when "10" =>
                an  <= "1011";
                seg <= decode_seg(digit1);
            when "11" =>
                an  <= "1111";
                seg <= "1111111";
        end case;
    end process;
end architecture RTL;
