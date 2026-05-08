library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx_tb is
end uart_rx_tb;

architecture sim of uart_rx_tb is

    component uart_rx is
        generic ( cycles_per_bit : integer := 868 );
        port (
            clk          : in  std_logic;
            rx           : in  std_logic;
            rx_data      : out std_logic_vector(7 downto 0);
            rx_done_tick : out std_logic
        );
    end component;

    signal clk_tb          : std_logic := '0';
    signal rx_tb           : std_logic := '1';
    signal rx_data_tb      : std_logic_vector(7 downto 0);
    signal rx_done_tick_tb : std_logic;

    constant CLK_PERIOD : time := 10 ns;     -- 100 MHz
    constant BIT_PERIOD : time := 8680 ns;   -- 1/115200 bauds = ~8.68 us

begin
    UUT: uart_rx 
        port map (
            clk          => clk_tb,
            rx           => rx_tb,
            rx_data      => rx_data_tb,
            rx_done_tick => rx_done_tick_tb
        );

    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD/2;
        clk_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_process : process
        procedure send_byte(data : std_logic_vector(7 downto 0)) is
        begin
            rx_tb <= '0';
            wait for BIT_PERIOD;
            
            for i in 0 to 7 loop
                rx_tb <= data(i);
                wait for BIT_PERIOD;
            end loop;
            
            rx_tb <= '1';
            wait for BIT_PERIOD;
        end procedure;

    begin
        wait for 10 us;

        send_byte(x"AA");
     
        wait for 20 us;

        send_byte(x"07");
        
        wait for 20 us;

        send_byte(x"11");
        
        wait for 20 us;

        send_byte(x"1D");
        
        wait for 20 us;

        send_byte(x"14");
        
        wait for 20 us;

        send_byte(x"1E");

        wait for 100 us;
    end process;

end sim;