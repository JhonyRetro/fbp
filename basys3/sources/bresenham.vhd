library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity bresenham is
    generic (
        delay_max    : integer := 150000; -- 1ms
        delay_min    : integer := 40000;
        delay_pen_up : integer := 15000;
        ramp_steps   : integer := 80
    ); 
    port (
        clk          : in  std_logic;
        packet_ready : in  std_logic;

        dx_in        : in  std_logic_vector(15 downto 0);
        dy_in        : in  std_logic_vector(15 downto 0);
        dir_x_in     : in  std_logic;
        dir_y_in     : in  std_logic;
        pen_state    : in  std_logic;

        step_x       : out std_logic := '0';
        dir_x        : out std_logic := '0';
        step_y       : out std_logic := '0';
        dir_y        : out std_logic := '0';

        busy         : out std_logic := '0'
    );
end bresenham;

architecture rtl of bresenham is

    type state_type is (IDLE, SETUP, STEP_HIGH, STEP_LOW, WAIT_DELAY, WAIT_SERVO);
    constant servo_delay  : integer := 15000000;
    signal state : state_type := IDLE;

    signal dx_reg, dy_reg : unsigned(15 downto 0) := (others => '0');
    signal delay_reg      : std_logic_vector(15 downto 0) := (others => '0');
    signal steps_major    : unsigned(15 downto 0) := (others => '0');
    signal steps_minor    : unsigned(15 downto 0) := (others => '0');

    signal acc : unsigned(16 downto 0) := (others => '0');

    signal step_count  : unsigned(15 downto 0) := (others => '0');
    signal delay_count : integer := 0;

    signal x_is_major  : boolean := true;
    
    signal delay_counter  : integer := 0;
    signal current_delay  : integer := delay_max;
    
    constant delay_step_change: integer := (delay_max - delay_min) / ramp_steps;

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
                        dir_x  <= dir_x_in;
                        dir_y  <= dir_y_in;
                        busy   <= '1';
                        state  <= SETUP;
                    end if;

                when SETUP =>
                    step_count  <= (others => '0');
                    delay_count <= 0;
                    current_delay <= delay_max;

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
                        state <= WAIT_SERVO;
                        delay_counter <= 0;
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
                    
                    if step_count < ramp_steps then
                        if current_delay > delay_min then
                            current_delay <= current_delay - DELAY_STEP_CHANGE;
                        end if;

                    elsif (steps_major - step_count) < RAMP_STEPS then
                        if current_delay < delay_max then
                            current_delay <= current_delay + DELAY_STEP_CHANGE;
                        end if;
                    
                    else
                        if pen_state = '0' then
                            current_delay <= delay_min;
                        else  
                            current_delay <= delay_pen_up;
                        end if;
                    end if;

                    delay_counter <= 0;
                    
                    if step_count = steps_major then
                        state <= IDLE;
                    else
                        state <= WAIT_DELAY;
                    end if;

                when WAIT_DELAY =>
                    if delay_counter < current_delay then
                        delay_counter <= delay_counter + 1;
                    else
                        state <= STEP_HIGH;
                    end if;
                    
                when WAIT_SERVO =>
                    if delay_counter < servo_delay then
                        delay_counter <= delay_counter + 1;
                    else
                        state <= IDLE;
                    end if;

            end case;
        end if;
    end process;

end rtl;