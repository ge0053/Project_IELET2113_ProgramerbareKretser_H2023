library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fifo_pkg.all;
use work.seven_segment_pkg.all;
entity exercise6_tb is
end entity;



architecture testbench of exercise6_tb is

component project1 is
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
		tx_data : out std_logic:='0'
		
		);
end component;


        signal clk   :   std_logic:='0';
        signal rst_n :   std_logic:='0';
        signal rx_in :   std_logic:='0';

		signal svnSegment :  t_6_svn_disp;

		signal rx_done  :   std_logic:='0';
		signal tx_data :  std_logic:='0';

begin
 i_exercise6: component project1
    port map (
       clk => clk,  
        rst_n => rst_n,
        rx_in  => rx_in,
        svnSegment  => svnSegment,
        rx_done  => rx_done,
		tx_data => tx_data
      );




clk <= not clk after 10 ns;	-- invert. aprox 50MHz
rx_in <= not rx_in after 104 us;	-- invert. aprox 9600 baudrate
process is
begin
rst_n <= '0' ;

wait for 100 ns;
rst_n <= '1' ;
wait for 20 ms;
report "Testbench finished";
std.env.stop;
	wait;
end process;


end architecture;