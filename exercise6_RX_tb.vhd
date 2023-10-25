library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fifo_pkg.all;
entity exercise6_tb is
end entity;



architecture testbench of exercise6_tb is

component exercise6_RX is
	generic(
	F_CLK_KHz: natural :=50000 ;
	OVERSAMPLING: natural:=8 ;
	BAUDRATE : natural:=9600;
	WORD_LENGTH: natural:=8;
	PARITY_ON : natural := 0 ; --0 or 1
	PARITY_ODD : std_logic:='0');
    port(
        clk   : in  std_logic;
        rst_n : in  std_logic;
        rx_in : in  std_logic;
        data_out  : out std_logic_vector(WORD_LENGTH-1-PARITY_ON downto 0);
        done  : out std_logic;
		fifoBuffer: out t_fifo
    );
end component;


	signal clk   :   std_logic := '0';
	signal rst_n :   std_logic;
	signal rx_in :   std_logic:='1';
	signal data_out  :  std_logic_vector(9-2 downto 0);
	signal done  :  std_logic;
	signal fifoBuffer:  t_fifo;

begin
 i_exercise6: component exercise6_RX
    port map (
       clk => clk,  
        rst_n => rst_n,
        rx_in  => rx_in,
        data_out  => data_out,
        done  => done,
		fifoBuffer => fifoBuffer
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