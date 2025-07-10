library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entity declaration for 7-segment display decoder
ENTITY display7 IS
    PORT (
        value  : IN  STD_LOGIC_VECTOR(3 downto 0);     -- 4-bit binary input (0–9)
        output : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)      -- 7-segment output (a-g)
    );
END display7;

-- Architecture definition
ARCHITECTURE behavior OF display7 IS
BEGIN

    -- Use WITH...SELECT to decode binary to 7-segment format
    -- Segment Mapping: a b c d e f g (bit 6 to bit 0)
    -- '0' means segment ON for common cathode displays
    WITH value SELECT
        output <= 
            "0000001" WHEN "0000",  -- 0
            "1001111" WHEN "0001",  -- 1
            "0010010" WHEN "0010",  -- 2
            "0000110" WHEN "0011",  -- 3
            "1001100" WHEN "0100",  -- 4
            "0100100" WHEN "0101",  -- 5
            "0100000" WHEN "0110",  -- 6
            "0001111" WHEN "0111",  -- 7
            "0000000" WHEN "1000",  -- 8
            "0000100" WHEN "1001",  -- 9
            "1111111" WHEN OTHERS;  -- Blank for undefined values (all segments off)

END behavior;
