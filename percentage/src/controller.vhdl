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
            clk    : in  std_logic;
            length : in  integer;
            i      : in  integer;
            result : out integer
        );
    end component percentage;

    component enc7seg
        port (
            clk : in  std_logic;
            num : in  integer;
            seg : out std_logic_vector(6 downto 0);
            an  : out std_logic_vector(3 downto 0)
        );
    end component enc7seg;

    signal percent : integer := 0;
begin
    module1: percentage
        port map (
            clk    => clk,
            length => length,
            i      => i,
            result => percent
        );

    module2: enc7seg
        port map (
            clk => clk,
            num => percent,
            seg => seg,
            an  => an
        );
end architecture rtl;
