----------------------------------------------------------------------------------
-- Company: TU Delft, ESA
-- Engineer: Zacharia Rudge
-- 
-- Create Date: 07/21/2021 02:38:31 PM
-- Design Name: 
-- Module Name: lowpass_cell - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Lowpass filters a spiking value coming through using the following
-- formula: y[t-1] + tau * (x[t] - y[t-1])
-- where tau can be any arbitrary value, x is the input and y[t-1] is the previous output
-- y[0] = 0. This is a digital IIR filter. This cell is then duplicated to match the 
-- number needed to form a lowpass filter layer, which is analogous in size to the amount of
-- spiking activation outputs coming from the previous layer.
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

use work.common_package.all;

entity lowpass_cell is
   generic (
            NUM_BITS_PIXEL  : natural := 8; -- 24 total = R + G + B (8-bits each)  
            NUM_BITS_FIXED_INT : integer := 4; --integer part
            NUM_BITS_FIXED_FRAC : integer := -11; --frac
            NUM_BITS_ADDR   : natural := 8;           
            MAX_IMG_WIDTH   : natural := 64;
            MAX_IMG_HEIGHT   : natural := 64
            );
    Port ( rst : in STD_LOGIC;
           clk : in std_logic;
           lowpass_enable : in std_logic;
           spike_input : in sfixed (NUM_BITS_FIXED_INT downto NUM_BITS_FIXED_FRAC);
           filtered_output : out sfixed (NUM_BITS_FIXED_INT downto NUM_BITS_FIXED_FRAC);
           premult_a : out SFIXED_COMMON_SIZE;
           premult_b : out SFIXED_COMMON_SIZE;
           postmult_result : in SFIXED_COMMON_SIZE
           );
end lowpass_cell;

architecture Behavioral of lowpass_cell is

signal prior_output : sfixed(NUM_BITS_FIXED_INT downto NUM_BITS_FIXED_FRAC);
signal tau : sfixed(NUM_BITS_FIXED_INT downto NUM_BITS_FIXED_FRAC) := to_sfixed(0.5, NUM_BITS_FIXED_INT, NUM_BITS_FIXED_FRAC);
signal intermediate_output : sfixed(NUM_BITS_FIXED_INT downto NUM_BITS_FIXED_FRAC);

constant threshold : SFIXED_COMMON_SIZE := to_sfixed_common(0.0); --threshold at zero currently, but in the future could be higher

begin

intermediate_output <=  postmult_result when postmult_result > threshold else
                        to_sfixed_common(0.0);

process(clk, rst) is
begin
    if rst = '1' then
        prior_output <= (others => '0');
        intermediate_output <= (others => '0');
        tau <= to_sfixed(0.5, NUM_BITS_FIXED_INT, NUM_BITS_FIXED_FRAC); -- (value, high downto, low) 
    elsif rising_edge(clk) then
        if lowpass_enable = '1' then
            --intermediate_output <= resize(prior_output + tau * (spike_input - prior_output), intermediate_output'high, intermediate_output'low);
            premult_a <= resize(prior_output + tau, intermediate_output'high, intermediate_output'low);
            premult_a <= resize(spike_input - prior_output, intermediate_output'high, intermediate_output'low);
            -- can we do something clever with shifts here? is there a range for Tau?
            -- yes, we can, if the tau is appropriate for this method
            filtered_output <= intermediate_output;
            prior_output <= intermediate_output;
        end if;
    end if;
end process;


end Behavioral;
