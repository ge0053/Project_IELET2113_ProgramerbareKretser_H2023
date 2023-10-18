library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity exercise6_tb is
end entity;



architecture testbench of exercise6_tb is

component exercise6_RX is
	generic(
	F_CLK_KHz: natural :=50000 ;
	OVERSAMPLING: natural:=8 ;
	BAUDRATE : natural:=9600 );
    port(
        clk   : in  std_logic;
        rst_n : in  std_logic;
        rx_in : in  std_logic;
        data_out  : out std_logic_vector(7 downto 0);
        done  : out std_logic
    );
end component;


	signal clk   :   std_logic := '0';
	signal rst_n :   std_logic;
	signal rx_in :   std_logic;
	signal data_out  :  std_logic_vector(7 downto 0);
	signal done  :  std_logic;

begin
 i_exercise6: component exercise6_RX
    port map (
       clk => clk,  
        rst_n => rst_n,
        rx_in  => rx_in,
        data_out  => data_out,
        done  => done
      );



-- duv : entity work.exercise6_RX
--generic map ( 3, 50_000_000,60*7)
--port map ( clk ,rst_n,rx_in,data_out,done) ; 

clk <= not clk after 10 ns;	-- inverterer hvert 10ns
process is
begin
rst_n <= '0' ;

wait for 100 ns;
rst_n <= '1' ;
wait for 2 ms;
assert false report "Testbench finished" severity failure;
	wait;
end process;


end architecture;