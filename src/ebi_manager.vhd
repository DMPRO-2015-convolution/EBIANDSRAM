library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ebi_manager is
	port (
		clk : in std_logic;
		
		-- EBI address and data 
		ebi_address : in std_logic_vector(1 downto 0);
		ebi_data : in std_logic_vector(15 downto 0);
		
		-- FIFO
		fifo_valid : in std_logic;
		fifo_ready : out std_logic;
		
		-- Reset processor
		daisy_reset : out boolean;
		
		-- EFM override mode
		efm_mode : out boolean;
		
		-- Daisy input
		control_valid : out boolean;
		control_data : out std_logic_vector(15 downto 0)
	);
end ebi_manager;

architecture Behavioral of ebi_manager is

	signal efm_mode_reg : boolean;
	
begin

	process (clk) is
	begin
		if rising_edge(clk) then
			if fifo_valid = '1' and ebi_address = "01" then
				efm_mode_reg <= ebi_data(0) = '1';
			end if;
		end if;
	end process;


	-- Send out EFM mode override
	efm_mode <= efm_mode_reg;

	-- Send fifo_valid as control_valid when address is 0
	control_valid <= ebi_address = "00" and fifo_valid = '1';

	-- Send out reset when address is 2
	daisy_reset <= ebi_address = "10";

	-- Feed ebi data through to Daisy
	control_data <= ebi_data;

	-- fifo_ready is set to '1' to always read from fifo
	fifo_ready <= '1';


end Behavioral;

