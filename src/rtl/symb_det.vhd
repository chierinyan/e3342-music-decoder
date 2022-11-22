library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

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

architecture rtl of symb_det is
    signal squared_adc : std_logic;
    signal squared_adc_buffer : std_logic;
    signal signed_adc : signed(11 downto 0);
    signal note_clk : std_logic := '0';
    signal note_clk_buffer : std_logic := '0';
    signal note_clk_counter : unsigned(11 downto 0) := x"000";

    type state_type is (St_IDEL, St_STARTING, St_WAITING, St_LISTING, St_COUNTING, St_WRITING);
    signal state, next_state : state_type := St_IDEL;

    signal freq_counter : unsigned(7 downto 0);
begin
    signed_adc <= signed(adc_data - x"800");

    sync_process: process(clk, clr)
    begin
        if clr = '1' then
            state <= St_IDEL;
        elsif rising_edge(clk) then
            squared_adc_buffer <= squared_adc;
            note_clk_buffer <= note_clk;

            -- gen note clk
            if note_clk_counter = x"5DB" then -- 1499
                note_clk <= not note_clk;
                note_clk_counter <= x"000";
            else
                note_clk_counter <= note_clk_counter + 1;
            end if;

            state <= next_state;
            case(state) is
                when St_STARTING =>
                    note_clk <= '0';
                    note_clk_counter <= x"000";
                when St_WAITING =>
                    freq_counter <= x"00";
                when St_COUNTING =>
                    freq_counter <= freq_counter + 1;
                when others =>
                    null;
            end case;
        end if;
    end process;

    state_logic: process(state, note_clk, squared_adc)
    begin
        next_state <= state;
        case(state) is
            when St_IDEL =>
                if (squared_adc = '1' and squared_adc_buffer = '0') then
                    next_state <= St_STARTING;
                end if;
            when St_STARTING =>
                if (squared_adc = '1' and squared_adc_buffer = '0') then
                    next_state <= St_WAITING;
                end if;
            when St_WAITING =>
                if (note_clk = '1' and note_clk_buffer = '0') then
                    next_state <= St_LISTING;
                end if;
            when St_LISTING =>
                if (squared_adc = '1' and squared_adc_buffer = '0') then
                    next_state <= St_COUNTING;
                end if;
            when St_COUNTING =>
                if (squared_adc = '1' and squared_adc_buffer = '0') then
                    next_state <= St_WRITING;
                end if;
            when St_WRITING =>
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

            count_int := to_integer(freq_counter);
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

    conv_adc: process(signed_adc)
    begin
        if signed_adc < -233 then
            squared_adc <= '0';
        elsif signed_adc > 233 then
            squared_adc <= '1';
        end if;
    end process;
end rtl;

