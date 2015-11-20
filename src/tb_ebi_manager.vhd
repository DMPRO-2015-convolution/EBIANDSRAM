LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_ebi_manager IS
END tb_ebi_manager;
 
ARCHITECTURE behavior OF tb_ebi_manager IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ebi_manager
    PORT(
         clk : IN  std_logic;
         ebi_address : IN  std_logic_vector(1 downto 0);
         ebi_data : IN  std_logic_vector(15 downto 0);
         fifo_valid : IN  std_logic;
         fifo_ready : OUT  std_logic;
         daisy_reset : OUT  boolean;
         efm_mode : OUT  boolean;
         control_valid : OUT  boolean;
         control_data : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal ebi_address : std_logic_vector(1 downto 0) := (others => '0');
   signal ebi_data : std_logic_vector(15 downto 0) := (others => '0');
   signal fifo_valid : std_logic := '0';

 	--Outputs
   signal fifo_ready : std_logic;
   signal daisy_reset : boolean;
   signal efm_mode : boolean;
   signal control_valid : boolean;
   signal control_data : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ebi_manager PORT MAP (
          clk => clk,
          ebi_address => ebi_address,
          ebi_data => ebi_data,
          fifo_valid => fifo_valid,
          fifo_ready => fifo_ready,
          daisy_reset => daisy_reset,
          efm_mode => efm_mode,
          control_valid => control_valid,
          control_data => control_data
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;


		-- Check ready signal
		assert fifo_ready = '1'
			report "fifo_ready should be '1'"
			severity failure;
			
		-- Check if data is passed through to daisy
		ebi_address <= "00";
		ebi_data <= x"DEAD";
		
		wait for clk_period;
		
		assert ebi_data = control_data
			report "ebi_data should be put through to control_data"
			severity failure;
		
		-- Check daisy reset signal
		
		assert not daisy_reset
			report "daisy_reset should not be set when writing to address 0"
			severity failure;		
		
		ebi_address <= "01";
		
		assert not daisy_reset
			report "daisy_reset should not be set when writing to address 1"
			severity failure;
		
		ebi_address <= "10";
		wait for clk_period;
		
		assert daisy_reset
			report "daisy_reset should be enabled when writing to address 2"
			severity failure;
			
		ebi_address <= "11";
		
		wait for clk_period;
		
		assert not daisy_reset
			report "daisy_reset should not be set when writing to address 3"
			severity failure;
			
			
		-- Check EFM mode override 
		
		assert not efm_mode
			report "efm_mode should initially be false"
			severity failure;
			
		fifo_valid <= '1';
		ebi_address <= "01";
		ebi_data <= x"0001";
		
		wait for clk_period;
		
		assert efm_mode
			report "efm_mode should be true after writing 1 to address 1"
			severity failure;
			
		ebi_data <= x"0000";
		
		wait for clk_period;
		
		assert not efm_mode
			report "efm_mode should be false after writing 0 to address 1"
			severity failure;
			
		-- Test control_valid
		fifo_valid <= '1';
		ebi_address <= "00";
		ebi_data <= x"DEAD";
		
		wait for clk_period;
		
		assert control_valid
			report "control_valid should be true when address is 0 and fifo is valid"
			severity failure;
			
		fifo_valid <= '0';
		
		wait for clk_period;
		
		assert not control_valid
			report "control_valid should be false when fifo is not valid"
			severity failure;
			
		-- Test address 1
		fifo_valid <= '1';
		ebi_address <= "01";
		
		wait for clk_period;
		
		assert not control_valid
			report "control_valid should be false when ebi_address is 1"
			severity failure;
			
		fifo_valid <= '0';
		
		wait for clk_period;
		
		assert not control_valid
			report "control_valid should be false when fifo is not valid"
			severity failure;
		
		-- Test address 2
		fifo_valid <= '1';
		ebi_address <= "10";
		
		wait for clk_period;
		
		assert not control_valid
			report "control_valid should be false when ebi_address is 2"
			severity failure;
			
		fifo_valid <= '0';
		
		wait for clk_period;
		
		assert not control_valid
			report "control_valid should be false when fifo is not valid"
			severity failure;
		
		-- Test address 3
		fifo_valid <= '1';
		ebi_address <= "11";
		
		wait for clk_period;
		
		assert not control_valid
			report "control_valid should be false when ebi_address is 3"
			severity failure;
			
		fifo_valid <= '0';
		
		wait for clk_period;
		
		assert not control_valid
			report "control_valid should be false when fifo is not valid"
			severity failure;
			
			
		report "Test success";
		wait;
 
   end process;

END;
