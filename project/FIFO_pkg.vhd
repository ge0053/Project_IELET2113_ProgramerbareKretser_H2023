library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fifo_pkg is
	constant fifoSize : integer :=16; 
	type t_arrayOfVec is array (0 to fifoSize-1) of std_logic_vector (7 downto 0) ;
	subtype t_fifoLength is integer range  0 to fifoSize-1;
		
	type t_fifo is record 
		FIFO: t_arrayOfVec ;
		place: t_fifoLength;
		pop: t_fifoLength;
		empty: std_logic;
		full: std_logic;
		
	end record t_fifo;
	-- add element to the fifo
	procedure fifo_place(variable object: inout t_fifo; signal data: in std_logic_vector);
	-- remove element  from fifo
	procedure fifo_pop(variable object: inout t_fifo; signal data: out std_logic_vector);
	-- read fifo element relative to the oldest element. do not throw out.
	function fifo_get(signal object: in t_fifo; offset: in integer)return std_logic_vector;


end package ;


package body fifo_pkg is
    procedure fifo_place(variable object: inout t_fifo; signal data: in std_logic_vector) is 

	begin
		if ((object.place ) /= (object.pop )) or (object.empty='1') then 
			object.FIFO(((object.place) mod (fifoSize))) := data;
			object.place:=(object.place+1) mod (fifoSize);
			object.empty :='0';
			if (object.place)  = (object.pop)  then
				object.full:='1';
			end if;
		end if;
	end procedure;
	
	 procedure fifo_pop(variable object: inout t_fifo; signal data: out std_logic_vector) is 
	begin
		
		if ((object.place ) /= (object.pop )) or (object.full='1') then 
			data <= object.FIFO(((object.pop) mod (fifoSize)));
			object.pop :=(object.pop+1) mod (fifoSize);
			object.full :='0';
			if (object.place)  = (object.pop)  then
				object.empty:='1';
			end if;
		end if;
	end procedure;
	
	function fifo_get(signal object: in t_fifo; offset: in integer)return std_logic_vector is 
	begin
	
		if ((offset) <= fifoSize-1) then 
			return object.FIFO((object.place-offset+fifoSize-1)mod fifoSize );
		end if;
		
		
		return "00000000";
	end function;
	

end package body ;