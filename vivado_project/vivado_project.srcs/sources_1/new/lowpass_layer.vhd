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


entity lowpass_layer is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC);
end lowpass_layer;

architecture Behavioral of lowpass_layer is

begin


end Behavioral;
