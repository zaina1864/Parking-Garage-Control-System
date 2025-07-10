-- TriggerGenerator: Generates a 100 µs pulse every 250 ms using a counter

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- Optional if arithmetic operations used

architecture Behavioral of TriggerGenerator is

    -- Component declaration for the generic counter
    COMPONENT Counter
        generic(n : positive := 24);
        Port (
            clk            : in  STD_LOGIC;
            up             : in  STD_LOGIC;
            reset          : in  STD_LOGIC;
            counter_output : out STD_LOGIC_VECTOR(n-1 downto 0)
        );
    END COMPONENT;

    -- Signals for reset and output of the counter
    signal reset_counter   : std_logic;
    signal output_counter  : std_logic_vector(23 downto 0);

begin

    -- Instantiate the 24-bit counter
    trig : Counter
        generic map(24)
        port map(
            clk            => clk,
            up             => '1',  -- Always counting
            reset          => reset_counter,
            counter_output => output_counter
        );

    -- Process to generate 100 µs trigger pulse every 250 ms
    process(clk)
        -- 250 ms in clock cycles (assumes 50 MHz clock => 1 cycle = 20 ns)
        constant ms250             : std_logic_vector(23 downto 0) := "101111101011110000100000";  -- 12,500,000
        constant ms250_plus_100us  : std_logic_vector(23 downto 0) := "101111101100111110101000";  -- 12,505,000
    begin
        -- Generate trigger pulse between 250 ms and 250.1 ms
        if (output_counter > ms250 and output_counter < ms250_plus_100us) then
            trigger <= '1';
        else
            trigger <= '0';
        end if;

        -- Reset counter after 250.1 ms or if corrupted value occurs
        if (output_counter = ms250_plus_100us or output_counter = "XXXXXXXXXXXXXXXXXXXXXXXX") then
            reset_counter <= '0';  -- Reset counter
        else
            reset_counter <= '1';  -- Continue counting
        end if;
    end process;

end Behavioral;
