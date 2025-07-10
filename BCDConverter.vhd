library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;     -- For arithmetic operations
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BCDConverter is
    Port (
        input    : in  STD_LOGIC_VECTOR (8 downto 0); -- 9-bit binary input (0 to 511)
        hundreds : out STD_LOGIC_VECTOR (3 downto 0); -- BCD digit: hundreds place
        tens     : out STD_LOGIC_VECTOR (3 downto 0); -- BCD digit: tens place
        unit     : out STD_LOGIC_VECTOR (3 downto 0)  -- BCD digit: units place
    );
end BCDConverter;

architecture Behavioral of BCDConverter is
begin

    process(input)
        variable i   : integer := 0;
        variable bcd : std_logic_vector(20 downto 0); -- [hundreds][tens][units][input]
    begin
        -- Initialize entire BCD register to 0
        bcd := (others => '0');

        -- Load the binary input into the lower 9 bits
        bcd(8 downto 0) := input;

        -- Double Dabble algorithm: shift left and add 3 if digit >= 5
        for i in 0 to 8 loop
            -- If units (bits 12–9) >= 5, add 3
            if bcd(12 downto 9) > "0100" then
                bcd(12 downto 9) := bcd(12 downto 9) + "0011";
            end if;

            -- If tens (bits 16–13) >= 5, add 3
            if bcd(16 downto 13) > "0100" then
                bcd(16 downto 13) := bcd(16 downto 13) + "0011";
            end if;

            -- If hundreds (bits 20–17) >= 5, add 3
            if bcd(20 downto 17) > "0100" then
                bcd(20 downto 17) := bcd(20 downto 17) + "0011";
            end if;

            -- Shift all bits left by 1
            bcd(20 downto 1) := bcd(19 downto 0);
            bcd(0) := '0';
        end loop;

        -- Assign the BCD digits to output ports
        hundreds <= bcd(20 downto 17);
        tens     <= bcd(16 downto 13);
        unit     <= bcd(12 downto 9);
    end process;

end Behavioral;
