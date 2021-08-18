----------------------------------------------------------------------------------
-- Company: TU Delft, ESA
-- Engineer: Zacharia Rudge
-- 
-- Create Date: 07/27/2021 10:34:51 PM
-- Design Name: 
-- Module Name: lowpass_cell_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Tests the lowpass cell by enabling it and inputting a signal for
-- an arbitrary amount of time. Verification can be done by inspecting the output
-- signal from the lowpass cell.
--
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: State is functional
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

entity lowpass_cell_tb is
--  Port ( );
end lowpass_cell_tb;

architecture Behavioral of lowpass_cell_tb is

    constant IMG_WIDTH      : natural := 64;
    constant IMG_HEIGHT     : natural := 64;
    constant NUM_BITS_PIXEL : natural := 8;    
    constant NUM_BITS_ADDR  : natural := 8;
    constant NUM_BITS_COEFF : natural := 16;

    signal rst : std_logic := '0';
    signal clk : std_logic := '0';
    signal input : sfixed (2*NUM_BITS_PIXEL-1 downto -4);
    signal output : sfixed (2*NUM_BITS_PIXEL-1 downto -4);
    
    signal lowpass_enable : std_logic := '0';

begin

uut: entity work.lowpass_cell(Behavioral) 
    generic map (
            NUM_BITS_PIXEL  => 8, -- 24 total = R + G + B (8-bits each)  
            NUM_BITS_ADDR   => 8,           
            MAX_IMG_WIDTH   => 128,
            MAX_IMG_HEIGHT   => 128
            )
    Port map ( 
           rst => rst,
           clk => clk,
           lowpass_enable => lowpass_enable,
           spike_input => input,
           filtered_output => output
           );

clk_proc: process
begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;        
end process;

process	--input process simulation only
begin
    wait until rising_edge(clk);
    rst <= '1';
    lowpass_enable <= '0';
    wait until rising_edge(clk);
    rst <= '0';
    lowpass_enable <= '1';
    input <= to_sfixed(1.5, 2*NUM_BITS_PIXEL-1, -4);
    wait for 20 ns;
    input <= to_sfixed(1.75, 2*NUM_BITS_PIXEL-1, -4);
    wait for 20 ns;
    input <= to_sfixed(0, 2*NUM_BITS_PIXEL-1, -4);
    wait for 100 ns;
    lowpass_enable <= '0';
end process;

end Behavioral;
