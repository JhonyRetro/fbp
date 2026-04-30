library IEEE;
use IEEE.std_logic_1164.all;

library work;

entity lut is
    port(
        ent1 : in std_logic;
        ent2 : in std_logic;
        S : out std_logic
    );
end entity lut;


architecture behavior of lut is
signal clk : std_logic;
signal helper : std_logic_vector(30 downto 0);
begin
    D_ff : entity work.D_ff
                port map(
                    clk => clk,
                    enable => helper(8),
                    ent => helper(9),
                    cl => helper(10),
                    pr => helper(11),
                    q => helper(12),
                    n_q => helper(13)
                 );
    
end architecture behavior;