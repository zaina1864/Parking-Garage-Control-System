-- Parking Garage Control System Top-Level VHDL Design
-- This design monitors vehicle entry/exit using ultrasonic sensors,
-- updates car count, and displays the result using 7-segment displays.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ParkingSystem is
    Port (
        pulse_pin_entry   : in STD_LOGIC;                      -- Echo from entry sensor
        led_enter         : out STD_LOGIC;                     -- LED on vehicle entry
        trigger_pin_entry : out STD_LOGIC;                     -- Trigger for entry sensor

        pulse_pin_exit    : in STD_LOGIC;                      -- Echo from exit sensor
        led_exit          : out STD_LOGIC;                     -- LED on vehicle exit
        led_full          : out STD_LOGIC;                     -- LED when garage is full
        trigger_pin_exit  : out STD_LOGIC;                     -- Trigger for exit sensor

        clk               : in STD_LOGIC;                      -- Clock input
        ones              : out STD_LOGIC_VECTOR(6 downto 0);  -- 7-segment: ones digit
        tens              : out STD_LOGIC_VECTOR(6 downto 0)   -- 7-segment: tens digit
    );
end ParkingSystem;

architecture Behavioral of ParkingSystem is

    -- Component declarations
    COMPONENT Range_sensor_module
        PORT(
            fpga_clk     : IN std_logic;
            pulse        : IN std_logic;
            led_out      : OUT std_logic;
            trigger_out  : OUT std_logic;
            cars_detected: OUT std_logic
        );
    END COMPONENT;

    COMPONENT VehicleCounter
        Port (
            clk            : in STD_LOGIC;
            enable         : in STD_LOGIC;
            reset          : in STD_LOGIC;
            counter_output : out STD_LOGIC_VECTOR (8 downto 0)
        );
    END COMPONENT;

    COMPONENT display7
        PORT (
            value  : IN STD_LOGIC_VECTOR(3 downto 0);
            output : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT BCDConverter
        Port (
            input    : in STD_LOGIC_VECTOR (8 downto 0);
            hundreds : out STD_LOGIC_VECTOR (3 downto 0);
            tens     : out STD_LOGIC_VECTOR (3 downto 0);
            unit     : out STD_LOGIC_VECTOR (3 downto 0)
        );
    END COMPONENT;

    -- Internal signals
    signal car_count       : STD_LOGIC_VECTOR(8 downto 0);
    signal hundreds_bcd    : STD_LOGIC_VECTOR(3 downto 0);
    signal tens_bcd        : STD_LOGIC_VECTOR(3 downto 0);
    signal ones_bcd        : STD_LOGIC_VECTOR(3 downto 0);
    signal led1_signal     : STD_LOGIC;
    signal led2_signal     : STD_LOGIC;
    signal enter1          : STD_LOGIC;
    signal exit1           : STD_LOGIC;
    signal counter_clock   : STD_LOGIC;
    signal enable          : STD_LOGIC;

begin

    -- Entry Ultrasonic Sensor Module
    ultrasonic_entry : Range_sensor_module
        PORT MAP (
            fpga_clk     => clk,
            pulse        => pulse_pin_entry,
            led_out      => led1_signal,
            trigger_out  => trigger_pin_entry,
            cars_detected=> enter1
        );

    -- Exit Ultrasonic Sensor Module
    ultrasonic_exit : Range_sensor_module
        PORT MAP (
            fpga_clk     => clk,
            pulse        => pulse_pin_exit,
            led_out      => led2_signal,
            trigger_out  => trigger_pin_exit,
            cars_detected=> exit1
        );

    -- Vehicle Counter Logic
    car_counter : VehicleCounter
        port map (
            clk            => counter_clock,
            enable         => enable,
            reset          => '1',
            counter_output => car_count
        );

    -- BCD Converter for 2-digit display
    toBCD : BCDConverter
        PORT MAP (
            input    => car_count,
            hundreds => hundreds_bcd,
            tens     => tens_bcd,
            unit     => ones_bcd
        );

    -- Display for ones digit
    ones_display7 : display7
        PORT MAP (
            value  => ones_bcd,
            output => ones
        );

    -- Display for tens digit
    tens_display7 : display7
        PORT MAP (
            value  => tens_bcd,
            output => tens
        );

    -- Control Logic Process
    process(clk)
    begin
        if rising_edge(clk) then
            -- Exit detected
            if exit1 = '1' then
                led_enter <= '0';
                led_exit  <= '1';
                enable    <= '0';

            -- Entry detected
            elsif enter1'event and enter1 = '1' then
                led_enter <= '1';
                led_exit  <= '0';
                enable    <= '1';
            end if;

            -- Full Garage Check (30 cars max assumed = 11110 binary)
            if car_count = "00011110" then
                led_full <= '1';
            else
                led_full <= '0';
            end if;

            -- Generate clock for vehicle counter based on activity
            counter_clock <= enter1 OR exit1;
        end if;
    end process;

end Behavioral;
