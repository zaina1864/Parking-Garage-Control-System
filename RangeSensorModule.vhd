-- Ultrasonic Sensor Interface Module
-- Generates trigger signal and measures echo pulse to detect car presence.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RangeSensorModule is
    Port (
        fpga_clk      : in  STD_LOGIC;                    -- Main clock input
        pulse         : in  STD_LOGIC;                    -- Echo signal from ultrasonic sensor
        led_out       : out STD_LOGIC;                    -- LED indicator (object detected)
        trigger_out   : out STD_LOGIC;                    -- Trigger signal to ultrasonic sensor
        cars_detected : out STD_LOGIC                     -- Output signal if car is detected
    );
end RangeSensorModule;

architecture Behavioral of RangeSensorModule is

    -- Component: Trigger signal generator
    COMPONENT TriggerGenerator
        PORT(
            clk     : IN  std_logic;
            trigger : OUT std_logic
        );
    END COMPONENT;

    -- Component: Pulse width calculator for distance measurement
    COMPONENT DistanceCalculation
        PORT(
            clk               : IN  std_logic;
            calculation_reset : IN  std_logic;
            pulse             : IN  std_logic;
            led_output        : OUT std_logic;
            distance          : BUFFER std_logic_vector(8 downto 0);
            cars_detected     : OUT std_logic
        );
    END COMPONENT;

    -- Internal signals
    signal distance_out : std_logic_vector(8 downto 0);
    signal trig_out     : std_logic;

begin

    -- Instantiate the Trigger Generator
    trig_generator : TriggerGenerator
        PORT MAP (
            clk     => fpga_clk,
            trigger => trig_out
        );

    -- Instantiate the Distance Calculator
    pulse_width : DistanceCalculation
        PORT MAP (
            clk               => fpga_clk,
            calculation_reset => trig_out,
            pulse             => pulse,
            led_output        => led_out,
            distance          => distance_out,
            cars_detected     => cars_detected
        );

    -- Pass trigger signal to the output port
    trigger_out <= trig_out;

end Behavioral;
