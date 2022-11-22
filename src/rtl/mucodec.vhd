library ieee;
use ieee.std_logic_1164.all;

entity mucodec is
    port (
        din    : in std_logic_vector(2 downto 0);
        valid  : in std_logic;
        clr    : in std_logic;
        clk    : in std_logic;
        led    : out std_logic;
        dout   : out std_logic_vector(7 downto 0);
        dvalid : out std_logic;
        error  : out std_logic);
end mucodec;

architecture rtl of mucodec is
    type state_type is (St_RESET, St_ERROR, St_STARTING , St_LISTENING, St_WRITING, St_ENDDING);
    signal state, next_state : state_type := St_RESET;

    signal valid_buffer : std_logic;
    signal note_byte : std_logic_vector(5 downto 0);
    signal note_order, note_order_buffer : std_logic := '1';
begin
    led <= note_order;

    sync_process: process (clk, clr)
    begin
        if clr = '1' then
            state <= St_RESET;
        elsif rising_edge(clk) then
            note_order_buffer <= note_order;
            state <= next_state;

            if (valid = '1' and valid_buffer = '0') then
                note_byte <= note_byte(2 downto 0) & din;
                if state = St_RESET then
                    note_order <= '1';
                else
                    note_order <= not note_order;
                end if;
            end if;
            valid_buffer <= valid;
        end if;
    end process;

    state_logic: process (note_byte, state)
    begin
        next_state <= state;
        case(state) is
            when St_RESET =>
                if note_byte = o"07" then
                    next_state <= St_STARTING;
                end if;
            when St_STARTING =>
                if (note_order = '1' and note_order_buffer = '0') then
                    if note_byte = o"07" then
                        next_state <= St_LISTENING;
                    else
                        next_state <= St_RESET;
                    end if;
                end if;
            when St_LISTENING =>
                if (note_order = '1' and note_order_buffer = '0') then
                    if note_byte = o"70" then
                        next_state <= St_ENDDING;
                    else
                        next_state <= St_WRITING;
                    end if;
                end if;
            when St_ENDDING =>
                if (note_order = '1' and note_order_buffer = '0') then
                    if note_byte = o"70" then
                        next_state <= St_RESET;
                    else
                        next_state <= St_ERROR;
                    end if;
                end if;
            when St_ERROR =>
                next_state <= St_RESET;
            when St_WRITING =>
                next_state <= St_LISTENING;
            when others =>
                null;
        end case;
    end process;

    output_logic: process (state)
    begin
        error <= '0';
        dvalid <= '0';
        case(state) is
            when St_ERROR => error <= '1';
            when St_WRITING =>
                dvalid <= '1';
                case(note_byte) is
                    when o"00" => dout <= "00110000";
                    when o"01" => dout <= "00110001";
                    when o"02" => dout <= "00110010";
                    when o"03" => dout <= "00110011";
                    when o"04" => dout <= "00110100";
                    when o"05" => dout <= "00110101";
                    when o"06" => dout <= "00110110";
                    when o"10" => dout <= "00001010";
                    when o"11" => dout <= "00001001";
                    when o"12" => dout <= "01000001";
                    when o"13" => dout <= "01000010";
                    when o"14" => dout <= "01000011";
                    when o"15" => dout <= "01000100";
                    when o"16" => dout <= "01000101";
                    when o"17" => dout <= "00101011";
                    when o"20" => dout <= "01000000";
                    when o"21" => dout <= "01000110";
                    when o"22" => dout <= "00111010";
                    when o"23" => dout <= "01000111";
                    when o"24" => dout <= "01001000";
                    when o"25" => dout <= "01001001";
                    when o"26" => dout <= "01001010";
                    when o"27" => dout <= "00101101";
                    when o"30" => dout <= "00100011";
                    when o"31" => dout <= "01001011";
                    when o"32" => dout <= "01001100";
                    when o"33" => dout <= "00111011";
                    when o"34" => dout <= "01001101";
                    when o"35" => dout <= "01001110";
                    when o"36" => dout <= "01001111";
                    when o"37" => dout <= "00101010";
                    when o"40" => dout <= "00100100";
                    when o"41" => dout <= "01010000";
                    when o"42" => dout <= "01010001";
                    when o"43" => dout <= "01010010";
                    when o"44" => dout <= "01011011";
                    when o"45" => dout <= "01010011";
                    when o"46" => dout <= "01010100";
                    when o"47" => dout <= "00101111";
                    when o"50" => dout <= "00100101";
                    when o"51" => dout <= "01010101";
                    when o"52" => dout <= "01010110";
                    when o"53" => dout <= "01010111";
                    when o"54" => dout <= "01011000";
                    when o"55" => dout <= "01011101";
                    when o"56" => dout <= "01011001";
                    when o"57" => dout <= "01011110";
                    when o"60" => dout <= "00100110";
                    when o"61" => dout <= "01011010";
                    when o"62" => dout <= "00100001";
                    when o"63" => dout <= "00101100";
                    when o"64" => dout <= "00111111";
                    when o"65" => dout <= "00100000";
                    when o"66" => dout <= "01011111";
                    when o"67" => dout <= "00111101";
                    when o"71" => dout <= "00110111";
                    when o"72" => dout <= "00111000";
                    when o"73" => dout <= "00111001";
                    when o"74" => dout <= "00111100";
                    when o"75" => dout <= "00111110";
                    when o"76" => dout <= "00101000";
                    when o"77" => dout <= "00101001";
                    when others => null;
                end case;
            when others => null;
        end case;
    end process;
end rtl;

