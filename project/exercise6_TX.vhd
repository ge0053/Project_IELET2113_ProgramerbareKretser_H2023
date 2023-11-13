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
        ready  : out std_logic:='0'

    );
end exercise6_TX;

architecture RTL of exercise6_TX is
	constant clk_divider: integer:= integer ((real(F_CLK_KHz)/real(BAUDRATE))*real(1000));

	-- possible states
type state_type is (IDLE,START, DATA, PARITY, STOP);
 signal current_state, next_state : state_type;

	signal bit_counter : integer range 0 to DATA_LENGTH := 0;
	signal parity_bit : std_logic;


	signal clk_buff : integer range 0 to clk_divider+1:=0;

	-- sample of data
	signal data_sample: std_logic_vector(DATA_LENGTH-1 downto 0):= (others => '0');
	signal next_ready: std_logic:='0';
begin
    process(all)
	--update state
    begin
        if rst_n = '0' then
            current_state <= IDLE;

			
        else
            current_state <= next_state;
			ready<=next_ready;

        end if;
    end process;

	
	
    process(all)
	variable next_clk_buff : integer range 0 to clk_divider+1:=0;

    begin

	
		if rising_edge(clk) then
			--next_clk_buff:=clk_buff;
			--next_ready<=ready;
			case current_state is
--------------------------------------------------------------------
				when IDLE =>
					next_ready<='1';
					tx_out<='1';
					next_clk_buff:=0;
					bit_counter<=0;
					if send_data ='1' then
						data_sample <= data_in;
						next_state <= START;
						--ready<='0';
						-- calculate parity
						if PARITY_ON=1 then 
							parity_bit<=vec_parity(data_in) xor PARITY_ODD;
						end if;
					else
						
					end if;
----------------------------------------------------------------------
				when START =>  ----startbit
					tx_out<='0';
					next_ready<='0';
					if clk_buff >=clk_divider then
						
						next_state <=DATA;

						next_clk_buff:=0;
					else
						next_clk_buff:=next_clk_buff+1;
					end if;
--------------------------------------------------------------------
				when DATA => ---- send all databits
					tx_out<=data_sample(bit_counter);
					next_ready<='1';
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

						next_clk_buff:=0;
						
					else
						next_clk_buff:=next_clk_buff+1;
						
					end if;
--------------------------------------------------------------------
				when PARITY => -- send parity bit if configured
					tx_out<=parity_bit;
					next_ready<='1';
					if clk_buff >=clk_divider then
					
						next_state <=STOP;

						next_clk_buff:=0;
					else
					next_clk_buff:=next_clk_buff+1;
					end if;
					
--------------------------------------------------------------------
				when STOP => -- send stopbit
					tx_out<='1';
					next_ready<='1';
					if clk_buff >=clk_divider then
					---- slow down TX for testing.
						--if bit_counter >= 9600 then 
					
							next_state <=IDLE;
							
							next_clk_buff:=0;
						--else
						--	bit_counter <= bit_counter+1;
						--	next_clk_buff:=0;
						--end if;
					else
						next_clk_buff:=next_clk_buff+1;
					end if;
				when others =>
					next_ready<='1';
					tx_out<='1';
					next_state <=IDLE;
				
				
					
			end case;
			clk_buff<=next_clk_buff;
		end if;
    end process;
end architecture;
