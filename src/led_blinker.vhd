library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Blinks the led in the given pattern.
-- Some usefull patterns in hex:
-- SOS: 0x926664900
-- quick: 0xAAAAAAAA
-- medium: 0xF0F0F0F0
-- long: 0xFFFF0000
-- blink: 0x88888888
-- Occulting: 0x77777777

entity led_blinker is
	port (
		clk : in std_logic;
		led : out std_logic;
		pattern : in std_logic_vector(31 downto 0);
		pattern_wen : in boolean
	);
end led_blinker;

architecture Behavioral of led_blinker is
	signal counter : unsigned(28 downto 0);
	signal saved_pattern : std_logic_vector(31 downto 0);
begin

	process(clk) begin
		if rising_edge(clk) then
			counter <= counter + 1;
			
			if pattern_wen then
				saved_pattern <= pattern;
			end if;
		end if;
	end process;

	led <= saved_pattern(31 - to_integer(counter(28 downto 24)));

end Behavioral;

