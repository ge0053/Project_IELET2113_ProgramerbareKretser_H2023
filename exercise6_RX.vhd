library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exercise6_RX is
	generic(
	F_CLK_KHz: natural :=50000 ;
	OVERSAMPLING: natural:=8 ;
	BAUDRATE : natural:=9600 );
    port(
        clk   : in  std_logic;
        rst_n : in  std_logic;
        rx_in : in  std_logic;
        data_out  : out std_logic_vector(7 downto 0);
        done  : out std_logic
    );
end exercise6_RX;

architecture RTL of exercise6_RX is
	-- divide by 4 since every positive edge should generate a sample.
	constant clk_divider: integer:= integer ((real(F_CLK_KHz)/real(OVERSAMPLING)/real(BAUDRATE))*real(1000)/real(4));

    type state_type is (IDLE, START, DATA, STOP);
    signal current_state, next_state : state_type;
    signal bit_counter : integer range 0 to 7 := 0;
    signal sample_counter : integer range 0 to 7 := 0;
    signal data_tmp : std_logic_vector(7 downto 0) := (others => '0');
	signal UART_OVERSAMLE_CLK : std_logic:='0';
	signal alignStart : std_logic:='0';
	signal clk_buff : integer range 0 to clk_divider:=0;
	
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
	begin
		if rst_n = '0' or (rising_edge(alignStart) )  then
			clk_buff <= 0;
			UART_OVERSAMLE_CLK<='0';
		elsif rising_edge(clk) then
			if clk_buff < clk_divider then 
				clk_buff<= clk_buff + 1;
			else
				clk_buff<=0;
				UART_OVERSAMLE_CLK<= NOT(UART_OVERSAMLE_CLK);
			end if;
		end if;	
	 end process;
	
	
    process(current_state, rx_in, data_tmp, bit_counter, sample_counter,UART_OVERSAMLE_CLK)
    begin
		if current_state = IDLE then
			-- detect possible startbit and align clock to this.
			if rx_in = '0' then
				next_state <= START;
				sample_counter <= 0;
				alignStart <='1';
			end if;
			
		end if;	
		if rising_edge(UART_OVERSAMLE_CLK) then
			done <= '0';
			next_state <= current_state;  -- Default

			case current_state is
				when IDLE =>
					
					
				when START =>
					if sample_counter = (OVERSAMPLING/2-1) then --sampe at 3
						alignStart <='0';
						if rx_in = '0' then
							next_state <= DATA;
							sample_counter <= 0;
							bit_counter <= 0;
						else
							next_state <= IDLE;
						end if;
					else
						sample_counter <= sample_counter + 1;
					end if;

				when DATA =>
					if sample_counter = (OVERSAMPLING-1) then --loop every 7 clk cycles
						data_tmp(bit_counter) <= rx_in;
						if bit_counter = 7 then
							next_state <= STOP;
							bit_counter <= 0;
						else
							bit_counter <= bit_counter + 1;
						end if;
						sample_counter <= 0;
					else
						sample_counter <= sample_counter + 1;
					end if;

				when STOP =>
					if sample_counter = (OVERSAMPLING-1) then
						if rx_in = '1' then
							data_out <= data_tmp;
							done <= '1';
							next_state <= IDLE;
						else
							next_state <= IDLE;
						end if;
						sample_counter <= 0;
					else
						sample_counter <= sample_counter + 1;
					end if;
			end case;
		end if;
			
    end process;
end architecture;
