library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DistanceCalculation is
    Port (
        clk              : in STD_LOGIC;
        calculation_reset: inout STD_LOGIC;
        pulse            : in STD_LOGIC;
        led_output       : out STD_LOGIC;
        distance         : out STD_LOGIC_VECTOR(8 downto 0);
        cars_detected    : out STD_LOGIC
    );
end DistanceCalculation;

architecture Behavioral of DistanceCalculation is

    -- Counter component for measuring pulse width
    COMPONENT Counter
        generic(n : positive := 22);
        Port (
            clk : in STD_LOGIC;
            up : in STD_LOGIC;
            reset : in STD_LOGIC;
            counter_output : out STD_LOGIC_VECTOR(n-1 downto 0)
        );
    END COMPONENT;

    signal pulse_width      : std_logic_vector(21 downto 0);
    signal dist_latch       : std_logic_vector(8 downto 0) := (others => '0');
    signal detection_timer  : std_logic_vector(26 downto 0) := (others => '0');
    signal led_latch        : std_logic := '0';

begin

    -- Counter instance to measure pulse width from ultrasonic echo
    counter_pulse: Counter
        generic map(22)
        port map (
            clk            => clk,
            up             => pulse,
            reset          => not calculation_reset,
            counter_output => pulse_width
        );

    -- Distance calculation and car detection logic
    Distance_calculation : process(clk)
        variable Result     : integer;
        variable multiplier : std_logic_vector(23 downto 0);
    begin
        if rising_edge(clk) then
            if pulse = '0' then
                -- Multiply pulse width by 2 (binary "11" = 3)
                multiplier := pulse_width & "00";  -- simple *4 approximation

                -- Extract 9 MSBs to reduce to 9-bit distance
                Result := to_integer(unsigned(multiplier(23 downto 13)));

                -- Clip value if result is too large
                if (Result > 450) then
                    dist_latch <= "111111111";
                    detection_timer <= (others => '0');
                else
                    dist_latch <= std_logic_vector(to_unsigned(Result, 9));

                    -- Car detected if distance between ~2–15 cm
                    if dist_latch > "000000001" and dist_latch < "000001111" then
                        led_latch     <= '1';
                        cars_detected <= '1';
                        detection_timer <= detection_timer + 1;

                        -- Auto-reset detection after ~5 seconds
                        if detection_timer = "11000010011010110010110101" then
                            cars_detected <= '0';
                        end if;
                    end if;
                end if;
            else
                detection_timer <= (others => '0');
            end if;
        end if;

        distance   <= dist_latch;
        led_output <= led_latch;

    end process Distance_calculation;

end Behavioral;
