library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity packet_parser_tb is
end packet_parser_tb;

architecture sim of packet_parser_tb is

    component packet_parser
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

    signal clk_tb          : std_logic := '0';
    signal rx_data_tb      : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_done_tick_tb : std_logic := '0';

    signal dx_out, dy_out  : std_logic_vector(15 downto 0);
    signal delay         : std_logic_vector(15 downto 0);
    signal dx_dir, dy_dir  : std_logic;
    signal p_down, p_end   : std_logic;
    signal p_ready         : std_logic;

    constant CLK_PERIOD : time := 10 ns;

begin

    UUT: packet_parser
        port map (
        clk          => clk_tb,
        rx_data      => rx_data_tb,
        rx_done_tick => rx_done_tick_tb,
        dx_steps     => dx_out,
        dy_steps     => dy_out,
        delay_out    => delay,
        dir_x        => dx_dir,
        dir_y        => dy_dir,
        pen_down     => p_down,
        plot_end     => p_end,
        packet_ready => p_ready
        );

    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD/2;
        clk_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
        procedure send_byte(val : in std_logic_vector(7 downto 0)) is
        begin
            rx_data_tb <= val;
            rx_done_tick_tb <= '1';
            wait for CLK_PERIOD;
            rx_done_tick_tb <= '0';
            wait for CLK_PERIOD * 5;
        end procedure;

    begin
        wait for 100 ns;

        send_byte(x"AA"); -- Sincronización
        send_byte(x"03"); -- Control (Dir X=1, Dir Y=1, Pen=0, End=0)
        send_byte(x"11"); -- X High
        send_byte(x"D3"); -- X Low  (11D3 hex = 4563 decimal)
        send_byte(x"13"); -- Y High
        send_byte(x"D1"); -- Y Low  (13D1 hex = 5073 decimal)
        send_byte(x"22"); -- Delay High
        send_byte(x"00"); -- Delay Low

        wait for 100 ns;

        send_byte(x"AA");
        send_byte(x"07");
        send_byte(x"10");
        send_byte(x"D4");
        send_byte(x"23");
        send_byte(x"51");
        send_byte(x"44");
        send_byte(x"22");

        wait for 10 ns;

        send_byte(x"32"); -- junk
        send_byte(x"FF");

    end process;
end sim;