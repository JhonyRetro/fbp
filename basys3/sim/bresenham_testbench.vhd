library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bresenham_tb is
end bresenham_tb;

architecture sim of bresenham_tb is

    component bresenham is
        port (
            clk          : in  std_logic;
            packet_ready : in  std_logic;
            dx_in        : in  std_logic_vector(15 downto 0);
            dy_in        : in  std_logic_vector(15 downto 0);
            delay_in     : in  std_logic_vector(15 downto 0);
            dir_x_in     : in  std_logic;
            dir_y_in     : in  std_logic;
            step_x       : out std_logic;
            dir_x        : out std_logic;
            step_y       : out std_logic;
            dir_y        : out std_logic;
            busy         : out std_logic
        );
    end component;

    signal clk_tb          : std_logic := '0';
    signal packet_ready_tb : std_logic := '0';
    signal dx_in_tb        : std_logic_vector(15 downto 0) := (others => '0');
    signal dy_in_tb        : std_logic_vector(15 downto 0) := (others => '0');
    signal delay_in_tb     : std_logic_vector(15 downto 0) := (others => '0');
    signal dir_x_in_tb     : std_logic := '0';
    signal dir_y_in_tb     : std_logic := '0';

    signal step_x_tb       : std_logic;
    signal dir_x_tb        : std_logic;
    signal step_y_tb       : std_logic;
    signal dir_y_tb        : std_logic;
    signal busy_tb         : std_logic;

    constant CLK_PERIOD : time := 10 ns;

begin

    UUT: bresenham
        port map (
        clk          => clk_tb,
        packet_ready => packet_ready_tb,
        dx_in        => dx_in_tb,
        dy_in        => dy_in_tb,
        delay_in     => delay_in_tb,
        dir_x_in     => dir_x_in_tb,
        dir_y_in     => dir_y_in_tb,
        step_x       => step_x_tb,
        dir_x        => dir_x_tb,
        step_y       => step_y_tb,
        dir_y        => dir_y_tb,
        busy         => busy_tb
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
        wait for 50 ns;

        dx_in_tb    <= x"0005";
        dy_in_tb    <= x"0002";
        delay_in_tb <= x"1111";
        dir_x_in_tb <= '1';
        dir_y_in_tb <= '0';

        packet_ready_tb <= '1';
        wait for CLK_PERIOD;
        packet_ready_tb <= '0';

        wait until busy_tb = '0';

        wait for 100 ns;

    end process;

end sim;