library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity musiccode_top is
    port (ain : in std_logic_vector(11 downto 0);
          clk : in std_logic;
          clr : in std_logic;
          sout : out std_logic);
end musiccode_top;

architecture rtl of musiccode_top is
    component symb_det is
        port (clk          : in std_logic;
              clr          : in std_logic;
              adc_data     : in std_logic_vector(11 downto 0);
              symbol_valid : out std_logic;
              symbol_out   : out std_logic_vector(2 downto 0));
    end component symb_det;
    component mucodec is
        port (din     : in std_logic_vector(2 downto 0);
              valid   : in std_logic;
              clr     : in std_logic;
              clk     : in std_logic;
              dout    : out std_logic_vector(7 downto 0);
              dvalid  : out std_logic;
              error   : out std_logic);
    end component mucodec;
    component dpop is
        port (din        : in std_logic_vector(7 downto 0);
              din_valid  : in std_logic;
              din_error  : in std_logic;
              dout_ready : in std_logic;
              dout       : out std_logic_vector(7 downto 0);
              dout_valid : out std_logic);
    end component dpop;
    component myuart is
        port (din  : in std_logic_vector (7 downto 0);
              busy : out std_logic;
              wen  : in std_logic;
              sout : out std_logic;
              clr  : in std_logic;
              clk  : in std_logic);
    end component myuart;

    signal symbol_out   : std_logic_vector(2 downto 0);
    signal symbol_valid : std_logic;

    signal mucodec_out  : std_logic_vector(7 downto 0);
    signal mucodec_valid, mucodec_error : std_logic;

    signal dpop_out : std_logic_vector(7 downto 0);
    signal dpop_valid : std_logic;
    signal uart_ready, uart_busy : std_logic;
begin
    uart_ready <= not uart_busy;

    symb_det_inst : symb_det port map(clk, clr, ain, symbol_valid, symbol_out);

    mucodec_inst  : mucodec  port map(symbol_out, symbol_valid, clr, clk,
                                      mucodec_out, mucodec_valid, mucodec_error);

    dpop_inst     : dpop     port map(mucodec_out, mucodec_valid, mucodec_error,
                                      uart_ready, dpop_out, dpop_valid);

    uart_inst     : myuart   port map(dpop_out, uart_busy, dpop_valid, sout, clr, clk);
end rtl;

