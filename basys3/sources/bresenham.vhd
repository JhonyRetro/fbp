library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity bresenham is
    port (
        clk          : in  std_logic;
        packet_ready : in  std_logic;

        dx_in        : in  std_logic_vector(15 downto 0);
        dy_in        : in  std_logic_vector(15 downto 0);
        delay_in     : in  std_logic_vector(15 downto 0);
        dir_x_in     : in  std_logic;
        dir_y_in     : in  std_logic;

        step_x       : out std_logic := '0';
        dir_x        : out std_logic := '0';
        step_y       : out std_logic := '0';
        dir_y        : out std_logic := '0';

        busy         : out std_logic := '0'
    );
end bresenham;

architecture rtl of bresenham is

    type state_type is (IDLE, SETUP, STEP_HIGH, STEP_LOW, WAIT_DELAY);
    signal state : state_type := IDLE;

    signal dx_reg, dy_reg : unsigned(15 downto 0) := (others => '0');
    signal delay_reg      : std_logic_vector(15 downto 0) := (others => '0');
    signal steps_major    : unsigned(15 downto 0) := (others => '0');
    signal steps_minor    : unsigned(15 downto 0) := (others => '0');

    signal acc : unsigned(16 downto 0) := (others => '0');

    signal step_count  : unsigned(15 downto 0) := (others => '0');
    signal delay_count : integer := 0;

    signal x_is_major  : boolean := true;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            case state is
                when IDLE =>
                    busy <= '0';
                    step_x <= '0';
                    step_y <= '0';

                    if packet_ready = '1' then
                        dx_reg <= unsigned(dx_in);
                        dy_reg <= unsigned(dy_in);
                        delay_reg <= delay_in;
                        dir_x  <= dir_x_in;
                        dir_y  <= dir_y_in;
                        busy   <= '1';
                        state  <= SETUP;
                    end if;

                when SETUP =>
                    step_count  <= (others => '0');
                    delay_count <= 0;

                    if dx_reg >= dy_reg then
                        x_is_major  <= true;
                        steps_major <= dx_reg;
                        steps_minor <= dy_reg;
                        acc <= resize(dx_reg(15 downto 1), 17);
                    else
                        x_is_major  <= false;
                        steps_major <= dy_reg;
                        steps_minor <= dx_reg;
                        acc <= resize(dy_reg(15 downto 1), 17);
                    end if;

                    if dx_reg = 0 and dy_reg = 0 then
                        state <= IDLE;
                    else
                        state <= STEP_HIGH;
                    end if;

                when STEP_HIGH =>
                    if x_is_major then
                        step_x <= '1'; else
                        step_y <= '1'; end if;

                    if (acc + steps_minor) >= steps_major then
                        if x_is_major then
                            step_y <= '1'; else
                            step_x <= '1'; end if;
                    end if;

                    state <= STEP_LOW;

                when STEP_LOW =>
                    step_x <= '0';
                    step_y <= '0';

                    if (acc + steps_minor) >= steps_major then
                        acc <= acc + steps_minor - steps_major;
                    else
                        acc <= acc + steps_minor;
                    end if;

                    step_count <= step_count + 1;
                    state <= WAIT_DELAY;

                when WAIT_DELAY =>
                    if delay_count = to_integer(unsigned(delay_reg & "000")) then
                        delay_count <= 0;

                        if step_count = steps_major then
                            state <= IDLE;
                        else
                            state <= STEP_HIGH;
                        end if;
                    else
                        delay_count <= delay_count + 1;
                    end if;

            end case;
        end if;
    end process;

end rtl;