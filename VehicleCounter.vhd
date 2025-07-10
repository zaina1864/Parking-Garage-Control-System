-- Listing 8: Entity for VehicleCounter
entity VehicleCounter is
    Port (
        clk             : in  STD_LOGIC;                      -- Clock signal
        vehicle_detected : in  STD_LOGIC;                      -- Signal indicating vehicle detection (1 = vehicle present)
        reset           : in  STD_LOGIC;                      -- Active low reset signal (reset = '0' clears counter)
        counter_output  : out STD_LOGIC_VECTOR(8 downto 0)    -- 9-bit output for vehicle count
    );
end VehicleCounter;

-- Listing 9: Architecture for VehicleCounter
architecture Behavioral of VehicleCounter is
    signal vehicle_count : unsigned(8 downto 0) := (others => '0'); -- Internal counter signal as unsigned for arithmetic
begin
    process(clk, reset)
    begin
        if reset = '0' then
            vehicle_count <= (others => '0');  -- Reset counter to zero
        elsif rising_edge(clk) then
            if vehicle_detected = '1' then
                -- Increment counter if below max (30 decimal = "11110" binary)
                if vehicle_count < 30 then
                    vehicle_count <= vehicle_count + 1;
                end if;
            else
                -- Decrement counter if above zero
                if vehicle_count > 0 then
                    vehicle_count <= vehicle_count - 1;
                end if;
            end if;
        end if;
    end process;

    counter_output <= std_logic_vector(vehicle_count);  -- Assign internal counter to output port
end Behavioral;
