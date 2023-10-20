library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.std_logic_vec_pkg.all;

entity exercise6_RX is
	generic(
	F_CLK_KHz: natural :=50000 ;
	OVERSAMPLING: natural:=8 ;
	BAUDRATE : natural:=9600;
	WORD_LENGTH: natural:=9;
	PARITY_ON : natural := 1 ; --0 or 1
	PARITY_ODD : std_logic:='0');
    port(
        clk   : in  std_logic;
        rst_n : in  std_logic;
        rx_in : in  std_logic;
        data_out  : out std_logic_vector(WORD_LENGTH-1-PARITY_ON downto 0);
        done  : out std_logic
    );
end exercise6_RX;

architecture RTL of exercise6_RX is
	-- divide by 2 since every positive edge should generate a sample.
	constant clk_divider: integer:= integer ((real(F_CLK_KHz)/real(OVERSAMPLING)/real(BAUDRATE))*real(1000)/real(2));
	constant dataLength: integer:=WORD_LENGTH-PARITY_ON;
    type state_type is (IDLE, START, DATA, STOP);
    signal current_state, next_state : state_type;
    signal bit_counter : integer range 0 to WORD_LENGTH-1 := 0;
    signal sample_counter : integer range 0 to OVERSAMPLING-1 := 0;
    signal data_tmp : std_logic_vector( WORD_LENGTH-1  downto 0) := (others => '0');
	signal UART_OVERSAMLE_CLK : std_logic:='0';
	signal alignStart : std_logic_vector (1 downto 0 ) :="00";
	signal clk_buff : integer range 0 to clk_divider:=0;
	signal sampler : std_logic_vector ((OVERSAMPLING-4) downto 0);
	
begin

    process(all)
    begin
        if rst_n = '0' then
            current_state <= IDLE;

			
        elsif rising_edge(clk) then
            current_state <= next_state;

			
        end if;
    end process;
	
	 p_clk_divider: process(clk , rst_n,alignStart)
	 variable v_UART_OVERSAMPLE_CLK: std_logic := UART_OVERSAMLE_CLK;
	 variable v_clk_buff:  integer range 0 to clk_divider:= clk_buff;
	begin
		if   (alignStart) = "01"  then
		-- align clock
			v_clk_buff := 0;
			v_UART_OVERSAMPLE_CLK:='0';
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
			done <= '0';
			--next_state <= current_state;  -- Default

			case current_state is
				when IDLE =>
					sampler<=(others =>'0');
					if rst_n = '0' then 
						data_out <= (others => '0');
					end if;
				when START =>
					if sample_counter = OVERSAMPLING-1 then
						if not(vec_more_Ones(sampler)) then
							sampler<=(others =>'0');	
							next_state <= DATA;
							sample_counter <= 0;
							bit_counter <= 0;
						else
							next_state <= IDLE;
						end if;
					elsif (sample_counter >=0) and (sample_counter <=OVERSAMPLING-4) then
						sampler(sample_counter)<=rx_in;
						sample_counter <= sample_counter+1;
					else 
						sample_counter <= sample_counter+1;
					end if;


				when DATA =>
					if sample_counter = OVERSAMPLING-1 then
							data_tmp(bit_counter)<=vec_more_Ones(sampler);
							if bit_counter = WORD_LENGTH-1 then
								next_state <= STOP;
								bit_counter <= 0;
								sample_counter<=0;
							else
								bit_counter <= bit_counter + 1;
								sample_counter<=0;
							end if;
					elsif (sample_counter >=0) and (sample_counter <=OVERSAMPLING-4) then
							sampler(sample_counter)<=rx_in;
							sample_counter <= sample_counter+1;
					else 
							sample_counter <= sample_counter+1;
					end if;


				when STOP =>
					if sample_counter = OVERSAMPLING-1 then
						if vec_more_Ones(sampler) then 
							-- only update if startbit is true and PARITY_ON is true
							if (PARITY_ON/=0) and (vec_parity(data_tmp)=PARITY_ODD) then
								data_out <= data_tmp(dataLength-1 downto 0);
							
							else
								data_out <= data_tmp(dataLength-1 downto 0);
							end if;

						end if;
						-- go back to IDLE
						next_state <= IDLE;
						sampler<=(others =>'0');
						sample_counter <= 0;
						bit_counter <= 0;
					
					elsif (sample_counter >=0) and (sample_counter <=OVERSAMPLING-4) then
						sampler(sample_counter)<=rx_in;
						sample_counter <= sample_counter+1;
					else 
						sample_counter <= sample_counter+1;
					end if;
			end case;
		else 
			sample_counter <= sample_counter;
			next_state <= next_state;
		end if;
			
    end process;
end architecture;
