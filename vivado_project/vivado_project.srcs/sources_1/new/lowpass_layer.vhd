----------------------------------------------------------------------------------
-- Company: TU Delft, ESA
-- Engineer: Zacharia Rudge
-- 
-- Create Date: 07/21/2021 02:38:31 PM
-- Design Name: 
-- Module Name: lowpass_layer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: The lowpass layer is meant to match the size of the preceding 
-- spiking-activation layer's outputs, serving as this layer's inputs.
-- This layer then populates itself with lowpass cells, which provide filtered 
-- output to the next layer.
--
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Basically nothing yet
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;


entity lowpass_layer is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC);
end lowpass_layer;



architecture Behavioral of lowpass_layer is

component lowpass_cell
    generic (
            NUM_BITS_PIXEL  : natural := 8; -- 24 total = R + G + B (8-bits each)  
            NUM_BITS_FIXED_INT : natural := 4;
            NUM_BITS_FIXED_FRAC : natural := 11;
            NUM_BITS_ADDR   : natural := 8;           
            MAX_IMG_WIDTH   : natural := 64;
            MAX_IMG_HEIGHT   : natural := 64
            );
    Port ( rst : in STD_LOGIC;
           clk : in std_logic;
           lowpass_enable : in std_logic;
           spike_input : in sfixed (2*NUM_BITS_PIXEL-1 downto -4);
           filtered_output : out sfixed (2*NUM_BITS_PIXEL-1 downto -4)
           );
end component;       

begin

GEN_REG: 
   for I in 0 to 3 generate
      lowpass_cells : lowpass_cell port map
        (DIN(I), 
        CLK, 
        RESET, DOUT(I));
   end generate GEN_REG;


end Behavioral;
