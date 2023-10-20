library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity exercise6_tb is
end exercise6_tb;

architecture Behavior of exercise6_tb is

    -- Constants
    constant CLK_PERIOD : time := 20 ns;
    constant clks_per_bit_constant : integer := 651;
    constant BIT_PERIOD : time := 104 ns;

    -- Signals
    signal clk           : std_logic := '0';
    signal received_byte : std_logic_vector(7 downto 0);
    signal RX_in         : std_logic := '1';
    signal rst_n         : std_logic := '0';
    signal byte_received : std_logic;

begin

    -- UART Receiver Instance
    UART_Receiver_INST : entity work.exercise6_RX
        generic map (
            F_CLK_KHz => 50000,
            OVERSAMPLING => 8,
            BAUDRATE => 9600
        )
        port map (
            clk           => clk,
            rst_n         => rst_n,
            RX_in         => RX_in,
            byte_received => byte_received,
            received_byte => received_byte
        );

    -- Clock Generator
    clk_gen : process
    begin
        wait for CLK_PERIOD/2;
        clk <= not clk;
    end process;

    -- Testbench Logic
    test_proc : process
        variable data_to_send : std_logic_vector(7 downto 0) := "01010101";
    begin
        wait for clks_per_bit_constant * CLK_PERIOD;   
        rst_n <= '0';  
        wait for clks_per_bit_constant * CLK_PERIOD;  
        rst_n <= '1';  

        RX_in <= '0';
        wait for clks_per_bit_constant * CLK_PERIOD;

        for i in 0 to 7 loop
            RX_in <= data_to_send(i);
            wait for clks_per_bit_constant * CLK_PERIOD;
        end loop;

        RX_in <= '1';
        wait until byte_received = '1';
        
        assert false report "Tests Complete" severity failure;
    end process;

end Behavior;
