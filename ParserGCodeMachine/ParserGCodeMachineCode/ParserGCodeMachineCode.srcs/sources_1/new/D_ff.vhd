library IEEE;
use IEEE.std_logic_1164.all;

library work;

entity D_ff is
    port (
        clk : in std_logic;
        enable : in std_logic;
        ent : in std_logic;
        cl : in std_logic;
        pr : in std_logic;
        q : out std_logic;
        n_q : out std_logic
    );
end entity D_ff;

architecture behavior of D_ff is
signal helper : std_logic;
begin
    process(clk, pr, cl)
    begin
        if enable = '1' then
            if pr = '1' then
                q <= '1';
                n_q <= '0';
            elsif cl = '1' then
                    q <= '0';
                    n_q <= '1';
            elsif rising_edge(clk) then
                helper <= ent;
                q <= helper;
                n_q <= not helper;
            end if;
         end if;
    end process;
end architecture behavior;