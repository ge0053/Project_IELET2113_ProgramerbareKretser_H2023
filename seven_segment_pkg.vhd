library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package seven_segment_pkg is -- same as .h-file in c
	subtype t_svn_segment is std_logic_vector(6 downto 0);
	type t_svnHex_truthTable is array (0 to 15) of std_logic_vector ( 6 downto 0);
	type t_svnAscii_truthTable is array (0 to 94) of std_logic_vector ( 6 downto 0);
	subtype t_nibble is std_logic_vector(3 downto 0);
	function vecTo_svnSegmentHex (num: std_logic_vector (3 downto 0 ) ) return t_svn_segment ;
	function vecTo_svnSegmentAscii (num: std_logic_vector (7 downto 0 ) ) return t_svn_segment ;
		
	
end package;

package body seven_segment_pkg is -- is the function definition

	function vecTo_svnSegmentHex(num: t_nibble) return t_svn_segment is 
		constant a_segemnts : t_svnHex_truthTable := (			
		"1000000",	--0
		"1111001",	--1
		"0100100",	--2
		"0110000",	--3
		"0011001",	--4
		"0010010",	--5
		"0000010",	--6
		"1111000",	--7
		"0000000",	--8
		"0010000",	--9
		"0001000",	--A
		"0000011",	--B
		"1000110",	--C
		"0100001",	--D
		"0000110",	--E
		"0001110"	--F
		
		);
	begin

		return a_segemnts(to_integer(unsigned(num)));
	end function;
	
	function vecTo_svnSegmentAscii (num: std_logic_vector (7 downto 0 ) ) return t_svn_segment is 
		constant a_segemnts : t_svnAscii_truthTable := (
			"00000000", /* (space) */
			"10000000", /* ! null */
			"00100010", /* "  */
			"10000000", /* # null */
			"10000000", /* $ null */
			"10000000", /* % null*/
			"10000000", /* & null*/
			"00100000", /* ' */
			"00101001", /* ( */
			"00001011", /* ) */
			"10000000", /* * null*/
			"10000000", /* + null*/
			"00010000", /* , */
			"01000000", /* - */
			"10000000", /* . */
			"01010010", /* / */
			"00111111", /* 0 */
			"00000110", /* 1 */
			"01011011", /* 2 */
			"01001111", /* 3 */
			"01100110", /* 4 */
			"01101101", /* 5 */
			"01111101", /* 6 */
			"00000111", /* 7 */
			"01111111", /* 8 */
			"01101111", /* 9 */
			"10000000", /* : null */
			"10000000", /* ; null */
			"10000000", /* < null */
			"01001000", /* = */
			"10000000", /* > null */
			"10000000", /* ? null*/
			"10000000", /* @ null*/
			"01110111", /* A */
			"01111100", /* B */
			"01011000", /* C */
			"01011110", /* D */
			"01111001", /* E */
			"01110001", /* F */
			"00111101", /* G */
			"01110110", /* H */
			"00110000", /* I */
			"00011110", /* J */
			"01110101", /* K */
			"00111000", /* L */
			"00010101", /* M */
			"00110111", /* N */
			"00111111", /* O */
			"01110011", /* P */
			"01101011", /* Q */
			"00110011", /* R */
			"01101101", /* S */
			"01111000", /* T */
			"00111110", /* U */
			"00011100", /* V */
			"00101010", /* W */
			"01110110", /* X */
			"01101110", /* Y */
			"01011011", /* Z */
			"00111001", /* [ */
			"10000000", /* \ null */
			"00001111", /* ] */
			"00100011", /* ^ */
			"00001000", /* _ */
			"00000010", /* ` */
			"11110111", /* A */
			"11111100", /* B */
			"11011000", /* C */
			"11011110", /* D */
			"11111001", /* E */
			"11110001", /* F */
			"10111101", /* G */
			"11110110", /* H */
			"10110000", /* I */
			"10011110", /* J */
			"11110101", /* K */
			"10111000", /* L */
			"10010101", /* M */
			"10110111", /* N */
			"10111111", /* O */
			"11110011", /* P */
			"11101011", /* Q */
			"10110011", /* R */
			"11101101", /* S */
			"11111000", /* T */
			"10111110", /* U */
			"10011100", /* V */
			"10101010", /* W */
			"11110110", /* X */
			"11101110", /* Y */
			"11011011", /* Z */
			"10000000", /* { null*/
			"00110000", /* | */
			"10000000", /* } null */
			"10000000", /* ~ null */
			"00000000" /* (del) */
		);
		
		
		
		begin
		if (to_integer(unsigned(num)) <= 127) and (to_integer(unsigned(num)) >= 32) then 
			return a_segemnts(to_integer(unsigned(num)-32));
		else
			return "10000000";
		end if;
		end function;

	
end package body;
