library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.UART_datatypes_pkg.all;

package std_logic_vec_pkg is -- same as .h-file in c
	
	function vec_more_Ones (num: std_logic_vector  ) return std_logic ;
	function vec_parity (num: std_logic_vector  ) return std_logic ;
		
	
end package;

package body std_logic_vec_pkg is -- is the function definition

	function vec_more_Ones (num: std_logic_vector ) return std_logic  is 
		variable ones : integer:=0;
	begin
			for i in num'range loop
				if num(i)='1' then 
					ones:=ones+1;
				end if;
			end loop;
			if ones > (num'length/2) then
				return '1';
			else
				return '0';
			end if;
	end function;
	
	function  vec_parity (num: std_logic_vector  ) return std_logic is
		variable pair: std_logic:='0';
	begin 
	
		for i in num'range loop	
			pair:=pair xor num(i);
		end loop;
		return pair;
	end function;
end package body;
