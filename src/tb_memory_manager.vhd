LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY tb_memory_manager IS
END tb_memory_manager;
 
ARCHITECTURE behavior OF tb_memory_manager IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT memory_manager
    PORT(
         clk : IN  std_logic;
			reset : IN boolean;
         efm_mode : IN  boolean;
         ebi_data : INOUT  std_logic_vector(15 downto 0);
         ebi_address : IN  std_logic_vector(18 downto 0);
         ebi_wen : IN  std_logic;
         ebi_ren : IN  std_logic;
         daisy_data : IN  std_logic_vector(15 downto 0);
         daisy_valid : IN  std_logic;
         daisy_ready : OUT  std_logic;
         hdmi_ready : IN  std_logic;
			hdmi_clk : IN std_logic;
         hdmi_data : OUT  std_logic_vector(23 downto 0);
         sram1_address : OUT  std_logic_vector(18 downto 0);
         sram1_data : INOUT  std_logic_vector(15 downto 0);
         sram1_ce : OUT  std_logic;
         sram1_oe : OUT  std_logic;
         sram1_we : OUT  std_logic;
         sram2_address : OUT  std_logic_vector(18 downto 0);
         sram2_data : INOUT  std_logic_vector(15 downto 0);
         sram2_ce : OUT  std_logic;
         sram2_oe : OUT  std_logic;
         sram2_we : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
	signal reset : boolean := false;
   signal efm_mode : boolean := true;
   signal ebi_data : std_logic_vector(15 downto 0) := (others => '0');
   signal ebi_address : std_logic_vector(18 downto 0) := (others => '0');
   signal ebi_wen : std_logic := '0';
   signal ebi_ren : std_logic := '0';
   signal daisy_data : std_logic_vector(15 downto 0) := (others => '0');
   signal daisy_valid : std_logic := '0';
   signal daisy_ready : std_logic := '0';
   signal hdmi_ready : std_logic := '0';
	signal hdmi_clk : std_logic := '0';
	
	--BiDirs
   signal sram1_data : std_logic_vector(15 downto 0) := (others => 'Z');
   signal sram2_data : std_logic_vector(15 downto 0) := (others => 'Z');

 	--Outputs
   signal hdmi_data : std_logic_vector(23 downto 0);
   signal sram1_address : std_logic_vector(18 downto 0);
   signal sram1_ce : std_logic;
   signal sram1_oe : std_logic;
   signal sram1_lb : std_logic;
   signal sram1_ub : std_logic;
   signal sram1_we : std_logic;
   signal sram2_address : std_logic_vector(18 downto 0);
   signal sram2_ce : std_logic;
   signal sram2_oe : std_logic;
   signal sram2_lb : std_logic;
   signal sram2_ub : std_logic;
   signal sram2_we : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
	-- number of 16-bit transfers for a whole 640x480 24-bit image
	constant IMAGE_SIZE : integer := 307200;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: memory_manager PORT MAP (
          clk => clk,
			 reset => reset,
          efm_mode => efm_mode,
          ebi_data => ebi_data,
          ebi_address => ebi_address,
          ebi_wen => ebi_wen,
          ebi_ren => ebi_ren,
          daisy_data => daisy_data,
          daisy_valid => daisy_valid,
          daisy_ready => daisy_ready,
          hdmi_ready => hdmi_ready,
			 hdmi_clk => hdmi_clk,
          hdmi_data => hdmi_data,
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
	
	procedure AssertEFMModeOverride is
	begin
		-- Address
		assert sram1_address = ebi_address
			report "SRAM1 address should be EBI address when efm_mode is true"
			severity failure;
			
		-- Data
		assert sram1_data = ebi_data
			report "SRAM1 data should be EBI data when efm_mode is true"
			severity failure;
			
		-- REn
		assert sram1_oe = ebi_ren
			report "SRAM1 OE should be EBI REn when efm_mode is true"
			severity failure;
			
		-- WEn
		assert sram1_we = ebi_wen
			report "SRAM1 WE should be EBI WEn when efm_mode is true"
			severity failure;
			
	end AssertEFMModeOverride;
 
	procedure AssertFirstWriteCycleSRAM1 is
	begin
		-- Check SRAM1 output enable
		assert sram1_oe = '1'
			report "SRAM1 Output enable should be '1' first write cycle"
			severity failure;
			
		-- Check SRAM1 data
		--assert sram1_data = daisy_data
		--	report "SRAM1 data should be the same as daisy data for first write cycle"
		--	severity failure;
			
		-- Check SRAM1 write enable
		assert sram1_we = '0'
			report "SRAM1 Write enable should be '0' on the first write cycle"
			severity failure;
			
		-- Check chip enable
		assert sram1_ce = '1'
			report "SRAM1 Chip enable should be '1' first write cycle"
			severity failure;
	end AssertFirstWriteCycleSRAM1;
	
	procedure AssertFirstWriteCycleSRAM2 is
	begin
		-- Check sram2 output enable
		assert sram2_oe = '1'
			report "sram2 Output enable should be '1' first write cycle"
			severity failure;
			
		-- Check sram2 data
		---assert sram2_data = daisy_data
		---	report "sram2 data should be the same as daisy data for first write cycle"
		---	severity failure;
			
		-- Check sram2 write enable
		assert sram2_we = '0'
			report "sram2 Write enable should be '0' on the first write cycle"
			severity failure;
			
		-- Check chip enable
		assert sram1_ce = '1'
			report "sram2 Chip enable should be '1' first write cycle"
			severity failure;
	end AssertFirstWriteCyclesram2;
	
	procedure AssertSecondWriteCycleSRAM1 is
	begin
		-- Ready should now be disabled
		assert daisy_ready = '0'
			report "daisy_ready should be disabled on the second write cycle"
			severity failure;
		
		-- Check SRAM1 output enable
		assert sram1_oe = '1'
			report "SRAM1 Output enable should be '1' second write cycle"
			severity failure;
			
		-- Check SRAM1 data
		assert sram1_data = daisy_data
			report "SRAM1 data should be the same as daisy data for second write cycle"
			severity failure;
			
		-- Check SRAM1 write enable
		assert sram1_we = '0'
			report "SRAM1 Write enable should be '0' on the second write cycle"
			severity failure;
			
		-- Check chip enable
		assert sram1_ce = '0'
			report "SRAM1 Chip enable should be '0' second write cycle"
			severity failure;
	end AssertSecondWriteCycleSRAM1;
	
	
	procedure AssertSecondWriteCyclesram2 is
	begin
		-- Ready should now be disabled
		assert daisy_ready = '0'
			report "daisy_ready should be disabled on the second write cycle"
			severity failure;
		
		-- Check sram2 output enable
		assert sram2_oe = '1'
			report "sram2 Output enable should be '1' second write cycle"
			severity failure;
			
		-- Check sram2 data
		assert sram2_data = daisy_data
			report "sram2 data should be the same as daisy data for second write cycle"
			severity failure;
			
		-- Check sram2 write enable
		assert sram2_we = '0'
			report "sram2 Write enable should be '0' on the second write cycle"
			severity failure;
			
		-- Check chip enable
		assert sram2_ce = '0'
			report "sram2 Chip enable should be '0' second write cycle"
			severity failure;
	end AssertSecondWriteCyclesram2;
	
	
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		
		-- Test EFM mode override
		efm_mode <= true;
		
		ebi_address <= (others => '0');
		ebi_data <= x"0000";
		ebi_wen <= '0';
		ebi_ren <= '0';
		
		wait for clk_period;
		
		AssertEFMModeOverride;
		
		ebi_address <= (others => '1');
		ebi_data <= x"FFFF";
		-- Wen needs to be low
		ebi_wen <= '0';
		ebi_ren <= '1';
		
		wait for clk_period;
		
		AssertEFMModeOverride;
		
		-- Turn off EFM mode override
		efm_mode <= false;
		ebi_wen <= '0';
		
		
		
		
		-- Test SRAM1 (Assuming data is coming from Daisy)
		-- Reset 
		reset <= true;
		wait for clk_period;
		reset <= false;
		
		
		-- Set valid data from daisy
		daisy_valid <= '1';
		--wait for clk_period;
		
		report "Test store to SRAM1";
		
		-- Testing reading from daisy and storing to SRAM1
		for i in 0 to 127 loop
			-- check SRAM1 address 0
			assert unsigned(sram1_address) = i
				report "Wrong sram1 address"
				severity failure;
				
			-- Should send out ready to daisy
			assert daisy_ready = '1'
				report "Daisy ready should be enabled to read values"
				severity failure;
				
			-- Assume daisy has some valid output
			daisy_data <= std_logic_vector(to_unsigned(i,16));
			
			wait for 1*clk_period/5;
			
			AssertFirstWriteCycleSRAM1;
			
			wait for 4*clk_period/5;
			
			AssertSecondWritecycleSRAM1;
			
			wait for clk_period;
			
		end loop;
		

		wait for clk_period*(IMAGE_SIZE-128)*2;

		
		report "Passed store to SRAM1";
		--wait for clk_period;
		
		--
		-- The memory manager should now switch SRAM
		--
		
		-- Testing reading from daisy and storing to SRAM2
		for i in 0 to IMAGE_SIZE-1 loop
			-- check SRAM1 address 0
			assert unsigned(sram2_address) = i
				report "Wrong sram1 address"
				severity failure;
				
			-- Should send out ready to daisy
			assert daisy_ready = '1'
				report "Daisy ready should be enabled to read values"
				severity failure;
				
			-- Assume daisy has some valid output
			daisy_data <= std_logic_vector(to_unsigned(i,16));
			
			wait for clk_period;
			
			AssertFirstWriteCycleSRAM2;
			
			wait for clk_period;
			
			AssertSecondWritecycleSRAM2;
			
			wait for clk_period;
			
		end loop;

	

		--
		-- Write is finished
		--
		
		daisy_valid <= '0';
		
		wait for clk_period;
		
		-- Daisy ready should be enabled again
		assert daisy_ready = '1'
			report "daisy_ready should be enabled after writing"
			severity failure;
		
		-- SRAM1 status pins should now be disabled
		assert sram1_we = '1'
			report "sram1_we should be '1' after finished writing"
			severity failure;
			
		assert sram1_ce = '1'
			report "sram1_ce should be '1' after finished writing"
			severity failure;
			
		wait for clk_period;
		
		
		--
		-- Test output to HDMI module (Assume HDMI using SRAM2)
		--
		
		-- HDMI requests memory value
		hdmi_ready <= '1';
		
		wait for clk_period;
		
		for i in 0 to IMAGE_SIZE-1 loop
			-- address for SRAM2 should be 0
			assert unsigned(sram2_address) = i
				report "Wrong address for HDMI reading SRAM2"
				severity failure;
				
			-- SRAM2 CE should be enabled
			assert sram2_ce = '0'
				report "sram2_ce should be '0' when hdmi ready is true"
				severity failure;
			
			-- SRAM2 OE should be enabled
			assert sram2_oe = '0'
				report "sram2_oe should be '0' when hdmi ready is true"
				severity failure;
				
			-- SRAM2 WE should be disabled
			assert sram2_we = '1'
				report "sram2_we should be '1' when hdmi is true"
				severity failure;
			
			-- Put data on bus
			sram2_data <= std_logic_vector(to_unsigned(i,16));
			
			wait for clk_period;
					
			-- Check HDMI data
			assert hdmi_data = sram2_data
				report "hdmi_data should be the same data as read from sram2"
				severity failure;
				
		end loop;
		
		
		
		-- Disable hdmi ready signal
		hdmi_ready <= '1';
		
		wait for clk_period*10;


		--
		-- Should now write to SRAM1
		--
		
		-- Set valid data from daisy
		daisy_valid <= '1';
		
		-- Testing reading from daisy and storing to SRAM1
		for i in 0 to IMAGE_SIZE-1 loop
			-- check SRAM1 address 0
			assert unsigned(sram1_address) = i
				report "Wrong sram1 address"
				severity failure;
				
			-- Should send out ready to daisy
			assert daisy_ready = '1'
				report "Daisy ready should be enabled to read values"
				severity failure;
				
			-- Assume daisy has some valid output
			daisy_data <= std_logic_vector(to_unsigned(i,16));
			
			wait for 1*clk_period/5;
			
			AssertFirstWriteCycleSRAM1;
			
			wait for 4*clk_period/5;
			
			AssertSecondWritecycleSRAM1;
			
			wait for clk_period;
			
		end loop;
		
		
		--
		-- HDMI should now read from SRAM1
		-- 
		
				-- HDMI requests memory value
		hdmi_ready <= '1';
		
		wait for clk_period;
		
		for i in 0 to IMAGE_SIZE-1 loop
			-- address for SRAM1 should be 0
			assert unsigned(sram1_address) = i
				report "Wrong address for HDMI reading sram1"
				severity failure;
				
			-- SRAM1 CE should be enabled
			assert sram1_ce = '0'
				report "sram1_ce should be '0' when hdmi ready is true"
				severity failure;
			
			-- SRAM1 OE should be enabled
			assert sram1_oe = '0'
				report "sram1_oe should be '0' when hdmi ready is true"
				severity failure;
				
			-- SRAM2 WE should be disabled
			assert sram1_we = '1'
				report "sram1_we should be '1' when hdmi ready is true"
				severity failure;
			
			-- Put data on bus
			sram1_data <= std_logic_vector(to_unsigned(i,16));
			
			wait for clk_period;
					
			-- Check HDMI data
			assert hdmi_data = sram1_data
				report "hdmi_data should be the same data as read from sram1"
				severity failure;
				
		end loop;
		
		
		
		wait for clk_period;
		
		
		
		report "Test success";
      wait;
		
   end process;

END;
