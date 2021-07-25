----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/21/2021 02:38:31 PM
-- Design Name: 
-- Module Name: lowpass_cell - Behavioral
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

entity lowpass_cell is
    Port ( spike_input : in STD_LOGIC_VECTOR (16 downto 0);
           filtered_output : out STD_LOGIC_VECTOR (16 downto 0);
           rst : in STD_LOGIC;
           clk : in STD_LOGIC);
end lowpass_cell;

architecture Behavioral of lowpass_cell is

begin


end Behavioral;
