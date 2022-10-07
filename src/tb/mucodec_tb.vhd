----------------------------------------------------------------------------------
-- Course: ELEC3342
-- Module Name: mucodec - Behavioral Testbench
-- Project Name: Template for Music Code Decoder for Homework 1
-- Created By: hso
--
-- Copyright (C) 2022 Hayden So
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.env.finish;

entity mucodec_tb is
end mucodec_tb;

architecture tb of mucodec_tb is
    component mucodec is
        port (
            din     : IN std_logic_vector(2 downto 0);
            valid   : IN std_logic;
            clr     : IN std_logic;
            clk     : IN std_logic;
            dout    : OUT std_logic_vector(7 downto 0);
            dvalid  : OUT std_logic;
            error   : OUT std_logic);
    end component;

    signal clk                  : std_logic;
    signal clr                  : std_logic;
    signal din                  : std_logic_vector(2 downto 0);
    signal valid                : std_logic;
    signal dvalid               : std_logic;
    signal error                : std_logic;
    signal dout                 : std_logic_vector(7 downto 0);

    constant clkPeriod : time := 10 us;

begin
    DUT : mucodec PORT MAP(din, valid, clr, clk, dout, dvalid, error);

    clk_process: process begin

        clk <= '0';
        wait for clkPeriod/2;
        clk <= '1';
        wait for clkPeriod/2;

    end process;

    reset_process: process begin
        clr <= '1', '0' after clkPeriod;
        wait;
     end process;

    transition_process: process begin

        -- 0707(32 12 46 46 16 65 13 16 45 46 62)7070  => "LATTE BEST!"

        valid <= '0';

        -- 0707
        wait for 5*clkPeriod;
        valid <= '1', '0' after clkPeriod;
        din <= "000";
        wait for 10*clkPeriod;
        valid <= '1', '0' after clkPeriod;
        din <= "111";
        wait for 10*clkPeriod;
        valid <= '1', '0' after clkPeriod;
        din <= "000";
        wait for 10*clkPeriod;
        valid <= '1', '0' after clkPeriod;
        din <= "111";
        wait for 10*clkPeriod;

                -- L: 4C
                valid <= '1', '0' after clkPeriod;
                din <= "011";
                wait for 10*clkPeriod;
                valid <= '1', '0' after clkPeriod;
                din <= "010";
                wait for 10*clkPeriod;

                -- A: 41
                valid <= '1', '0' after clkPeriod;
                din <= "001";
                wait for 10*clkPeriod;
                valid <= '1', '0' after clkPeriod;
                din <= "010";
                wait for 10*clkPeriod;


                -- T: 54
                valid <= '1', '0' after clkPeriod;
                din <= "100";
                wait for 10*clkPeriod;
                valid <= '1', '0' after clkPeriod;
                din <= "110";
                wait for 10*clkPeriod;

                -- T: 54
                valid <= '1', '0' after clkPeriod;
                din <= "100";
                wait for 10*clkPeriod;
                valid <= '1', '0' after clkPeriod;
                din <= "110";
                wait for 10*clkPeriod;

                -- E: 45
                valid <= '1', '0' after clkPeriod;
                din <= "001";
                wait for 10*clkPeriod;
                valid <= '1', '0' after clkPeriod;
                din <= "110";
                wait for 10*clkPeriod;

                -- Space: 20
                valid <= '1', '0' after clkPeriod;
                din <= "110";
                wait for 10*clkPeriod;
                valid <= '1', '0' after clkPeriod;
                din <= "101";
                wait for 10*clkPeriod;

                -- B: 42
                valid <= '1', '0' after clkPeriod;
                din <= "001";
                wait for 10*clkPeriod;
                valid <= '1', '0' after clkPeriod;
                din <= "011";
                wait for 10*clkPeriod;

                -- E: 45
                valid <= '1', '0' after clkPeriod;
                din <= "001";
                wait for 10*clkPeriod;
                valid <= '1', '0' after clkPeriod;
                din <= "110";
                wait for 10*clkPeriod;

                -- S: 53
                valid <= '1', '0' after clkPeriod;
                din <= "100";
                wait for 10*clkPeriod;
                valid <= '1', '0' after clkPeriod;
                din <= "101";
                wait for 10*clkPeriod;

                -- T: 54
                valid <= '1', '0' after clkPeriod;
                din <= "100";
                wait for 10*clkPeriod;
                valid <= '1', '0' after clkPeriod;
                din <= "110";
                wait for 10*clkPeriod;

                -- !: 21
                valid <= '1', '0' after clkPeriod;
                din <= "110";
                wait for 10*clkPeriod;
                valid <= '1', '0' after clkPeriod;
                din <= "010";
                wait for 10*clkPeriod;

        -- 7070
        valid <= '1', '0' after clkPeriod;
        din <= "111";
        wait for 10*clkPeriod;
        valid <= '1', '0' after clkPeriod;
        din <= "000";
        wait for 10*clkPeriod;
        valid <= '1', '0' after clkPeriod;
        din <= "111";
        wait for 10*clkPeriod;
        valid <= '1', '0' after clkPeriod;
        din <= "000";
        wait for 10*clkPeriod;

        wait;
    end process;

    -- Stop the simulation after 100 cycles
    FINISH : process
    begin
        wait for clkPeriod*400;
        std.env.finish;
    end process;



end tb;
