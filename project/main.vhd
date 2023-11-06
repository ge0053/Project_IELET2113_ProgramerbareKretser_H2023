library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fifo_pkg.all;

use work.seven_segment_pkg.all;
-- deklarasjon

entity project1 is
--type  t_disp is array (0 to 3) of t_svn_segment;

generic (
	F_CLK_KHz: natural :=50000 ;
	OVERSAMPLING: natural:=8 ;
	BAUDRATE : natural:=9600;
	DATA_LENGTH: natural:=8;
	PARITY_ON : natural := 0 ; --0 or 1
	PARITY_ODD : std_logic:='0');

port (
        clk   : in  std_logic;
        rst_n : in  std_logic;
        rx_in : in  std_logic;
		
		svnSegment : out t_6_svn_disp;
		
		rx_done  :  out std_logic:='0';
		tx_data : out std_logic:='0';
		signalOut : out std_logic
		);



end entity;

--kode
architecture rtl1 of project1 is
	
	signal rx_data  :  std_logic_vector(7 downto 0):="00000000";
   --signal fifoBuffer : t_fifo;
	signal tx_ready: std_logic;
	signal rx_ready: std_logic;
	signal fifo_out : std_logic_vector(7 downto 0):="00000000";
	signal fifo_out_ready : std_logic;
	SIGNAL tmp_signalOut :std_logic;

begin



------------------------------------------------------------------------------	
	UART_Receiver_INST : entity work.exercise6_RX
		generic map(
			F_CLK_KHz =>F_CLK_KHz ,
			OVERSAMPLING=>OVERSAMPLING ,
			BAUDRATE =>BAUDRATE,
			DATA_LENGTH=>DATA_LENGTH,
			PARITY_ON=>PARITY_ON,
			PARITY_ODD =>PARITY_ODD
		)
		 port map (
			clk => clk,  
			rst_n => rst_n,
			rx_in  => rx_in,
			data_out => rx_data,
			done => rx_done,
			--fifoBuffer => fifoBuffer,
			data_ready=> rx_ready
    );
	

	
	
----------------------------------------------------------------------------	
	UART_transmiter : entity work.exercise6_TX
		generic map(
			F_CLK_KHz=>F_CLK_KHz ,
			BAUDRATE =>BAUDRATE,
			DATA_LENGTH=>DATA_LENGTH,
			PARITY_ON => PARITY_ON , --0 or 1
			PARITY_ODD =>PARITY_ODD
		)

		port map (
		   clk => clk,  
			rst_n => rst_n,
			send_data=>fifo_out_ready,
			data_in=> fifo_out,
			tx_out => tmp_signalOut,
			ready => tx_ready

    );

--------------------------------------------------------------------------	
	UART_fifo : entity work.fifo
		generic map(
	
			DATA_LENGTH=>DATA_LENGTH
		)
		port map(
			clk => clk,
			rst_n => rst_n,
			readDataIn=> rx_ready,
			data_in=> rx_data,
			dataOutHandled=>tx_ready ,
			data_out=> fifo_out,
			dataOutReady=> fifo_out_ready
	);
	



svnSegment(0) <= vecTo_svnSegmentHex(rx_data(3 downto 0));
svnSegment(1) <= vecTo_svnSegmentHex(rx_data(7 downto 4));
svnSegment(2) <= vecTo_svnSegmentAscii(rx_data);
svnSegment(3) <= vecTo_svnSegmentHex(fifo_out(3 downto 0));
svnSegment(4) <= vecTo_svnSegmentHex(fifo_out(7 downto 4));
--svnSegment(4) <= vecTo_svnSegmentAscii(fifo_get(fifoBuffer,2));
svnSegment(5) <=rx_ready& tx_ready & fifo_out_ready & "11111";
tx_data <=  tmp_signalOut;
signalOut <=  tmp_signalOut;


end architecture;