-- Architecture for a generic up-counter module
-- Counts up on every rising edge of clk when 'up' is high
-- Resets to zero when reset is low

architecture Behavioral of Counter is
    -- Internal signal to hold the current count value
    signal count : std_logic_vector(n-1 downto 0);
begin
    -- Main process triggered on rising edge of clk or reset
    process(clk, reset)
    begin
        -- Asynchronous reset: reset count to zero when reset is '0'
        if reset = '0' then
            count <= (others => '0');

        -- Synchronous count: increment count when 'up' is '1'
        elsif rising_edge(clk) then
            if up = '1' then
                count <= count + 1;
            end if;
        end if;
    end process;

    -- Assign internal count value to output port
    counter_output <= count;
end Behavioral;
