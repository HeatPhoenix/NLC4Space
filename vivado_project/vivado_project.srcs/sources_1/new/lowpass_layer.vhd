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

use work.common_package.all;


entity lowpass_layer is
    generic (
            NUM_BITS_PIXEL  : natural := 8; -- 24 total = R + G + B (8-bits each)  
            NUM_BITS_FIXED_INT : integer := NUM_BITS_FIXED_INT_package;
            NUM_BITS_FIXED_FRAC : integer := NUM_BITS_FIXED_FRAC_package;
            NUM_BITS_ADDR   : natural := 8;           
            MAX_IMG_WIDTH   : natural := 64;
            MAX_IMG_HEIGHT   : natural := 64
            );
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           lowpass_layer_enable : in STD_LOGIC;
           spike_inputs_in : in SFIXED_VECTOR(MAX_IMG_WIDTH*MAX_IMG_HEIGHT downto 0);
           filtered_outputs_out : out SFIXED_VECTOR(MAX_IMG_WIDTH*MAX_IMG_HEIGHT downto 0)
           );
end lowpass_layer;



architecture Behavioral of lowpass_layer is

component lowpass_cell
    generic (
            NUM_BITS_PIXEL  : natural := 8; -- 24 total = R + G + B (8-bits each)  
            NUM_BITS_FIXED_INT : integer := 4;
            NUM_BITS_FIXED_FRAC : integer := -11;
            NUM_BITS_ADDR   : natural := 8;           
            MAX_IMG_WIDTH   : natural := 64;
            MAX_IMG_HEIGHT   : natural := 64
            );
    Port ( rst : in STD_LOGIC;
           clk : in std_logic;
           lowpass_enable : in std_logic;
           spike_input : in sfixed (NUM_BITS_FIXED_INT_package downto NUM_BITS_FIXED_FRAC_package);
           filtered_output : out sfixed (NUM_BITS_FIXED_INT_package downto NUM_BITS_FIXED_FRAC_package)
           );
end component;       


signal lowpass_enable : std_logic := '0';

begin


GEN_LPC: 
   for I in 0 to MAX_IMG_WIDTH*MAX_IMG_HEIGHT generate
      lowpass_cells : lowpass_cell port map
        (rst => rst,
        clk => clk,
        lowpass_enable => lowpass_layer_enable,
        spike_input => spike_inputs_in(I), 
        filtered_output => filtered_outputs_out(I)
        );
   end generate GEN_LPC;

-- input process
process(clk, rst) is
begin
    if rst = '1' then 
    elsif rising_edge(clk) then
    
    end if;
end process;

-- output process

end Behavioral;
