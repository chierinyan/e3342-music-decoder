library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity myuart is
    Port (
           din : in STD_LOGIC_VECTOR (7 downto 0);
           busy: out STD_LOGIC;
           wen : in STD_LOGIC;
           sout : out STD_LOGIC;
           clr : in STD_LOGIC;
           clk : in STD_LOGIC);
end myuart;

architecture rtl of myuart is
    type state_type is (S_IDLE, S_STARTBIT, S_D0, S_D1, S_D2, S_D3, S_D4, S_D5, S_D6, S_D7, S_STOPBIT, IDLE);
    -- define your signals here

begin

-- Your FSM here

-- Generate 9600 Baud based on 96k clock (1:10)
PROC_BAUD_GEN: process(clk)
begin

end process;

end rtl;

