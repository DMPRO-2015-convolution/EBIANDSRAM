library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity MemoryManager is
	port (
		clk : in std_logic;
		
		-- EFM override mode
		efm_mode : in boolean;
		
		-- EBI
		ebi_data : in std_logic_vector(15 downto 0);
		ebi_address : in std_logic_vector(18 downto 0);
		ebi_wen, ebi_ren : in std_logic;
		
		-- Daisy
		daisy_data : in std_logic_vector(15 downto 0);
		daisy_valid, daisy_ready : in std_logic;
		
		-- HDMI
		hdmi_ready : in std_logic;
		hdmi_data : out std_logic_vector(23 downto 0);
		
		-- SRAM
		sram1_address : out std_logic_vector(18 downto 0);
		sram1_data : inout std_logic_vector(15 downto 0);
		sram1_ce, sram1_oe, sram1_lb, sram1_ub, sram1_we : out std_logic;
		
		sram2_address : out std_logic_vector(18 downto 0);
		sram2_data : inout std_logic_vector(15 downto 0);
		sram2_ce, sram2_oe, sram2_lb, sram2_ub, sram2_we : out std_logic;
		
end MemoryManager;

architecture Behavioral of MemoryManager is

begin


end Behavioral;

