library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
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
end uart_tx;

architecture rtl of uart_tx is

    type state_type is (IDLE, TX_START_BIT, TX_DATA_BITS, TX_STOP_BIT);
    signal state : state_type := IDLE;

    signal clk_count : integer range 0 to (cycles_per_bit - 1) := 0;
    signal bit_index : integer range 0 to 7 := 0;
    signal tx_data_reg : std_logic_vector(7 downto 0) := (others => '0');

begin

    process(clk)
    begin
        if rising_edge(clk) then
            case state is
                when IDLE =>
                    tx_out    <= '1';
                    tx_active <= '0';
                    clk_count <= 0;
                    bit_index <= 0;

                    if tx_start = '1' then
                        tx_data_reg <= tx_data;
                        state <= TX_START_BIT;
                    end if;
                    
                when TX_START_BIT =>
                    tx_active <= '1';
                    tx_out    <= '0';
                    if clk_count < cycles_per_bit - 1 then
                        clk_count <= clk_count + 1;
                    else
                        clk_count <= 0;
                        state     <= TX_DATA_BITS;
                    end if;
                    
                when TX_DATA_BITS =>
                    tx_out <= tx_data_reg(bit_index);
                    if clk_count < cycles_per_bit - 1 then
                        clk_count <= clk_count + 1;
                    else
                        clk_count <= 0;
                        if bit_index < 7 then
                            bit_index <= bit_index + 1;
                        else
                            bit_index <= 0;
                            state     <= TX_STOP_BIT;
                        end if;
                    end if;
                    
                when TX_STOP_BIT =>
                    tx_out <= '1';
                    if clk_count < cycles_per_bit - 1 then
                        clk_count <= clk_count + 1;
                    else
                        clk_count <= 0;
                        state     <= IDLE;
                    end if;
                    
            end case;
        end if;
    end process;

end rtl;