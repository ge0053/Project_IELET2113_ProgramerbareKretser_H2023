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
        data_in : in  std_logic_vector(DATA_LENGTH-1 downto 0);
		dataOutHandled: in std_logic;
        data_out : out  std_logic_vector(DATA_LENGTH-1 downto 0);
		dataOutReady : out std_logic


    );
end fifo;

architecture RTL of fifo is
signal readDataIn_sample: std_logic_vector(1 downto 0);
signal dataOutHandled_sample : std_logic_vector(1 downto 0);

signal outBuffer : t_fifo := ( 	FIFO =>(others => (others =>'0')),
									place=>0,
									pop=>0,
									full=>'0',
									empty=>'1');

begin
    process(all)
		variable tmp_outBuffer : t_fifo := outBuffer;
		variable sendData: std_logic:='1';
	begin
	--tmp_outBuffer := outBuffer;
	if rising_edge(clk) then 
		--wait on positive edge
		if readDataIn_sample = "01" then
			fifo_place(tmp_outBuffer,data_in);
		
		end if;
		--wait on positive edge
		if dataOutHandled_sample="01" then
			--signal fifo to send data
			sendData:='1';
			dataOutReady<='0';
		elsif (sendData='1') and (tmp_outBuffer.empty /='1') and (dataOutHandled_sample = "11" ) then
			fifo_pop(tmp_outBuffer,data_out);
			dataOutReady<='1';
			sendData:='0';
		end if;
		readDataIn_sample<=readDataIn_sample(0) & readDataIn;
		dataOutHandled_sample<=dataOutHandled_sample(0) & dataOutHandled;
	end if;

	--dataOutReady <=sendData;
	outBuffer<=tmp_outBuffer;
    end process;
end architecture;
