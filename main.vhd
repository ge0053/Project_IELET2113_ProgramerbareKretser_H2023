library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.seven_segment_pkg.all;
-- deklarasjon

entity project1 is
--type  t_disp is array (0 to 3) of t_svn_segment;

generic (
	F_CLK_KHz: natural :=50000 ;
	OVERSAMPLING: natural:=8 ;
	BAUDRATE : natural:=9600;
	WORD_LENGTH: natural:=9;
	PARITY_ON : natural := 1 ; --0 or 1
	PARITY_ODD : std_logic:='0');

port (
        clk   : in  std_logic;
        rst_n : in  std_logic;
        rx_in : in  std_logic;
		
		svnSegment : out t_6_svn_disp;
		key: in std_logic_vector(3 downto 0);
		rx_done  :  out std_logic:='0'
		);



end entity;



--kode
architecture rtl1 of project1 is
	component exercise6_RX is
	generic(
	F_CLK_KHz: natural :=F_CLK_KHz ;
	OVERSAMPLING: natural:=OVERSAMPLING ;
	BAUDRATE : natural:=BAUDRATE;
	WORD_LENGTH: natural:=WORD_LENGTH;
	PARITY_ON : natural :=PARITY_ON;
	PARITY_ODD : std_logic:=PARITY_ODD);
    port(
        clk   : in  std_logic;
        rst_n : in  std_logic;
        rx_in : in  std_logic;
        data_out  : out std_logic_vector(7 downto 0);
        done  : out std_logic
    );
	
	
	end component;
	signal rx_data  :  std_logic_vector(7 downto 0):="00000000";
    


begin

 i_exercise6: component exercise6_RX
    port map (
       clk => clk,  
        rst_n => rst_n,
        rx_in  => rx_in,
        data_out => rx_data,
        done => rx_done
      );


svnSegment(0) <= vecTo_svnSegmentHex(rx_data(3 downto 0));
svnSegment(1) <= vecTo_svnSegmentHex(rx_data(7 downto 4));
svnSegment(2) <= vecTo_svnSegmentAscii(rx_data);
svnSegment(3) <= "11111111";
svnSegment(4) <= "11111111";
svnSegment(5) <= "11111111";



end architecture;



