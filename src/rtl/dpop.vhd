library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dpop is
    port (din        : in std_logic_vector(7 downto 0);
          din_valid  : in std_logic;
          din_error  : in std_logic;
          dout_ready : in std_logic;
          dout       : out std_logic_vector(7 downto 0);
          dout_valid : out std_logic);
end dpop;

architecture rtl of dpop is
begin
    -- TODO
    dout <= din;
    dout_valid <= din_valid and (not din_error);
end rtl;

