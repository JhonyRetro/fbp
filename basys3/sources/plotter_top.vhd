library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity plotter_top is
    port (
        clk       : in  std_logic;
        rx        : in  std_logic;
        
        sw_enable_x   : in  std_logic; -- sw[0]
        sw_enable_y   : in  std_logic; -- sw[1]
        limit_x   : in  std_logic; -- Pmod JB1
        limit_y   : in  std_logic; -- Pmod JB2
        
        step_x    : out std_logic; -- Pmod JA1
        dir_x     : out std_logic; -- Pmod JA2
        en_x_out  : out std_logic; -- Pmod JB3
        step_y    : out std_logic; -- Pmod JA3
        dir_y     : out std_logic; -- Pmod JA4
        en_y_out  : out std_logic; -- Pmod JB4
        
        servo_pwm : out std_logic; -- Pmod JB7
        led_done  : out std_logic  -- led[15]
    );
end plotter_top;

architecture structural of plotter_top is

    component uart_rx is
        generic ( cycles_per_bit : integer := 868 );
        port (
            clk          : in  std_logic;
            rx           : in  std_logic;
            rx_data      : out std_logic_vector(7 downto 0);
            rx_done_tick : out std_logic
        );
    end component;

    component packet_parser is
        port (
            clk          : in  std_logic;
            rx_data      : in  std_logic_vector(7 downto 0);
            rx_done_tick : in  std_logic;
            dx_steps     : out std_logic_vector(15 downto 0);
            dy_steps     : out std_logic_vector(15 downto 0);
            delay_out    : out std_logic_vector(15 downto 0);
            dir_x        : out std_logic;
            dir_y        : out std_logic;
            pen_down     : out std_logic;
            plot_end     : out std_logic;
            packet_ready : out std_logic
        );
    end component;

    component bresenham is
        port (
            clk          : in  std_logic;
            packet_ready : in  std_logic;
            dx_in        : in  std_logic_vector(15 downto 0);
            dy_in        : in  std_logic_vector(15 downto 0);
            delay_in     : in std_logic_vector(15 downto 0);
            dir_x_in     : in  std_logic;
            dir_y_in     : in  std_logic;
            step_x       : out std_logic;
            dir_x        : out std_logic;
            step_y       : out std_logic;
            dir_y        : out std_logic;
            busy         : out std_logic
        );
    end component;

    -- UART a Parser
    signal uart_data_w : std_logic_vector(7 downto 0);
    signal uart_tick_w : std_logic;
    
    -- Parser a Bresenham
    signal packet_rdy_w : std_logic;
    signal dx_w, dy_w   : std_logic_vector(15 downto 0);
    signal delay_w      : std_logic_vector(15 downto 0);
    signal dir_x_w      : std_logic;
    signal dir_y_w      : std_logic;
    signal pen_down_w   : std_logic;
    signal bres_busy_w  : std_logic;
    
    signal plot_end_w   : std_logic;

    signal pwm_counter  : integer range 0 to 2000000 := 0; -- 20ms a 100MHz
    signal pwm_high_time: integer := 100000; -- Por defecto 

begin

    en_x_out <= sw_enable_x; 
    en_y_out <= sw_enable_y;

    led_done <= plot_end_w;
    
    inst_uart: uart_rx
        generic map ( cycles_per_bit => 868 )
        port map (
            clk          => clk,
            rx           => rx,
            rx_data      => uart_data_w,
            rx_done_tick => uart_tick_w
        );

    inst_parser: packet_parser
        port map (
            clk          => clk,
            rx_data      => uart_data_w,
            rx_done_tick => uart_tick_w,
            dx_steps     => dx_w,
            dy_steps     => dy_w,
            delay_out    => delay_w,
            dir_x        => dir_x_w,
            dir_y        => dir_y_w,
            pen_down     => pen_down_w,
            plot_end     => plot_end_w,
            packet_ready => packet_rdy_w
        );

    inst_bresenham: bresenham
        port map (
            clk          => clk,
            packet_ready => packet_rdy_w,
            dx_in        => dx_w,
            dy_in        => dy_w,
            delay_in     => delay_w,
            dir_x_in     => dir_x_w,
            dir_y_in     => dir_y_w,
            step_x       => step_x,   
            dir_x        => dir_x,    
            step_y       => step_y,   
            dir_y        => dir_y,    
            busy         => bres_busy_w
        );
    
    process(clk)
    begin
        if rising_edge(clk) then
            if pen_down_w = '1' then
                pwm_high_time <= 200000;
            else
                pwm_high_time <= 100000;
            end if;
            
            if pwm_counter < 1999999 then
                pwm_counter <= pwm_counter + 1;
            else
                pwm_counter <= 0;
            end if;

            if pwm_counter < pwm_high_time then
                servo_pwm <= '1';
            else
                servo_pwm <= '0';
            end if;
        end if;
    end process;

end structural;