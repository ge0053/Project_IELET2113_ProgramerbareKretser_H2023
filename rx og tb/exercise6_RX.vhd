library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity exercise6_RX is
  generic (
    F_CLK_KHz      : natural := 50000;
    OVERSAMPLING   : natural := 8;
    BAUDRATE       : natural := 9600
  );
  
  port (
    clk            : in  std_logic;
    rst_n          : in  std_logic;
    RX_in          : in  std_logic;
    byte_received  : out std_logic;
    received_byte  : out std_logic_vector(7 downto 0)
  );

end exercise6_RX;

architecture RTL of exercise6_RX is

  -- Beregn antall klokkesykluser per bit
  constant clks_per_bit: integer := F_CLK_KHz * 1000 / (BAUDRATE * OVERSAMPLING); 
  
  constant MIDDLE_SAMPLE_POINT: integer := clks_per_bit / 2;
  constant LAST_SAMPLE_POINT: integer := clks_per_bit - 1;

  type ReceiverState is (IDLE, START, DATA, STOP);
  signal current_state, next_state: ReceiverState := IDLE;

  signal clk_counter: integer range 0 to clks_per_bit-1 := 0;
  signal bit_position: integer range 0 to 7 := 0;
  signal data_byte: std_logic_vector(7 downto 0) := (others => '0');
  signal rx_data_valid: std_logic := '0';

begin

  process (clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        -- Nullstiller alle signaler ved reset
        current_state  <= IDLE;
        clk_counter  <= 0;
        bit_position  <= 0;
        data_byte      <= (others => '0');
        rx_data_valid  <= '0';
      else
        current_state  <= next_state;

        case current_state is
          when IDLE =>
            rx_data_valid  <= '0';
            clk_counter  <= 0;
            bit_position  <= 0;
            if RX_in = '0' then
              next_state <= START;
            else
              next_state <= IDLE;
            end if;

          when START =>
            if clk_counter = MIDDLE_SAMPLE_POINT then
              if RX_in = '0' then
                clk_counter <= 0;
                next_state    <= DATA;
              else
                next_state    <= IDLE;
              end if;
            elsif clk_counter < LAST_SAMPLE_POINT then
              clk_counter <= clk_counter + 1;
              next_state    <= START;
            else
              clk_counter <= 0;
              next_state    <= IDLE;
            end if;

          when DATA =>
            if clk_counter = LAST_SAMPLE_POINT then
              clk_counter <= 0;
              if bit_position < 7 then
                bit_position  <= bit_position + 1;
                next_state    <= DATA;
              else
                bit_position  <= 0;
                next_state    <= STOP;
              end if;
            elsif clk_counter = MIDDLE_SAMPLE_POINT then
              data_byte(bit_position) <= RX_in;
              clk_counter           <= clk_counter + 1;
              next_state              <= DATA;
            else
              clk_counter           <= clk_counter + 1;
              next_state              <= DATA;
            end if;

          when STOP =>
            if clk_counter = LAST_SAMPLE_POINT then
              rx_data_valid  <= '1';
              clk_counter  <= 0;
              next_state     <= IDLE;
            else
              clk_counter  <= clk_counter + 1;
              next_state     <= STOP;
            end if;

          when others =>
            next_state <= IDLE;

        end case;
      end if;
    end if;
  end process;
  
  byte_received   <= rx_data_valid;
  received_byte   <= data_byte;

end RTL;
