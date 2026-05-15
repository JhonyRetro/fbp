library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity plotter_top_tb is
end plotter_top_tb;

architecture sim of plotter_top_tb is

    component plotter_top is
        port (
            clk           : in  std_logic;
            rx            : in  std_logic;
            sw_enable_x   : in  std_logic;
            sw_enable_y   : in  std_logic;
            step_x        : out std_logic;
            dir_x         : out std_logic;
            en_x_out      : out std_logic;
            step_y        : out std_logic;
            dir_y         : out std_logic;
            en_y_out      : out std_logic;
            servo_pwm     : out std_logic;
            led_done      : out std_logic;
            tx            : out std_logic
        );
    end component;

    signal clk_tb       : std_logic := '0';
    signal rx_tb        : std_logic := '1';
    signal sw_en_x_tb   : std_logic := '0';
    signal sw_en_y_tb   : std_logic := '0';

    signal step_x_tb    : std_logic;
    signal dir_x_tb     : std_logic;
    signal en_x_out_tb  : std_logic;
    signal step_y_tb    : std_logic;
    signal dir_y_tb     : std_logic;
    signal en_y_out_tb  : std_logic;
    signal servo_pwm_tb : std_logic;
    signal led_done_tb  : std_logic;
    signal tx_tb        : std_logic;

    constant CLK_PERIOD : time := 10 ns;
    constant BIT_PERIOD : time := 8680 ns; -- 1 / 115200 baud = ~8.68 us

    procedure send_uart_byte (
        constant data_in : in std_logic_vector(7 downto 0);
        signal tx_line   : out std_logic
    ) is
    begin
        tx_line <= '0';
        wait for BIT_PERIOD;
        for i in 0 to 7 loop
            tx_line <= data_in(i);
            wait for BIT_PERIOD;
        end loop;
        tx_line <= '1';
        wait for BIT_PERIOD;
    end procedure;

    procedure send_packet (
        constant ctrl  : in std_logic_vector(7 downto 0);
        constant x_val : in integer;
        constant y_val : in integer;
        signal tx_line : out std_logic
    ) is
        variable x_vec : std_logic_vector(15 downto 0);
        variable y_vec : std_logic_vector(15 downto 0);
    begin
        x_vec := std_logic_vector(to_unsigned(x_val, 16));
        y_vec := std_logic_vector(to_unsigned(y_val, 16));

        send_uart_byte(x"AA", tx_line);           -- 0. Sync
        send_uart_byte(ctrl, tx_line);            -- 1. Control
        send_uart_byte(x_vec(15 downto 8), tx_line); -- 2. X_High
        send_uart_byte(x_vec(7 downto 0), tx_line);  -- 3. X_Low
        send_uart_byte(y_vec(15 downto 8), tx_line); -- 4. Y_High
        send_uart_byte(y_vec(7 downto 0), tx_line);  -- 5. Y_Low
    end procedure;

    procedure wait_for_uart_byte (
        signal tx_line : in std_logic
    ) is
    begin
        wait until falling_edge(tx_line);
        wait for BIT_PERIOD * 10;
    end procedure;

begin

    UUT: plotter_top
        port map (
        clk       => clk_tb,
        rx        => rx_tb,
        sw_enable_x   => sw_en_x_tb,
        sw_enable_y   => sw_en_y_tb,
        step_x    => step_x_tb,
        dir_x     => dir_x_tb,
        en_x_out  => en_x_out_tb,
        step_y    => step_y_tb,
        dir_y     => dir_y_tb,
        en_y_out  => en_y_out_tb,
        servo_pwm => servo_pwm_tb,
        led_done  => led_done_tb,
        tx        => tx_tb
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
        wait for 100 us;

        -- PAQUETE 1: Mover 30 pasos en ambos ejes
        -- Dir_X=1, Dir_Y=1, Pen=0, End=0 -> Control = "00000011" (0x03)
        -- Delay = 4 (Para simulación rápida)
        send_packet(x"07", 240, 240, rx_tb);
        wait_for_uart_byte(tx_tb);
        wait for 20 us;

        -- PAQUETE 2: Bajar Lápiz (Movimiento 0)
        -- Dir_X=1, Dir_Y=1, Pen=1, End=0 -> Control = "00000111" (0x07)
        send_packet(x"07", 0, 0, rx_tb);
        wait_for_uart_byte(tx_tb);
        wait for 20 us;

        -- PAQUETE 3: Subir Lápiz (Movimiento 0)
        -- Dir_X=1, Dir_Y=1, Pen=0, End=0 -> Control = "00000011" (0x03)
        send_packet(x"03", 0, 0, rx_tb);
        wait_for_uart_byte(tx_tb);
        wait for 20 us;

        -- PAQUETE 4: Mover 10 pasos hacia atrás en X (X=-10, Y=0)
        -- Dir_X=0, Dir_Y=1, Pen=0, End=0 -> Control = "00000010" (0x02)
        send_packet(x"02", 80, 0, rx_tb);
        wait_for_uart_byte(tx_tb);
        wait for 20 us;

        -- PAQUETE 5: Mover 10 pasos hacia atrás en Y (X=0, Y=-10)
        -- Dir_X=1, Dir_Y=0, Pen=0, End=0 -> Control = "00000001" (0x01)
        send_packet(x"01", 0, 80, rx_tb);
        wait_for_uart_byte(tx_tb);
        wait for 20 us;

        -- PAQUETE 6: Fin de Trabajo
        -- Dir_X=1, Dir_Y=1, Pen=0, End=1 -> Control = "00001011" (0x0B)
        send_packet(x"0B", 0, 0, rx_tb);
        wait_for_uart_byte(tx_tb);

        wait for 500 us;
    end process;

end sim;