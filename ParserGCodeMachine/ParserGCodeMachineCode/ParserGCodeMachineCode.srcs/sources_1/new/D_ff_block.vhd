library IEEE;
use IEEE.std_logic_1164.all;

library work;

entity D_ff_block is
    port (
        clk : in std_logic;
        E : in std_logic;
        cl_all : in std_logic;
        pr_all : in std_logic;
        S : out std_logic_vector(7 downto 0);
        nS : out std_logic_vector(7 downto 0)
    );
end entity D_ff_block;

architecture behavior of D_ff_block is
signal helper : std_logic_vector(30 downto 0);
signal mux_out : std_logic_vector(7 downto 0);
begin
    D_ff_1 : entity work.D_ff
                port map(
                    clk => clk,
                    enable => '1',
                    ent => E,
                    cl => cl_all,
                    pr => pr_all,
                    q => helper(0),
                    n_q => nS(0)
                );
    D_ff_2 : entity work.D_ff
                port map(
                    clk => clk,
                    enable => '1',
                    ent => helper(0),
                    cl => cl_all,
                    pr => pr_all,
                    q => helper(1),
                    n_q => nS(1)
                );
    D_ff_3 : entity work.D_ff
                port map(
                    clk => clk,
                    enable => '1',
                    ent => helper(1),
                    cl => cl_all,
                    pr => pr_all,
                    q => helper(2),
                    n_q => nS(2)
                );
    D_ff_4 : entity work.D_ff
                port map(
                    clk => clk,
                    enable => '1',
                    ent => helper(2),
                    cl => cl_all,
                    pr => pr_all,
                    q => helper(3),
                    n_q => nS(3)
                );
    D_ff_5 : entity work.D_ff
                port map(
                    clk => clk,
                    enable => '1',
                    ent => helper(3),
                    cl => cl_all,
                    pr => pr_all,
                    q => helper(4),
                    n_q => nS(4)
                );
    D_ff_6 : entity work.D_ff
                port map(
                    clk => clk,
                    enable => '1',
                    ent => helper(4),
                    cl => cl_all,
                    pr => pr_all,
                    q => helper(5),
                    n_q => nS(5)
                );
    D_ff_7 : entity work.D_ff
                port map(
                    clk => clk,
                    enable => '1',
                    ent => helper(5),
                    cl => cl_all,
                    pr => pr_all,
                    q => helper(6),
                    n_q => nS(6)
                );
    D_ff_8 : entity work.D_ff
                port map(
                    clk => clk,
                    enable => '1',
                    ent => helper(6),
                    cl => cl_all,
                    pr => pr_all,
                    q => helper(7),
                    n_q => nS(7)
                );
end architecture behavior;