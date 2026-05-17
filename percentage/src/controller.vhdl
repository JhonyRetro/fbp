library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port (
        clk    : in  std_logic;
        length : in  integer;
        i      : in  integer;
        seg    : out std_logic_vector(6 downto 0);
        an     : out std_logic_vector(3 downto 0)
    );
end entity controller;

architecture rtl of controller is
    component percentage
        port (
            length : in  integer;
            i      : in  integer;
            result : out integer
        );
    end component percentage;

    component dec7seg
        port (
            num : in  integer;
            seg : out std_logic_vector(6 downto 0)
        );
    end component dec7seg;

    signal percent : integer := 0;
begin
    module1 : percentage
        port map (
            length => length,
            i      => i,
            result => percent
        );

    module2 : dec7seg
        port map (
            num => percent,
            seg => seg
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if percent > 10 then
                an <= "1011";
            else
                an <= "1101";
            end if;
        end if;
    end process;
end architecture rtl;
