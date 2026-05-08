library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    generic (
        -- 100 MHz clk / 115200 baud = 868
        cycles_per_bit : integer := 868 
    );
    port (
        clk          : in  std_logic;
        rx           : in  std_logic; 
        rx_data      : out std_logic_vector(7 downto 0) := (others => '0'); 
        rx_done_tick : out std_logic := '0'
    );
end uart_rx;

architecture rtl of uart_rx is

    type state_t is (IDLE, RX_START_BIT, RX_DATA_BITS, RX_STOP_BIT, CLEANUP);
    signal state : state_t := IDLE;

    signal clk_count : integer range 0 to cycles_per_bit-1 := 0;
    signal bit_index : integer range 0 to 7 := 0;
    signal rx_data_reg : std_logic_vector(7 downto 0) := (others => '0');

begin
    process(clk)
    begin
        if rising_edge(clk) then
            rx_done_tick <= '0';

            case state is
                when IDLE =>
                    clk_count <= 0;
                    bit_index <= 0;
                    if rx = '0' then
                        state <= RX_START_BIT;
                    end if;

                when RX_START_BIT =>
                    if clk_count = (cycles_per_bit-1)/2 then
                        if rx = '0' then
                            clk_count <= 0;
                            state <= RX_DATA_BITS;
                        else
                            state <= IDLE;
                        end if;
                    else
                        clk_count <= clk_count + 1;
                    end if;

                when RX_DATA_BITS =>
                    if clk_count = cycles_per_bit-1 then
                        clk_count <= 0;
                        rx_data_reg(bit_index) <= rx;
                        
                        if bit_index < 7 then
                            bit_index <= bit_index + 1;
                        else
                            bit_index <= 0;
                            state <= RX_STOP_BIT;
                        end if;
                    else
                        clk_count <= clk_count + 1;
                    end if;

                when RX_STOP_BIT =>
                    if clk_count = cycles_per_bit-1 then
                        rx_data <= rx_data_reg; 
                        rx_done_tick <= '1';    
                        state <= CLEANUP;
                    else
                        clk_count <= clk_count + 1;
                    end if;

                when CLEANUP =>
                    state <= IDLE;
                    
                when others =>
                    state <= IDLE;
                    
            end case;
        end if;
    end process;
end rtl;