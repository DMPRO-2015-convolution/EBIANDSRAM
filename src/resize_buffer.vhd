library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ResizeBuffer is
	port (
		clk : in std_logic;
		data_in : in std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(23 downto 0);
		data_in_valid : in std_logic;
		data_out_valid : out std_logic
	);

end ResizeBuffer;

architecture Behavioral of ResizeBuffer is
	type state_t is (STATE_LAST, STATE_FIRST, STATE_SHIFT);
	signal state : state_t;
	signal stage1, stage2 : std_logic_vector(15 downto 0);
	signal shifted_last_cycle : boolean;
begin

	data_out <=
		stage2 & stage1(15 downto 8) when state = STATE_FIRST else
		stage2(7 downto 0) & stage1 when state = STATE_LAST else
		x"000000";
		
	data_out_valid <= '1' when shifted_last_cycle and state /= STATE_SHIFT else '0';

	process(clk) begin
		if rising_edge(clk) then
			if data_in_valid = '1' then
			
				-- Update state
				case state is
					when STATE_FIRST =>
						state <= STATE_LAST;
					when STATE_LAST =>
						state <= STATE_SHIFT;
					when STATE_SHIFT =>
						state <= STATE_FIRST;
				end case;

				-- Shift in new value
				stage2 <= stage1;
				stage1 <= data_in;
				
				shifted_last_cycle <= true;
			else
				shifted_last_cycle <= false;
			end if;
		end if;
	end process;

end Behavioral;

