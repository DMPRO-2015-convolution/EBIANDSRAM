LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_downsize_buffer IS
END tb_downsize_buffer;
 
ARCHITECTURE behavior OF tb_downsize_buffer IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT downsize_buffer
    PORT(
         clk : IN  std_logic;
			reset : IN boolean;
         data_in : IN  std_logic_vector(23 downto 0);
         data_out : OUT  std_logic_vector(15 downto 0);
         data_in_valid : IN  std_logic;
         data_in_ready : OUT  std_logic;
         data_out_valid : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
	signal reset : boolean  := false;
   signal data_in : std_logic_vector(23 downto 0) := (others => '0');
   signal data_in_valid : std_logic := '0';

 	--Outputs
   signal data_out : std_logic_vector(15 downto 0);
   signal data_in_ready : std_logic;
   signal data_out_valid : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: downsize_buffer PORT MAP (
          clk => clk,
			 reset => reset,
          data_in => data_in,
          data_out => data_out,
          data_in_valid => data_in_valid,
          data_in_ready => data_in_ready,
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
      wait for clk_period;
		
		assert data_out_valid = '0'
			report "Data out valid before data in has been valid"
			severity failure;

		wait for clk_period;

		data_in <= x"ABCDEF";
		data_in_valid <= '1';
		
		wait for clk_period;
		
		data_in_valid <= '0';
		
		assert data_out_valid = '1' and data_out = x"ABCD"
			report "No data even when enough data is present"
			severity failure;
		
		wait for clk_period;
		
		assert data_out_valid = '0'
			report "Outputs data when input data is missing"
			severity failure;
		
		data_in <= x"012345";
		data_in_valid <= '1';
		
		wait for clk_period;
		
		assert data_out_valid = '1' and data_out = x"EF01"
			report "Data not pushed when ready!"
			severity failure;
			
		assert data_in_ready = '0'
			report "Accepting too much data"
			severity failure;
		
		data_in <= x"987676";
		wait for clk_period;
		assert data_out_valid = '1' and data_out = x"2345"
			report "Does not output last word correctly"
			severity failure;

		assert data_in_ready = '1'
			report "Not accepting more data after first denial"
			severity failure;
		
		wait for clk_period;
		
		data_in <= x"000000";
		
		assert data_out_valid = '1' and data_out = x"9876"
			report "Not serving first data after cycle"
			severity failure;

		wait for clk_period;
		
		data_in_valid <= '0';
		
		assert data_out_valid = '1' and data_out = x"7600";

		wait for clk_period;
		
		assert data_out_valid = '1' and data_out = x"0000"
			report "Not serving last data out"
			severity failure;
		
		wait for clk_period;
		
		assert data_out_valid = '0'
			report "Serving more data than available"
			severity failure;

		-- test reset
		data_in <= x"ABABAB";
		data_in_valid <= '1';
		wait for 2*clk_period;
		
		assert data_out_valid = '1'; -- this was tested erlier
		reset <= true;
		wait for clk_period;
		reset <= false;
		
		assert data_out_valid = '0'
			report "Reset not resetting...."
			severity failure;

		report "Test success!"
			severity failure;

   end process;

END;
