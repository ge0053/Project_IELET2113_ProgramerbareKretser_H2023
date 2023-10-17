library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exercise6_RX is
    port(
        clk   : in  std_logic;
        rst_n : in  std_logic;
        rx_in : in  std_logic;
        data_out  : out std_logic_vector(7 downto 0);
        done  : out std_logic
    );
end exercise6_RX;

architecture RTL of exercise6_RX is
    type state_type is (IDLE, START, DATA, STOP);
    signal current_state, next_state : state_type;
    signal bit_counter : integer range 0 to 7 := 0;
    signal sample_counter : integer range 0 to 7 := 0;
    signal data_tmp : std_logic_vector(7 downto 0) := (others => '0');
begin

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    process(current_state, rx_in, data_tmp, bit_counter, sample_counter)
    begin
        done <= '0';
        next_state <= current_state;  -- Default

        case current_state is
            when IDLE =>
                if rx_in = '0' then
                    next_state <= START;
                    sample_counter <= 0;
                end if;
                
            when START =>
                if sample_counter = 3 then
                    if rx_in = '0' then
                        next_state <= DATA;
                        sample_counter <= 0;
                    else
                        next_state <= IDLE;
                    end if;
                else
                    sample_counter <= sample_counter + 1;
                end if;

            when DATA =>
                if sample_counter = 3 then
                    data_tmp(bit_counter) <= rx_in;
                    if bit_counter = 7 then
                        next_state <= STOP;
                        bit_counter <= 0;
                    else
                        bit_counter <= bit_counter + 1;
                    end if;
                    sample_counter <= 0;
                else
                    sample_counter <= sample_counter + 1;
                end if;

            when STOP =>
                if sample_counter = 3 then
                    if rx_in = '1' then
                        data_out <= data_tmp;
                        done <= '1';
                        next_state <= IDLE;
                    else
                        next_state <= IDLE;
                    end if;
                    sample_counter <= 0;
                else
                    sample_counter <= sample_counter + 1;
                end if;
        end case;
    end process;
end architecture;
