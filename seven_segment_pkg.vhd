library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package seven_segment_pkg is -- same as .h-file in c
	subtype t_svn_segment is std_logic_vector(7 downto 0);
	type t_svnHex_truthTable is array (0 to 15) of std_logic_vector ( 7 downto 0);
	type t_svnAscii_truthTable is array (0 to 95) of std_logic_vector ( 7 downto 0);
	subtype t_nibble is std_logic_vector(3 downto 0);
	type  t_6_svn_disp is array (0 to 5) of t_svn_segment;
	
	function vecTo_svnSegmentHex (num: std_logic_vector (3 downto 0 ) ) return t_svn_segment ;
	function vecTo_svnSegmentAscii (num: std_logic_vector (7 downto 0 ) ) return t_svn_segment ;
		
	
end package;

package body seven_segment_pkg is -- is the function definition

	function vecTo_svnSegmentHex(num: t_nibble) return t_svn_segment is 
		constant a_segemnts : t_svnHex_truthTable := (			
		"11000000",	--0
		"11111001",	--1
		"10100100",	--2
		"10110000",	--3
		"10011001",	--4
		"10010010",	--5
		"10000010",	--6
		"11111000",	--7
		"10000000",	--8
		"10010000",	--9
		"10001000",	--A
		"10000011",	--B
		"11000110",	--C
		"10100001",	--D
		"10000110",	--E
		"10001110"	--F
		
		);
	begin

		return a_segemnts(to_integer(unsigned(num)));
	end function;
	
	function vecTo_svnSegmentAscii (num: std_logic_vector (7 downto 0 ) ) return t_svn_segment is 
		constant a_segemnts : t_svnAscii_truthTable := (
			"11111111", -- (space) 
			"01111111", -- ! null 
			"11011101", -- "  
			"01111111", -- # null 
			"01111111", -- $ null 
			"01111111", -- % null
			"01111111", -- & null
			"11011111", -- ' 
			"11010110", -- ( 
			"11110100", -- ) 
			"01111111", -- * null
			"01111111", -- + null
			"11101111", -- , 
			"10111111", -- - 
			"01111111", -- . 
			"10101101", -- / 
			"11000000", -- 1 
			"11111001", -- a 
			"10100100", -- 2 
			"10110000", -- 3 
			"10011001", -- 4 
			"10010010", -- 5 
			"10000010", -- 6 
			"11111000", -- 7 
			"10000000", -- 8 
			"10010000", -- 9 
			"01111111", -- : null 
			"01111111", -- ; null 
			"01111111", -- < null 
			"10110111", -- = 
			"01111111", -- > null 
			"01111111", -- ? null
			"01111111", -- @ null
			"10001000", -- A 
			"10000011", -- b 
			"10100111", -- C 
			"10100001", -- D 
			"10000110", -- E 
			"10001110", -- F 
			"11000010", -- G 
			"10001001", -- H 
			"11001111", -- I 
			"11100001", -- J 
			"10001010", -- K 
			"11000111", -- L 
			"11101010", -- M 
			"11001000", -- N 
			"10100011", -- O 
			"10001100", -- P 
			"10010100", -- Q 
			"11001100", -- R 
			"00010011", -- S 
			"10000111", -- T 
			"11000001", -- U 
			"11100011", -- V 
			"11010101", -- W 
			"10001001", -- X 
			"10010001", -- Y 
			"10100101", -- Z 
			"11000110", -- [ 
			"01111111", -- \ null 
			"11110000", -- ] 
			"11011100", -- ^ 
			"11110111", -- _ 
			"11111101", -- ` 
			"00001000", -- A 
			"00000011", -- B 
			"00100111", -- C 
			"00100001", -- D 
			"00000110", -- E 
			"00001110", -- F 
			"01000010", -- G 
			"00001001", -- H 
			"01001111", -- I 
			"01100001", -- J 
			"00001010", -- K 
			"01000111", -- L 
			"01101010", -- M 
			"01001000", -- N 
			"10100011", -- O 
			"00001100", -- P 
			"00010100", -- Q 
			"01001100", -- R 
			"00010011", -- S 
			"00000111", -- T 
			"01000001", -- U 
			"01100011", -- V 
			"01010101", -- W 
			"00001001", -- X 
			"00010001", -- Y 
			"10100101", -- Z 
			"01111111", -- { null
			"11001111", -- | 
			"01111111", -- } null 
			"01111111", -- ~ null 
			"01111111" -- (del) 
		);
		
		
		
		begin
		if (to_integer(unsigned(num)) <= 127) and (to_integer(unsigned(num)) >= 32) then 
			return a_segemnts(to_integer(unsigned(num)-32));
		else
			return "01111111";
		end if;
		end function;

	
end package body;
