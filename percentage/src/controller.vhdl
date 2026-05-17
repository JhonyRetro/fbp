library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port (
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
            seg : out std_logic_vector(6 downto 0);
            an  : out std_logic_vector(3 downto 0)
        );
    end component dec7seg;

    signal percent : integer := 0;
begin
    module1: percentage
        port map (
            length => length,
            i      => i,
            result => percent
        );

    module2: dec7seg
        port map (
            num => percent,
            seg => seg,
            an  => an
        );
end architecture rtl;
