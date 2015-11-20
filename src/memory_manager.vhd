library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity memory_manager is
	generic (
		IMAGE_WIDTH : integer := 640;
		IMAGE_HEIGHT : integer := 480
	);
	port (
		clk : in std_logic;
		
		-- EFM override mode
		efm_mode, reset : in boolean;
		
		-- EBI
		ebi_data : inout std_logic_vector(15 downto 0);
		ebi_address : in std_logic_vector(18 downto 0);
		ebi_wen, ebi_ren : in std_logic;
		
		-- Daisy (active low? active high?)
		daisy_data : in std_logic_vector(15 downto 0);
		daisy_valid : in std_logic;
		daisy_ready : out std_logic;
		
		-- HDMI
		hdmi_ready, hdmi_clk : in std_logic; -- active high?
		hdmi_data : out std_logic_vector(23 downto 0);
		
		-- SRAM
		sram1_address : out std_logic_vector(18 downto 0);
		sram1_data : inout std_logic_vector(15 downto 0);
		sram1_ce, sram1_oe, sram1_we : out std_logic;
		
		sram2_address : out std_logic_vector(18 downto 0);
		sram2_data : inout std_logic_vector(15 downto 0);
		sram2_ce, sram2_oe, sram2_we : out std_logic
	);
end memory_manager;

architecture Behavioral of memory_manager is
	type chip_t is (CHIP_SRAM1, CHIP_SRAM2);
	type state_t is (STATE_SETUP, STATE_WRITE);
	
	signal efm_controlled : boolean;

	signal daisy_address : unsigned(18 downto 0);
	signal hdmi_address : unsigned(18 downto 0) := to_unsigned(0, 19);
	
	signal sram_read_data : std_logic_vector(15 downto 0);
	signal sram_data_valid : std_logic;
	signal hdmi_fifo_full : std_logic;
	signal hdmi_fifo_input : std_logic_vector(23 downto 0);
	signal hdmi_fifo_input_valid : std_logic;

	signal write_chip : chip_t;
	signal state : state_t;
begin

	efm_controlled <= efm_mode and (ebi_wen = '0' or ebi_ren = '0');

	resize_buffer: entity work.ResizeBuffer
		port map (
			clk => clk,
			data_in => sram_read_data,
			data_out => hdmi_fifo_input,
			data_in_valid => sram_data_valid,
			data_out_valid => hdmi_fifo_input_valid
		);

	-- HDMI FIFO
	hdmi_fifo : entity work.pixel_fifo
		port map (
			wr_clk => clk,
			rd_clk => hdmi_clk,
			din => hdmi_fifo_input,
			wr_en => hdmi_fifo_input_valid,
			rd_en => hdmi_ready,
			dout => hdmi_data,
			full => hdmi_fifo_full
		);

	-- SRAM control
	sram1_address <=
			ebi_address when efm_mode else
			std_logic_vector(daisy_address) when write_chip = CHIP_SRAM1 else
			std_logic_vector(hdmi_address);

	sram1_data <=
			ebi_data when ebi_wen = '0' else
			daisy_data when write_chip = CHIP_SRAM1 and state = STATE_WRITE else
			(others => 'Z');
			
	sram1_ce <= '0' when efm_mode or write_chip /= CHIP_SRAM1 or state = STATE_WRITE else '1';
	sram1_oe <= '0' when (not efm_mode and write_chip /= CHIP_SRAM1) or (efm_mode and ebi_ren = '0') else '1';
	sram1_we <= '0' when (not efm_mode and write_chip = CHIP_SRAM1) or (efm_mode and ebi_wen = '0') else '1';
		
	sram2_address <=
			std_logic_vector(daisy_address) when write_chip = CHIP_SRAM2 else
			std_logic_vector(hdmi_address);

	sram2_data <=
			ebi_data when ebi_wen = '0' else
			daisy_data when write_chip = CHIP_SRAM2 and state = STATE_WRITE else
			(others => 'Z');
			
	sram2_ce <= '0' when write_chip /= CHIP_SRAM2 or state = STATE_WRITE else '1';
	sram2_oe <= '0' when write_chip /= CHIP_SRAM2 else '1';
	sram2_we <= '0' when write_chip = CHIP_SRAM2 else '1';
	
	sram_read_data <= sram1_data when write_chip /= CHIP_SRAM1 else sram2_data;

	-- EBI control
	ebi_data <=
			sram1_data when efm_mode and ebi_ren = '0' else
			(others => 'Z');

	daisy_ready <= '1' when state = STATE_SETUP else '0';

	process(clk) begin
		if rising_edge(clk) then

			-- Synchronous reset
			if reset then
				daisy_address <= to_unsigned(0, 19);
				state <= STATE_SETUP;
			else
				
				-- Handle write cycles
				case state is
					when STATE_SETUP =>
						if daisy_valid = '1' then
							state <= STATE_WRITE;
						end if;
					when STATE_WRITE =>
						state <= STATE_SETUP;
						if daisy_address = IMAGE_HEIGHT * IMAGE_WIDTH - 1 then
							daisy_address <= to_unsigned(0, 19);
						else
							daisy_address <= daisy_address + 1;
						end if;
				end case;
			end if;
			
			if hdmi_address = IMAGE_HEIGHT * IMAGE_WIDTH - 1 then
				hdmi_address <= to_unsigned(0, 19);
			elsif hdmi_fifo_full = '1' then
				hdmi_address <= hdmi_address + 1;
			end if;

		end if;
	end process;


end Behavioral;

