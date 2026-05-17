library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity TestBench is
end entity TestBench;

architecture Test of TestBench is
    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';
    signal pulse        : std_logic := '0';
    signal file_length  : unsigned(31 downto 0) := to_unsigned(20, 32);

    signal seg          : std_logic_vector(6 downto 0);
    signal an           : std_logic_vector(3 downto 0);

    constant clk_period : time := 10 ns;
begin
    uut: entity work.file_progress_display
        port map (
            clk         => clk,
            reset       => reset,
            pulse       => pulse,
            file_length => file_length,
            seg         => seg,
            an          => an
        );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    stim_proc : process
    begin
        reset <= '1';
        wait for 100 ns;
        reset <= '0';

        for k in 0 to 20 loop
            pulse <= '1';
            wait for clk_period;
            pulse <= '0';

            wait for 50 ns;
        end loop;

        wait for 1 us;
        assert false report "Simulation finished" severity failure;
    end process;
end architecture Test;
