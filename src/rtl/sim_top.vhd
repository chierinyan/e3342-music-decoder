----------------------------------------------------------------------------------
-- Company: Computer Architecture and System Research (CASR), HKU, Hong Kong
-- Engineer: Jiajun Wu, Mo Song
-- 
-- Create Date: 09/09/2022 06:20:56 PM
-- Design Name: system top with a signal generator module
-- Module Name: sys_top - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sim_top is
    Port (  
        clk         : in STD_LOGIC; -- input clock 96kHz
        clr         : in STD_LOGIC; -- input synchronized reset
        adc_data    : in STD_LOGIC_VECTOR(11 DOWNTO 0);
        sout        : out STD_LOGIC;
        led_busy    : out STD_LOGIC
    );
end sim_top;

architecture Behavioral of sim_top is
    component musiccode_top is
        port (ain : in std_logic_vector(11 downto 0);
              clk : in std_logic;
              clr : in std_logic;
              sout : out std_logic;
              led  : out std_logic);
    end component musiccode_top;
begin
    musiccode_top_inst : musiccode_top port map(adc_data, clk, clr, sout, led_busy);
end Behavioral;
