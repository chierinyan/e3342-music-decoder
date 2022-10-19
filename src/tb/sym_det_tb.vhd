----------------------------------------------------------------------------------
-- Company: Computer Architecture and System Research (CASR), HKU, Hong Kong
-- Engineer: Jiajun Wu, Mo Song
-- 
-- Create Date: 09/09/2022 06:20:56 PM
-- Design Name: system top
-- Module Name: top - Behavioral
-- Project Name: Music Decoder
-- Target Devices: Xilinx Basys3
-- Tool Versions: Vivado 2022.1
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

use STD.textio.all;
use ieee.std_logic_textio.all;

entity sym_det_tb is
--  Port ( );
end sym_det_tb;

architecture Behavioral of sym_det_tb is
    component symb_det is
        Port (  clk: in STD_LOGIC; -- input clock 96kHz
                clr: in STD_LOGIC; -- input synchronized reset
                adc_data: in STD_LOGIC_VECTOR(11 DOWNTO 0); -- input 12-bit ADC data
                symbol_valid: out STD_LOGIC;
                symbol_out: out STD_LOGIC_VECTOR(2 DOWNTO 0) -- output 3-bit detection symbol
                );
    end component symb_det;

    file file_VECTORS   : text;

    constant clkPeriod  : time := 10 ns;
    constant ADC_WIDTH  : integer := 12;
    constant SAMPLE_LEN : integer := 96000;
    
    signal clk          : std_logic;
    signal clr          : std_logic;
    signal adc_data     : std_logic_vector(11 downto 0);
    signal symbol_valid : std_logic;
    signal symbol_out   : std_logic_vector(2 downto 0);
    signal sample_cnt   : integer := 0;
    signal valid_cnt    : integer := 0;
    signal finished     : std_logic := '0';
    signal finished_st  : std_logic := '0';

    -- sine wave signal
    type wave_array is array (0 to SAMPLE_LEN-1) of std_logic_vector (ADC_WIDTH-1 downto 0);
    signal input_wave: wave_array;
    type sym_array is array (0 to 15) of std_logic_vector (2 downto 0);
    signal sym_det: sym_array;
begin
    
    symb_det_inst: symb_det port map (
        clk => clk,
        clr => clr,
        adc_data => adc_data,
        symbol_valid => symbol_valid,
        symbol_out => symbol_out
    );

    proc_init_array: process
        -- variable input_wave_temp: wave_array;
        variable wave_amp   : std_logic_vector(ADC_WIDTH-1 downto 0);
        variable line_index : integer := 0;
        variable v_ILINE    : line;
    begin
        -- related location
        -- file_open(file_VECTORS, "../../../../info_wave.txt", read_mode);
        file_open(file_VECTORS, "info_wave.txt", read_mode);
        for i in 0 to (SAMPLE_LEN-1) loop
            readline(file_VECTORS, v_ILINE);
            read(v_ILINE, wave_amp);
            input_wave(i) <= wave_amp;
        end loop;
        wait;
    end process proc_init_array;

    -- clock process
    proc_clk: process
    begin
        clk <= '0';
        wait for clkPeriod/2;
        clk <= '1';
        wait for clkPeriod/2;
    end process proc_clk;

    proc_clr: process
    begin
        clr <= '1', '0' after clkPeriod;
        wait;
    end process proc_clr;

    proc_adc_data: process(clk)
    begin
        if rising_edge(clk) then
            if clr = '1' then
                adc_data <= (others=>'0');
            else
                adc_data <= input_wave(sample_cnt);
            end if;
        end if;
    end process proc_adc_data;

    proc_sample_cnt: process(clk)
    begin
        if rising_edge(clk) then
            if clr = '1' then
                sample_cnt <= 0;
            elsif (sample_cnt = SAMPLE_LEN - 1) then 
                sample_cnt <= 0;
            else 
                sample_cnt <= sample_cnt + 1;
            end if;
        end if;
    end process proc_sample_cnt;

--    proc_dout_det: process(clk)
--    begin
--     if rising_edge(clk) then
--         if dvalid = '1' then
--             report (slv'(dout));
--         end if;
--     end if;
--    end process proc_dout_det;

    proc_valid_cnt: process(clk)
    begin
        if rising_edge(clk) then
            if clr = '1' then
                valid_cnt <= 0;
            elsif symbol_valid = '1' and finished_st = '0' then
                sym_det(valid_cnt) <= symbol_out;
                if valid_cnt = 15 then
                    valid_cnt <= 0;
                else 
                    valid_cnt <= valid_cnt + 1;
                end if;
            end if;
        end if;
    end process proc_valid_cnt;

    finished <= '1' when symbol_valid = '1' and valid_cnt = 15 else '0';

    proc_finished_st: process(clk)
    begin
        if rising_edge(clk) then
            if clr = '1' then
                finished_st <= '0';
            elsif finished = '1' then
                finished_st <= '1';
            end if;
        end if;
    end process proc_finished_st;

    proc_check_sym: process(clk)
    begin
        if rising_edge(clk) then
            if symbol_valid = '1' and valid_cnt = 15 then
                for k in 0 to 15 loop
                    report "Symbol index " & integer'image(k) & " is " & integer'image(to_integer(unsigned(sym_det(k))));
                end loop;
            end if;
        end if;
    end process proc_check_sym;

end Behavioral;
