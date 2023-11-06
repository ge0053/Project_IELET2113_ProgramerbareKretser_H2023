library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.std_logic_vec_pkg.all;
use work.fifo_pkg.all;

entity exercise6_TX is
	generic(
	F_CLK_KHz: natural :=50000 ;

	BAUDRATE : natural:=9600;
	DATA_LENGTH: natural:=8;
	PARITY_ON : natural := 0 ; --0 or 1
	PARITY_ODD : std_logic:='0');

    port(
        clk   : in  std_logic;
        rst_n : in  std_logic;
		send_data: in std_logic;
        data_in : in  std_logic_vector(DATA_LENGTH-1 downto 0);
        tx_out  : out std_logic;
        ready  : out std_logic

    );
end exercise6_TX;

architecture RTL of exercise6_TX is
	-- divide by 2 since every positive edge should generate a sample.
	constant clk_divider: integer:= integer ((real(F_CLK_KHz)/real(BAUDRATE))*real(1000));
	-- the data length excluding parity.
	
	-- sample boundary. defines which steps to sample for data/stopbit/startbit 
	--constant c_sampleLowerBound: integer:=(OVERSAMPLING/4)-1; -- start sample at 1/4.
	--constant c_sampleUpperBound: integer:=OVERSAMPLING-(OVERSAMPLING/4)-1; --end sample at 3/4
	-- possible states
type state_type is (IDLE,START, DATA, PARITY, STOP);
 signal current_state, next_state : state_type;
	-- hold controll over which databit we are reading.
	signal bit_counter : integer range 0 to DATA_LENGTH-1 := 0;
	signal parity_bit : std_logic;
	-- cold controll over which sample we are at
--signal sample_counter : integer range 0 to OVERSAMPLING-1 := 0;
--signal data_tmp : std_logic_vector( DATA_LENGTH-1  downto 0) := (others => '0');
	-- the clock most of te system uses
	--signal UART_OVERSAMLE_CLK : std_logic:='0';
	-- edge detection of startbit
	signal alignStart : std_logic_vector (1 downto 0 ) :="00";
	signal clk_buff : integer range 0 to clk_divider+1:=0;
	--signal next_clk_buff : integer range 0 to clk_divider+1:=0;
	-- hold the samled values
--	signal sampler : std_logic_vector (c_sampleLowerBound to c_sampleUpperBound);
	-- sample of data
	signal data_sample: std_logic_vector(DATA_LENGTH-1 downto 0):= (others => '0');
	signal next_ready: std_logic:='0';
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
	
		-- creates the clock divider

	
	
    process(all)
	variable next_clk_buff : integer range 0 to clk_divider+1:=clk_buff;
    begin
		--tmp_outBuffer := outBuffer;
	
		if rising_edge(clk) then
			--next_clk_buff:=clk_buff;
			--next_ready<=ready;
			case current_state is
--------------------------------------------------------------------
				when IDLE =>
					tx_out<='1';
					next_clk_buff:=0;
					bit_counter<=0;
					if send_data ='1' then
						data_sample <= data_in;
						next_state <= START;
						next_ready<='0';
						-- calculate parity
						if PARITY_ON=1 then 
							parity_bit<=vec_parity(data_in) xor PARITY_ODD;
						end if;
					else
						next_ready<='1';
					end if;
----------------------------------------------------------------------
				when START =>
					tx_out<='0';
					if clk_buff >=clk_divider then
					
						next_state <=DATA;

						next_clk_buff:=0;
					else
						next_clk_buff:=next_clk_buff+1;
					end if;
--------------------------------------------------------------------
				when DATA => -- sampel multiple points to make sure it was a startbit.
					tx_out<=data_sample(0);
					if clk_buff >=clk_divider then
					
						if bit_counter >= DATA_LENGTH-1 then 
							if PARITY_ON =1 then 
								next_state <=PARITY;
							else 
								next_state <=STOP;
							end if;
						else
							bit_counter<= bit_counter+1;
						end if;
						--shift right
						data_sample<='0' & data_sample(DATA_LENGTH-1 downto 1);
						next_clk_buff:=0;
						
					else
						next_clk_buff:=next_clk_buff+1;
						
					end if;
--------------------------------------------------------------------
				when PARITY =>
					tx_out<=parity_bit;
					if clk_buff >=clk_divider then
					
						next_state <=STOP;

						next_clk_buff:=0;
					else
					next_clk_buff:=next_clk_buff+1;
					end if;
					
--------------------------------------------------------------------
				when STOP =>
					tx_out<='1';
					next_ready<='1';
					if clk_buff >=clk_divider then
					
						next_state <=IDLE;
						
						next_clk_buff:=0;
					else
						next_clk_buff:=next_clk_buff+1;
					end if;
					
			end case;
	
		clk_buff<=next_clk_buff;
		ready<=next_ready;
		end if;
			
    end process;
end architecture;
