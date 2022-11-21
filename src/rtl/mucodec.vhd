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
    signal note_order : std_logic := '0';
    signal next_note_order : std_logic := '1';
begin
    led <= note_order;

    sync_process: process (clk, clr)
    begin
        if clr = '1' then
            state <= St_RESET;
        elsif rising_edge(clk) then
            valid_buffer <= valid;
            state <= next_state;
            if valid = '1' then
                note_byte(5 downto 3) <= note_byte(2 downto 0);
                note_byte(2 downto 0) <= din;
                note_order <= next_note_order;
            end if;
        end if;
    end process;

    state_logic: process (valid)
        variable next_byte: std_logic_vector(5 downto 0);
    begin
        if state = St_RESET then
            next_note_order <= '0';
        else
            next_note_order <= note_order;
            if (valid = '1' and valid_buffer = '0') then
                next_note_order <= not note_order;
            end if;
        end if;

        next_byte := note_byte(2 downto 0) & din;
        next_state <= state;
        case(state) is
            when St_RESET =>
                if next_byte = "000111" then
                    next_state <= St_STARTING;
                end if;
            when St_STARTING =>
                if valid = '1' then
                    if note_order = '1' and next_byte = "000111" then
                        next_state <= St_LISTENING;
                    elsif note_order = '0' and din /= "000" then
                        next_state <= St_RESET;
                    end if;
                end if;
            when St_LISTENING =>
                if valid = '1' then
                    if note_order = '1' then
                        case(next_byte) is
                            when "111000" =>
                                next_state <= St_ENDDING;
                            when "010001" | "011001" | "100001" | "101001" | "110001" | "001010" |
                                 "011010" | "100010" | "101010" | "110010" | "001011" | "010011" |
                                 "100011" | "101011" | "110011" | "001100" | "010100" | "011100" |
                                 "101100" | "110100" | "001101" | "010101" | "011101" | "100101" |
                                 "110101" | "001110" | "010110" | "011110" | "100110" | "101110" =>
                                next_state <= St_WRITING;
                            when others =>
                                next_state <= St_ERROR;
                        end case;
                    elsif din = "000" then
                        next_state <= St_ERROR;
                    end if;
                end if;
            when St_ENDDING =>
                if valid = '1' then
                    if note_order = '1' and next_byte = "111000" then
                        next_state <= St_RESET;
                    elsif note_order = '0' and din /= "111" then
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
            when St_RESET =>
                dout <= "10000000";
            when St_ERROR =>
                dout <= "10000001";
                error <= '1';
            when St_STARTING =>
                dout <= "10000010";
            when St_LISTENING =>
                null;
            when St_WRITING =>
                dvalid <= '1';
                case(note_byte) is
                    when "001010" =>
                        dout <= "01000001";
                    when "001011" =>
                        dout <= "01000010";
                    when "001100" =>
                        dout <= "01000011";
                    when "001101" =>
                        dout <= "01000100";
                    when "001110" =>
                        dout <= "01000101";
                    when "010001" =>
                        dout <= "01000110";
                    when "010011" =>
                        dout <= "01000111";
                    when "010100" =>
                        dout <= "01001000";
                    when "010101" =>
                        dout <= "01001001";
                    when "010110" =>
                        dout <= "01001010";
                    when "011001" =>
                        dout <= "01001011";
                    when "011010" =>
                        dout <= "01001100";
                    when "011100" =>
                        dout <= "01001101";
                    when "011101" =>
                        dout <= "01001110";
                    when "011110" =>
                        dout <= "01001111";
                    when "100001" =>
                        dout <= "01010000";
                    when "100010" =>
                        dout <= "01010001";
                    when "100011" =>
                        dout <= "01010010";
                    when "100101" =>
                        dout <= "01010011";
                    when "100110" =>
                        dout <= "01010100";
                    when "101001" =>
                        dout <= "01010101";
                    when "101010" =>
                        dout <= "01010110";
                    when "101011" =>
                        dout <= "01010111";
                    when "101100" =>
                        dout <= "01011000";
                    when "101110" =>
                        dout <= "01011001";
                    when "110001" =>
                        dout <= "01011010";
                    when "110010" =>
                        dout <= "00100001";
                    when "110011" =>
                        dout <= "00101110";
                    when "110100" =>
                        dout <= "00111111";
                    when "110101" =>
                        dout <= "00100000";
                    when others =>
                        dout <= "11111111";
                        dvalid <= '0';
                end case;
            when St_ENDDING =>
                dout <= "10000100";
            when others =>
                dout <= "10000101";
        end case;
    end process;
end rtl;

