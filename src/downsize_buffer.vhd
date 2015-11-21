library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity downsize_buffer is
	port (
		clk : in std_logic;
		reset : in boolean;
		data_in : in std_logic_vector(23 downto 0);
		data_out : out std_logic_vector(15 downto 0);
		data_in_valid : in std_logic;
		data_in_ready : out std_logic;
		data_out_valid : out std_logic
	);

end downsize_buffer;

architecture Behavioral of downsize_buffer is
	type state_t is (STATE_LAST, STATE_SPLIT, STATE_FIRST);
	signal state : state_t;
	signal last_value : std_logic_vector(23 downto 0);
	signal overflow : std_logic_vector(7 downto 0);
	signal can_output : boolean;
begin

	data_out <=
			last_value(23 downto 8) when state = STATE_FIRST else
			overflow & last_value(23 downto 16) when state = STATE_SPLIT else
			last_value(15 downto 0);
		
	data_out_valid <= '1' when can_output else '0';
	data_in_ready <= '1' when state /= STATE_SPLIT else '0';

	process(clk) begin
		if rising_edge(clk) then
		
			if reset then
				state <= STATE_LAST;
				can_output <= false;
			elsif state /= STATE_SPLIT then
				if data_in_valid = '1' then
					-- Shift value
					overflow <= last_value(7 downto 0);
					last_value <= data_in;
					can_output <= true;
					
					-- Continue to next state
					if state = STATE_FIRST then
						state <= STATE_SPLIT;
					else
						state <= STATE_FIRST;
					end if;
				else
					can_output <= false;
				end if;
			else
				state <= STATE_LAST;
			end if;

		end if;
	end process;

end Behavioral;

