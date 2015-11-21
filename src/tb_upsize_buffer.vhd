LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_upsize_buffer IS
END tb_upsize_buffer;
 
ARCHITECTURE behavior OF tb_upsize_buffer IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT upsize_buffer
    PORT(
			clk : IN std_logic;
			reset : IN boolean;
         data_in : IN  std_logic_vector(15 downto 0);
         data_out : OUT  std_logic_vector(23 downto 0);
         data_in_valid : IN  std_logic;
         data_out_valid : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
	signal clk : std_logic := '0';
	signal reset : boolean := false;
   signal data_in : std_logic_vector(15 downto 0) := (others => '0');
   signal data_out : std_logic_vector(23 downto 0) := (others => '0');
   signal data_in_valid : std_logic := '0';
   signal data_out_valid : std_logic := '0';
   -- No clocks detected in port list. Replace clk below with 
   -- appropriate port name 
 
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: upsize_buffer PORT MAP (
			clk => clk,
			reset => reset,
          data_in => data_in,
          data_out => data_out,
          data_in_valid => data_in_valid,
          data_out_valid => data_out_valid
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

      data_in <= x"AAAA";
		data_in_valid <= '1';
		
		wait for clk_period;
		
		assert data_out_valid = '0'
			report "Data out should not be valid after one cycle"
			severity failure;
			
		data_in <= x"ABCD";
		
		wait for clk_period;
		
		assert data_out_valid = '1' and data_out = x"AAAAAB"
			report "Data should be valid after two cycles"
			severity failure;
			
		data_in <= x"DEAD";
		
		wait for clk_period;
		
		assert data_out_valid = '1' and data_out = x"CDDEAD"
			report "Data not correct after two cycles"
			severity failure;

		data_in <= x"FFFF";

		wait for clk_period;
		assert data_out_valid = '0'
			report "Cannot output more data than arrived!?"
			severity failure;
		
		data_in <= x"0000";
		
		wait for clk_period;
		assert data_out_valid = '1' and data_out = x"FFFF00"
			report "should output data when available"
			severity failure;
		
		data_in_valid <= '0';
		
		wait for clk_period;
		
		assert data_out_valid = '0'
			report "Should not output data when no data is available..."
			severity failure;


		-- Test reset behaviour
		data_in_valid <= '1';
	    data_in <= x"FFFF";

		wait for 2*clk_period;

		reset <= true;
		wait for clk_period;
		reset <= false;

		assert data_out_valid = '0'
			report "Reset not clearing data"
			severity failure;
			
		report "Test success!"
			severity failure;
   end process;

END;
