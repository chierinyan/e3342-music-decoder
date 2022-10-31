library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity symb_det is
    port (clk: in std_logic; -- input clock 96khz
          clr: in std_logic; -- input synchronized reset
          adc_data: in std_logic_vector(11 downto 0); -- input 12-bit adc data
          symbol_valid: out std_logic;
          symbol_out: out std_logic_vector(2 downto 0) -- output 3-bit detection symbol
          );
end symb_det;

architecture Behavioral of symb_det is
    signal squared_adc : std_logic;
    signal signed_adc : signed(11 downto 0);
    signal note_clk : std_logic := '0';
    signal note_clk_counter : unsigned(11 downto 0) := x"000";

    type state_type is (St_IDEL, St_STARTING, St_WAITING, St_LISTING, St_COUNTING, St_WRITING, St_WROTE);
    signal state, next_state : state_type := St_IDEL;

    signal count : unsigned(7 downto 0);
    signal count_valid : std_logic;

begin
    signed_adc <= signed(adc_data);

    sync_process: process(clk, clr)
    begin
        if clr = '1' then
            state <= St_STARTING;
        elsif rising_edge(clk) then
            state <= next_state;

            case(state) is
                when St_STARTING =>
                    note_clk_counter <= x"000";
                    count <= x"00";
                when St_COUNTING =>
                    count <= count + 1;
                when St_WROTE =>
                    count <= x"00";
                when others =>
                    null;
            end case;

            -- gen note clk
            if note_clk_counter = x"BB7" then
                note_clk <= not note_clk;
                note_clk_counter <= x"000";
            else
                note_clk_counter <= note_clk_counter + 1;
            end if;
        end if;
    end process;

    state_logic: process(state, adc_data, squared_adc, note_clk)
    begin
        next_state <= state;
        case(state) is
            when St_IDEL =>
                if signed_adc < -500 then
                    next_state <= St_STARTING;
                end if;
            when St_STARTING =>
                -- TODO: imporve starting logic
                next_state <= St_WAITING;
            when St_WAITING =>
                if rising_edge(note_clk) then
                    next_state <= St_LISTING;
                end if;
            when St_LISTING =>
                if rising_edge(squared_adc) then
                    next_state <= St_COUNTING;
                end if;
            when St_COUNTING =>
                if rising_edge(squared_adc) then
                    next_state <= St_WRITING;
                end if;
            when St_WRITING =>
                next_state <= St_WROTE;
            when St_WROTE =>
                next_state <= St_WAITING;
            when others =>
                null;
        end case;
    end process;

    output_logic: process(state)
        variable count_int : integer;
    begin
        symbol_valid <= '0';
        if state = St_WRITING then
            symbol_valid <= '1';

            count_int := to_integer(count);
            case(count_int) is
                when 164 to 255 =>
                    symbol_out <= "000";
                when 134 to 163 =>
                    symbol_out <= "001";
                when 109 to 133 =>
                    symbol_out <= "010";
                when 89 to 108 =>
                    symbol_out <= "011";
                when 75 to 88 =>
                    symbol_out <= "100";
                when 61 to 74 =>
                    symbol_out <= "101";
                when 50 to 60 =>
                    symbol_out <= "110";
                when 0 to 49 =>
                    symbol_out <= "111";
                when others =>
                    null;
            end case;
        end if;
    end process;

    conv_adc: process(adc_data)
    begin
        if signed_adc < -233 then
            squared_adc <= '0';
        elsif signed_adc > 233 then
            squared_adc <= '1';
        end if;
    end process;
end Behavioral;

