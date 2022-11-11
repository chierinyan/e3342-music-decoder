library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity musiccode_top_tb is
end musiccode_top_tb;

architecture tb of musiccode_top_tb is
    component musiccode_top is
        port (ain : in std_logic_vector(11 downto 0);
              clk : in std_logic;
              clr : in std_logic;
              sout : out std_logic);
    end component musiccode_top;

    file file_vectors   : text;

    constant clkperiod  : time := 10 ns;
    constant adc_width  : integer := 12;
    constant sample_len : integer := 180000;

    signal adc_data     : std_logic_vector(11 downto 0);
    signal clk          : std_logic;
    signal clr          : std_logic;
    signal sout         : std_logic;

    signal sample_cnt   : integer := 0;
    signal finished     : std_logic := '0';

    -- sine wave signal
    type wave_array is array (0 to sample_len-1) of std_logic_vector (adc_width-1 downto 0);
    signal input_wave: wave_array;
    type sym_array is array (0 to 15) of std_logic_vector (2 downto 0);
    signal sym_det: sym_array;
begin
    musiccode_top_inst: musiccode_top port map (
        clk => clk,
        clr => clr,
        ain => adc_data,
        sout => sout
    );

    proc_init_array: process
        variable wave_amp   : std_logic_vector(adc_width-1 downto 0);
        variable line_index : integer := 0;
        variable v_iline    : line;
    begin
        file_open(file_vectors, "info_wave.txt", read_mode);
        for i in 0 to (sample_len-1) loop
            readline(file_vectors, v_iline);
            read(v_iline, wave_amp);
            input_wave(i) <= wave_amp;
        end loop;
        wait;
    end process proc_init_array;

    proc_clk: process
    begin
        clk <= '0';
        wait for clkperiod/2;
        clk <= '1';
        wait for clkperiod/2;
    end process proc_clk;

    proc_clr: process
    begin
        clr <= '1', '0' after clkperiod;
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
            elsif (sample_cnt = sample_len - 1) then
                sample_cnt <= 0;
            else
                sample_cnt <= sample_cnt + 1;
            end if;
        end if;
    end process proc_sample_cnt;

    finished <= '1' when sample_cnt = sample_len-1 else '0';
end tb;
