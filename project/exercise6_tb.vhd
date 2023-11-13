library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fifo_pkg.all;  -- including your fifo_pkg
use work.seven_segment_pkg.all;  -- including your seven_segment_pkg

entity exercise6_tb is
end exercise6_tb;

architecture Behavior of exercise6_tb is

    -- Constants
    constant CLK_PERIOD : time := 20 ns;
    constant BIT_PERIOD : time := 104.167 us;  -- Corrected Bit Period

    -- Signals
    signal clk              : std_logic := '0';
    signal data_out         : std_logic;  -- Initialize to all zeros
    signal RX_in            : std_logic := '1';
    signal rst_n            : std_logic := '1';
    signal done             : std_logic;
    signal fifoBuffer_signal : t_fifo;  -- FIFO Buffer signal
	
    
    -- 7-segment display signals
    signal svnSegment        : t_6_svn_disp;
    
    -- Signal for data to send
    signal data_to_send      : std_logic_vector(7 downto 0) := "00000000"; -- Initialize to all zeros
	signal signalOut :  std_logic ;  -- for testing
	signal lock_tx: std_logic;
begin

    -- UART Receiver Instance
    UART_Receiver_INST : entity work.project1
        generic map (
            F_CLK_KHz => 50000,
            OVERSAMPLING => 8,
            BAUDRATE => 9600,
            DATA_LENGTH => 8,
            PARITY_ON => 0,
            PARITY_ODD => '0'
            --FIFO_LENGTH => 16 
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            rx_in => RX_in,
			lock_tx => lock_tx,
            svnSegment => svnSegment,
			rx_done => done,
			tx_data => data_out,
			signalOut => signalOut --for testing
            --fifoBuffer => fifoBuffer_signal  -- Mapping FIFO Buffer
        );

    -- Clock Generator
    clk_gen : process
    begin
        wait for CLK_PERIOD/2;
        clk <= not clk;
    end process;

    -- Testbench Logic
    test_proc : process
    begin
	wait for 1 ms;
        for i in 0 to 255 loop
            data_to_send <= std_logic_vector(to_unsigned(i, 8));
 /*           
            wait for BIT_PERIOD;   
            rst_n <= '0';  
            wait for BIT_PERIOD;  
            rst_n <= '1';  
*/
            RX_in <= '0';
            wait for BIT_PERIOD;

            for j in 0 to 7 loop
                RX_in <= data_to_send(j);
                wait for BIT_PERIOD;
            end loop;
            
            RX_in <= '1';
            
            wait for 2*BIT_PERIOD;
            
            -- if fifoBuffer_signal.empty = '0' then
                -- report "FIFO has data.";
            -- else
                -- report "FIFO is empty.";
            -- end if;
            
            -- svnSegment(0) <= vecTo_svnSegmentHex(data_out(3 downto 0));
            -- svnSegment(1) <= vecTo_svnSegmentHex(data_out(7 downto 4));
            -- svnSegment(2) <= vecTo_svnSegmentAscii(data_out);
            
            
            -- Increment data_out for the next iteration
            -- data_out <= std_logic_vector(unsigned(data_out) + 1);
        end loop;
        
        assert false report "Tests Complete" severity failure;
    end process;

end Behavior;
