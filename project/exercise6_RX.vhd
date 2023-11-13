library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.std_logic_vec_pkg.all;
use work.fifo_pkg.all;

entity exercise6_RX is
	generic(
	F_CLK_KHz: natural :=50000 ;
	OVERSAMPLING: natural:=8 ;
	BAUDRATE : natural:=9600;
	DATA_LENGTH: natural:=8;
	PARITY_ON : natural := 0 ; --0 or 1
	PARITY_ODD : std_logic:='0'

	);
    port(
        clk   : in  std_logic;
        rst_n : in  std_logic;
        rx_in : in  std_logic;
        data_out  : out std_logic_vector(DATA_LENGTH-1 downto 0);
        done  : out std_logic;
		--fifoBuffer: out t_fifo;
		data_ready: out std_logic
    );
end exercise6_RX;

architecture RTL of exercise6_RX is
	-- divide by 2 since every positive edge should generate a sample.
	constant clk_divider: integer:= integer ((real(F_CLK_KHz)/real(OVERSAMPLING)/real(BAUDRATE))*real(1000)/real(2));
	-- the data length excluding parity.
	--constant dataLength: integer:=DATA_LENGTH;
	-- sample boundary. defines which steps to sample for data/stopbit/startbit 
	constant c_sampleLowerBound: integer:=(OVERSAMPLING/4)-1; -- start sample at 1/4.
	constant c_sampleUpperBound: integer:=OVERSAMPLING-(OVERSAMPLING/4)-1; --end sample at 3/4
	-- possible states
    type state_type is (IDLE, START, DATA, STOP);
    signal current_state, next_state : state_type;
	-- hold controll over which databit we are reading.
    signal bit_counter : integer range 0 to DATA_LENGTH-1+PARITY_ON := 0;
	-- cold controll over which sample we are at
    signal sample_counter : integer range 0 to OVERSAMPLING-1 := 0;
    signal data_tmp : std_logic_vector( DATA_LENGTH-1+PARITY_ON  downto 0) := (others => '0');
	-- the clock most of te system uses
	signal UART_OVERSAMLE_CLK : std_logic:='0';
	-- edge detection of startbit
	signal alignStart : std_logic_vector (1 downto 0 ) :="00";
	signal clk_buff : integer range 0 to clk_divider:=0;
	-- hold the samled values
	signal sampler : std_logic_vector (c_sampleLowerBound to c_sampleUpperBound);
	-- the fifo
	 
	-- signal outBuffer : t_fifo := ( 	FIFO =>(others => (others =>'0')),
									-- place=>0,
									-- pop=>0,
									-- full=>'0',
									-- empty=>'1');
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
	 p_clk_divider: process(all)
		
		variable v_UART_OVERSAMPLE_CLK: std_logic := UART_OVERSAMLE_CLK;
		variable v_clk_buff:  integer range 0 to clk_divider:= clk_buff;
	begin
		if   (alignStart) = "01"  then
		-- align clock to startbit edge
			v_clk_buff := 0;
			v_UART_OVERSAMPLE_CLK:='0';
		-- update the UART_RX clock
		elsif rising_edge(clk) then
			if v_clk_buff < clk_divider then 
				v_clk_buff:= clk_buff + 1;
			else
				v_clk_buff:=0;
				v_UART_OVERSAMPLE_CLK:= NOT(v_UART_OVERSAMPLE_CLK);
			end if;
			
		end if;	
		UART_OVERSAMLE_CLK <=v_UART_OVERSAMPLE_CLK;
		clk_buff<= v_clk_buff;
	 end process;
	
	
    process(all)
	variable tmp_alignStart : std_logic:='0';
	--variable tmp_outBuffer : t_fifo ;
    begin
		if current_state = IDLE then
			
			-- detect possible startbit and align clock to this.
			if rx_in = '0' then
				next_state <= START;
				sample_counter <= 0;
				tmp_alignStart :='1';
			else 
			tmp_alignStart :='0';
			
			end if;
		else 
			tmp_alignStart := '0';
		end if;	
		alignStart <= alignStart(0) & tmp_alignStart;
		if rising_edge(UART_OVERSAMLE_CLK) then
			

			case current_state is
--------------------------------------------------------------------
				when IDLE =>
					data_ready<='1';
					done <= '0';
					sampler<=(others =>'0');
					if rst_n = '0' then 
						data_out <= (others => '0');
					end if;
--------------------------------------------------------------------
				when START => -- sampel multiple points to make sure it was a startbit.
					--when the signallength of 1 bit is finished
					data_ready<='0';
					if sample_counter = (OVERSAMPLING-1) then
						-- if most samples are 0. goto state DATA. else state IDLE.
						if not(vec_more_Ones(sampler)) then
							sampler<=(others =>'0');	
							next_state <= DATA;
							sample_counter <= 0;
							bit_counter <= 0;
						else
							next_state <= IDLE;
						end if;
					-- aslong we are inside the samplingrange take a sample. 
					elsif (sample_counter >=c_sampleLowerBound) and (sample_counter <=c_sampleUpperBound) then
						sampler(sample_counter)<=rx_in;
						sample_counter <= sample_counter+1;
					else 
						sample_counter <= sample_counter+1;
					end if;

--------------------------------------------------------------------
				when DATA =>
					data_ready<='0';
					done <= '1';
					-- take samples at every bit and append it to the data_tmp list.
					-- do this until there are enough bits.
					if sample_counter = (OVERSAMPLING-1) then
							data_tmp(bit_counter)<=vec_more_Ones(sampler);
							if bit_counter = (DATA_LENGTH-1+PARITY_ON )then
								next_state <= STOP;
								bit_counter <= 0;
								sample_counter<=0;
							else
								bit_counter <= bit_counter + 1;
								sample_counter<=0;
							end if;
					elsif (sample_counter >=c_sampleLowerBound) and (sample_counter <=c_sampleUpperBound) then
							sampler(sample_counter)<=rx_in;
							sample_counter <= sample_counter+1;
					else 
							sample_counter <= sample_counter+1;
					end if;

--------------------------------------------------------------------
				when STOP =>
					
					if sample_counter = (OVERSAMPLING-1) then
						--check if it is a stopbit.
						if vec_more_Ones(sampler) then 
							if (((PARITY_ON/=0) and (vec_parity(data_tmp)=PARITY_ODD)) or PARITY_ON=0) then
								--only add new if parity is turned off or ok.
								
								--only add data. not parity
								data_out<=data_tmp (DATA_LENGTH-1 downto 0);

								data_ready<='0';
							end if;

						end if;
						-- go back to IDLE
						next_state <= IDLE;
						sampler<=(others =>'0');
						sample_counter <= 0;
						bit_counter <= 0;
					--take new sample
					elsif ((sample_counter >=c_sampleLowerBound) and (sample_counter <=c_sampleUpperBound)) then
						sampler(sample_counter)<=rx_in;
						sample_counter <= sample_counter+1;
					else 
						sample_counter <= sample_counter+1;
					end if;
				when others =>
					data_ready<='0';
			end case;

		else 
			sample_counter <= sample_counter;
			next_state <= next_state;

		end if;
			
    end process;
end architecture;