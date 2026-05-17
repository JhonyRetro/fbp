library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity packet_parser is
    port (
        clk          : in  std_logic;

        rx_data      : in  std_logic_vector(7 downto 0);
        rx_done_tick : in  std_logic;

        dx_steps     : out std_logic_vector(15 downto 0) := (others => '0');
        dy_steps     : out std_logic_vector(15 downto 0) := (others => '0');
        dir_x        : out std_logic := '0';
        dir_y        : out std_logic := '0';
        pen_down     : out std_logic := '0';
        plot_end     : out std_logic := '0';
        packet_ready : out std_logic := '0'
    );
end packet_parser;

architecture rtl of packet_parser is

    type state_type is (WAIT_SYNC, READ_CTRL, READ_X_H, READ_X_L, READ_Y_H, READ_Y_L);
    signal state : state_type := WAIT_SYNC;

    signal ctrl_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal x_h_reg  : std_logic_vector(7 downto 0) := (others => '0');
    signal x_l_reg  : std_logic_vector(7 downto 0) := (others => '0');
    signal y_h_reg  : std_logic_vector(7 downto 0) := (others => '0');
    
begin

    process(clk)
    begin
        if rising_edge(clk) then
            packet_ready <= '0';

            if rx_done_tick = '1' then

                case state is
                    when WAIT_SYNC =>
                        if rx_data = x"AA" then
                            state <= READ_CTRL;
                        end if;

                    when READ_CTRL =>
                        ctrl_reg <= rx_data;
                        state <= READ_X_H;

                    when READ_X_H =>
                        x_h_reg <= rx_data;
                        state <= READ_X_L;

                    when READ_X_L =>
                        x_l_reg <= rx_data;
                        state <= READ_Y_H;

                    when READ_Y_H =>
                        y_h_reg <= rx_data;
                        state <= READ_Y_L;

                    when READ_Y_L =>
                        dir_x    <= ctrl_reg(0);
                        dir_y    <= ctrl_reg(1);
                        pen_down <= ctrl_reg(2);
                        plot_end <= ctrl_reg(3);

                        dx_steps <= x_h_reg & x_l_reg;
                        dy_steps <= y_h_reg & rx_data;
                        
                        packet_ready <= '1';

                        state <= WAIT_SYNC;

                end case;
            end if;
        end if;
    end process;
end rtl;