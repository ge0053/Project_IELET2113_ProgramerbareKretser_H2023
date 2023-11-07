library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.std_logic_vec_pkg.all;
use work.fifo_pkg.all;

entity fifo is
	generic(
	
	DATA_LENGTH: natural:=8
	);
    port(
        clk   : in  std_logic;
        rst_n : in  std_logic;
		readDataIn : in std_logic;
		dataInHandled: out std_logic:='0';
        data_in : in  std_logic_vector(DATA_LENGTH-1 downto 0);
		dataOutHandled: in std_logic;
        data_out : out  std_logic_vector(DATA_LENGTH-1 downto 0);
		dataOutReady : out std_logic


    );
end fifo;

architecture RTL of fifo is
signal readDataIn_sample: std_logic_vector(1 downto 0):="00";
signal dataOutHandled_sample : std_logic_vector(1 downto 0):="11";
signal sendData: std_logic:='1';

type state_type is (IDLE, POS_EDGE, POSITIVE_SIGN);
    signal current_state, next_state : state_type;

signal outBuffer : t_fifo := ( 	FIFO =>(others => (others =>'0')),
									place=>0,
									pop=>0,
									full=>'0',
									empty=>'1');

begin
    process(all)
	--update state
    begin
        if rst_n = '0' then
            current_state <= IDLE;
			
			
        elsif rising_edge(clk) then
            current_state <= next_state;

			
        end if;
	end process;	
    process(all)
		variable tmp_outBuffer : t_fifo := ( 	FIFO =>(others => (others =>'0')),
									place=>0,
									pop=>0,
									full=>'0',
									empty=>'1');

	begin
	--tmp_outBuffer := outBuffer;
	if rising_edge(clk) then 
		--wait on positive edge
		if readDataIn_sample = "01" then
			fifo_place(tmp_outBuffer,data_in);
			--data_out<=data_in;
			dataInHandled<= not dataInHandled ;
		end if;
		
		case current_state is
		
			when IDLE =>
				if dataOutHandled='1' then 
					next_state<= POS_EDGE;
					dataOutReady<='0';
				end if;
			when POS_EDGE =>
				if dataOutHandled='1' then
					
					if tmp_outBuffer.empty /='1' then
						next_state <= POSITIVE_SIGN;
						fifo_pop(tmp_outBuffer,data_out);
					else
						dataOutReady<='0';
					end if;
				else 
					next_state <=IDLE;
				end if;
			when POSITIVE_SIGN =>
				dataOutReady<='1';
				if dataOutHandled='0' then 
					next_state <= IDLE;
				end if;
			when others =>
				next_state<=IDLE;
		end case;

			
		
		
		
		----wait on positive edge
		-- if dataOutHandled_sample="01" then
			----signal fifo to send data
			-- sendData<='1';
			-- dataOutReady<='0';
		-- elsif  dataOutHandled_sample="00"  then
			-- sendData<='0';
			-- dataOutReady<='0';
		
		-- elsif (sendData='1') and (tmp_outBuffer.empty /='1') and (dataOutHandled_sample = "11" ) then
			-- fifo_pop(tmp_outBuffer,data_out);
			-- dataOutReady<='1';
			-- sendData<='0';

		-- end if;
		readDataIn_sample<=readDataIn_sample(0) & readDataIn;
		dataOutHandled_sample<=dataOutHandled_sample(0) & dataOutHandled;
	end if;

	--dataOutReady <=sendData;
	--outBuffer<=tmp_outBuffer;
    end process;
end architecture;
