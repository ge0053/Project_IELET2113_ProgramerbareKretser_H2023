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
	--procedure fifo_reset(variable object: inout t_fifo);

end package ;


package body fifo_pkg is
	-- For placing data into the FIFO queue
    procedure fifo_place(variable object: inout t_fifo; signal data: in std_logic_vector) is 

	begin
		-- Is the FIFO full or is empty
		if ((object.place ) /= (object.pop )) or (object.empty='1') then 
			-- Place data into the FIFO at the current 'place'
			object.FIFO(((object.place) mod (fifoSize))) := data; 
			-- Increment the 'place' pointer and wrapping with mod
			object.place:=(object.place+1) mod (fifoSize);
			-- FIFO not empty
			object.empty :='0';
			-- If 'place' = 'pop', mark FIFO as full
			if (object.place)  = (object.pop)  then
				object.full:='1';
			end if;
		end if;
	end procedure;
	-- Data from the FIFO queue
	 procedure fifo_pop(variable object: inout t_fifo; signal data: out std_logic_vector) is 
	begin
		-- Check if the FIFO is not empty or is full
		if ((object.place ) /= (object.pop )) or (object.full='1') then 
			-- Retrieve data from FIFO at the current position
			data <= object.FIFO(((object.pop) mod (fifoSize)));
			-- Increment the pointer and wrapping
			object.pop :=(object.pop+1) mod (fifoSize);
			-- FIFO not full
			object.full :='0';
			-- If 'pop' = 'place', mark FIFO as empty
			if (object.place)  = (object.pop)  then
				object.empty:='1';
			end if;
		end if;
	end procedure;
	-- Get data from the FIFO queue at a specific offset
	function fifo_get(signal object: in t_fifo; offset: in integer)return std_logic_vector is 
	begin
		-- Is the offset within the valid range
		if ((offset) <= fifoSize-1) then 
			-- Return the data, based on offset
			return object.FIFO((object.place-offset+fifoSize-1)mod fifoSize );
		end if;
		
		-- Offset is out of range
		return "00000000";
	end function;
	

end package body ;
