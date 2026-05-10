library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx_tb is
end uart_tx_tb;

architecture sim of uart_tx_tb is
    component uart_tx is
        generic (
            cycles_per_bit : integer := 868
        );
        port (
            clk       : in  std_logic;
            tx_start  : in  std_logic;
            tx_data   : in  std_logic_vector(7 downto 0);
            tx_active : out std_logic;
            tx_out    : out std_logic
        );
    end component;

    signal clk_tb       : std_logic := '0';
    signal tx_start_tb  : std_logic := '0';
    signal tx_data_tb   : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_active_tb : std_logic;
    signal tx_out_tb    : std_logic;

    constant CLK_PERIOD : time := 10 ns;

begin
    UUT: uart_tx
        generic map (
        cycles_per_bit => 868
        )
        port map (
        clk       => clk_tb,
        tx_start  => tx_start_tb,
        tx_data   => tx_data_tb,
        tx_active => tx_active_tb,
        tx_out    => tx_out_tb
        );

    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD/2;
        clk_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
    begin
        wait for 100 ns;

        tx_data_tb  <= x"4F";
        wait for CLK_PERIOD;

        tx_start_tb <= '1';
        wait for CLK_PERIOD;
        tx_start_tb <= '0';

        wait until tx_active_tb = '0';

        wait for 20 us;

        tx_data_tb  <= x"4B";
        wait for CLK_PERIOD;

        tx_start_tb <= '1';
        wait for CLK_PERIOD;
        tx_start_tb <= '0';

        wait until tx_active_tb = '0';
        wait for 20 us;

    end process;

end sim;