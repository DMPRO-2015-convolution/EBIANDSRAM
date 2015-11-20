library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Camvolution is
	generic (
		IMAGE_WIDTH : integer := 640;
		IMAGE_HEIGHT : integer := 480
	);
	port (
		sys_clk : in std_logic;
		led : out std_logic;
		sw6, sw7 : in std_logic;
		
		sram1_address : out std_logic_vector(18 downto 0);
		sram1_data : inout std_logic_vector(15 downto 0);
		sram1_ce, sram1_oe, sram1_lb, sram1_ub, sram1_we : out std_logic;
		
		sram2_address : out std_logic_vector(18 downto 0);
		sram2_data : inout std_logic_vector(15 downto 0);
		sram2_ce, sram2_oe, sram2_lb, sram2_ub, sram2_we : out std_logic;

		ebi_wen, ebi_ren, ebi_cs0, ebi_cs1 : in std_logic;
		ebi_address : in std_logic_vector(19 downto 0);
		ebi_data : inout std_logic_vector(15 downto 0)
	);
end Camvolution;

architecture Behavioral of Camvolution is
	signal efm_mode : boolean;
begin

	-- Constant values for memory
	sram1_lb <= '0';
	sram1_ub <= '0';
	sram2_lb <= '0';
	sram2_up <= '0';

	memory_manager : entity work.memory_manager
		generic map (
			IMAGE_WIDTH => IMAGE_WIDTH,
			IMAGE_HEIGHT => IMAGE_HEIGHT
		)
		port map (
			efm_mode => efm_mode,
			ebi_address => ebi_address,
			ebi_data => ebi_data,
			ebi_wen => ebi_wen,
			ebi_ren => ebi_ren,
--			daisy_data =>,
--			daisy_valid =>,
--			hdmi_ready =>,
--			hdmi_data =>,
			sram1_address => sram1_address,
			sram1_data => sram1_data,
			sram1_ce => sram1_ce,
			sram1_oe => sram1_oe,
			sram1_we => sram1_we,
			sram2_address => sram2_address,
			sram2_data => sram2_data,
			sram2_ce => sram2_ce,
			sram2_oe => sram2_oe,
			sram2_we => sram2_we
		);

end Behavioral;

