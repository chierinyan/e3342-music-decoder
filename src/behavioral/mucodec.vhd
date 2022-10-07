LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity mucodec is
    port (
        din     : IN std_logic_vector(2 downto 0);
        valid   : IN std_logic;
        clr     : IN std_logic;
        clk     : IN std_logic;
        dout    : OUT std_logic_vector(7 downto 0);
        dvalid  : OUT std_logic;
        error   : OUT std_logic);
end mucodec;

architecture Behavioral of mucodec is
    type state_type is (St_RESET, St_ERROR, >>Define more states here as needed<<);
    signal state, next_state : state_type := St_RESET;

    -- Define additional signal needed here as needed
begin
    sync_process: process (clk, clr)
    begin
        if clr = '1' then
        -- Your code here
        elsif rising_edge(clk) then
          -- Put your code here

        end if;
    end process;

    state_logic: process (state)
    begin
        -- Next State Logic
        -- Complete the following:
        next_state <= state;
        case(state) is
            when St_RESET =>

            when St_ERROR =>

            -- Put your code here

    end process;

    output_logic: process ()
    begin
      -- Put your code here
    end process;


end Behavioral;

