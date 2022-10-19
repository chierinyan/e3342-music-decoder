library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity myuart is
    Port (
           din  : in std_logic_vector (7 downto 0);
           busy : out std_logic;
           wen  : in std_logic;
           sout : out std_logic;
           clr  : in std_logic;
           clk  : in std_logic);
end myuart;

architecture rtl of myuart is
    type state_type is (St_IDLE, St_BUSY);
    signal state, next_state : state_type := St_IDLE;

    signal din_buffer : std_logic_vector (7 downto 0);
    signal bit_seq, baud_timer : unsigned (3 downto 0) := x"0";
begin
    sync_process: process (clk, clr)
    begin
        if clr = '1' then
            state <= St_IDLE;
        elsif rising_edge(clk) then
            state <= next_state;

            if state = St_IDLE then
                bit_seq <= x"0";
                baud_timer <= x"0";
            else
                if wen = '1' then
                    baud_timer <= x"0";
                    bit_seq <= x"0";
                elsif baud_timer = x"9" then
                    baud_timer <= x"0";
                    if bit_seq = x"9" then
                        bit_seq <= x"0";
                    else
                        bit_seq <= bit_seq + 1;
                    end if;
                else
                    baud_timer <= baud_timer + 1;
                end if;
            end if;
        end if;
    end process;

    state_logic: process (wen, baud_timer)
    begin
        next_state <= state;
        case(state) is
            when St_IDLE =>
                if rising_edge(wen) then
                    din_buffer <= din;
                    next_state <= St_BUSY;
                end if;
            when St_BUSY =>
                if bit_seq = x"9" and baud_timer = x"9" then
                    next_state <= St_IDLE;
                end if;
            when others =>
                next_state <= St_IDLE;
        end case;
    end process;

    output_logic: process (state, bit_seq)
    begin
        case(state) is
            when St_IDLE =>
                sout <= '1';
                busy <= '0';
            when St_BUSY =>
                busy <= '1';
                case(bit_seq) is
                    when x"0" | x"9" =>
                        sout <= '0';
                    when x"1" | x"2" | x"3" | x"4" | x"5" | x"6" | x"7" | x"8" =>
                        sout <= din_buffer(to_integer(bit_seq - 1));
                    when others =>
                        null;
                end case;
            when others =>
                null;
        end case;
    end process;
end rtl;

