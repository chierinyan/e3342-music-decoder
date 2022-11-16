library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sys_top is
    Port (  
        clk_100m    : in STD_LOGIC; -- input clock 96kHz
        clr         : in STD_LOGIC; -- input synchronized reset
        csn         : out STD_LOGIC;
        sclk        : out STD_LOGIC;
        sdata       : in STD_LOGIC;
        sout        : out STD_LOGIC;
        led_busy    : out STD_LOGIC
    );
end sys_top;

architecture Behavioral of sys_top is
    component adccntrl is
        Port (  csn : out STD_LOGIC;
                sclk : out STD_LOGIC;
                sdata : in STD_LOGIC;
                data : out STD_LOGIC_VECTOR(11 DOWNTO 0);
                clk : in STD_LOGIC;
                clr : in STD_LOGIC);
    end component adccntrl;
    component clk_wiz_0
        port
        (
            clk_12288k  : out    std_logic;
            -- Status and control signals
            -- reset       : in     std_logic;
            locked      : out    std_logic;
            clk_100m    : in     std_logic
        );
    end component clk_wiz_0;
    component clk_div is
        Port (  clk_in      : in STD_LOGIC;
                locked      : in STD_LOGIC;
                clk_div128  : out STD_LOGIC);
    end component clk_div;
    component musiccode_top is
        port (ain : in std_logic_vector(11 downto 0);
              clk : in std_logic;
              clr : in std_logic;
              sout : out std_logic;
              led  : out std_logic);
    end component musiccode_top;

    signal clk_12288k       : STD_LOGIC;
    signal clk              : STD_LOGIC;
    signal locked           : STD_LOGIC;
    signal adc_data         : STD_LOGIC_VECTOR(11 DOWNTO 0);
begin
    -- if it works, copy to top.vhd
    clk_wiz_inst : clk_wiz_0
        port map ( 
    -- Clock out ports  
        clk_12288k => clk_12288k,
    -- Status and control signals                
        -- reset => clr,
        locked => locked,
        -- Clock in ports
        clk_100m => clk_100m
    );
    
    -- 96kHz clk
    clk_div_128_inst : clk_div port map (
        clk_in => clk_12288k,
        locked => locked,
        clk_div128 => clk
    );
    
    -- real adc
    adc_ctrl_inst: adccntrl port map(
        csn     => csn,
        sclk    => sclk,
        sdata   => sdata,
        data    => adc_data,
        clk     => clk_12288k,
        clr     => clr
    );

    musiccode_top_inst : musiccode_top port map(adc_data, clk, clr, sout, led_busy);
end Behavioral;
