----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/08/2021 11:51:45 PM
-- Design Name: 
-- Module Name: spiking_activation_layer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

entity spiking_activation_layer is
    Port ( conv_buffer_in : in STD_LOGIC_VECTOR (0 downto 0);
           spike_out : in STD_LOGIC_VECTOR (0 downto 0));
end spiking_activation_layer;

architecture Behavioral of spiking_activation_layer is

begin


end Behavioral;
