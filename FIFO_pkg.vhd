library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fifo_pkg is
	type t_arrayOfVec is array (0 to 15) of std_logic_vector (7 downto 0) ;
	subtype t_fifoLength is integer range  0 to 15;
		
	type t_fifo is record 
		FIFO: t_arrayOfVec ;
		place: t_fifoLength;
		pop: t_fifoLength;
		empty: std_logic;
		full: std_logic;
		
	end record t_fifo;
	--procedure init(object: inout t_fifo);
	procedure fifo_place(variable object: inout t_fifo; signal data: in std_logic_vector);
	procedure fifo_pop(variable object: inout t_fifo; signal data: out std_logic_vector);
	function fifo_get(signal object: in t_fifo; offset: in integer)return std_logic_vector;


end package ;


package body fifo_pkg is

    procedure fifo_place(variable object: inout t_fifo; signal data: in std_logic_vector) is 

	begin
		if ((object.place ) /= (object.pop )) or (object.empty='1') then 
			object.FIFO(((object.place) mod (object.FIFO'length))) := data;
			object.place:=(object.place+1 mod (object.FIFO'length));
			object.empty :='0';
			if (object.place)  = (object.pop)  then
				object.full:='1';
			end if;
		end if;
	end procedure;
	
	 procedure fifo_pop(variable object: inout t_fifo; signal data: out std_logic_vector) is 
	begin
		-- if ((object.place) mod (object.FIFO'length-1)) /= (object.pop mod (object.FIFO'length-1)) then 
			-- data  <= object.FIFO(((object.pop)mod (object.FIFO'length-1)));
			-- object.pop<=(object.pop+1 mod (object.FIFO'length-1));
		-- end if;
		
		if ((object.place ) /= (object.pop )) or (object.full='1') then 
			data <= object.FIFO(((object.pop) mod (object.FIFO'length)));
			object.pop :=(object.pop+1 mod (object.FIFO'length));
			object.full :='0';
			if (object.place)  = (object.pop)  then
				object.empty:='1';
			end if;
		end if;
	end procedure;
	
	function fifo_get(signal object: in t_fifo; offset: in integer)return std_logic_vector is 
	begin
	
		if ((offset) <= object.FIFO'length-1) then 
			return object.FIFO((object.place-offset+object.FIFO'length-1)mod object.FIFO'length );
		end if;
		
		
		return "00000000";
	end function;
	

end package body ;