----------------------------------------------------------------------------------
-- Company: TU Delft, ESA
-- Engineer: Zacharia Rudge
-- 
-- Create Date: 07/08/2021 10:50:58 PM
-- Design Name: 
-- Module Name: spiking_activation_cell - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Individual cell of the spiking activation layer.
-- Receives its spiking frequency from the top level spiking layer.
-- Gets the current "time" from a clock signal counter and compares it to
-- its own trigger time and spikes when it is reached.
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

entity spiking_activation_cell is
    Generic ( NUM_BITS_PIXEL  : natural := 8; -- 24 total = R + G + B (8-bits each)  
            NUM_BITS_ADDR   : natural := 8;     
            COUNTER_RES     : natural := 16;      
            MAX_IMG_WIDTH   : natural := 64;
            MAX_IMG_HEIGHT   : natural := 64
            );
    Port ( clk : in std_logic;
           rst : in std_logic;
           spiking_frequency : in STD_LOGIC_VECTOR (COUNTER_RES downto 0) := (others => '0'); -- not a generic because it has to be changeable
           clk_current_count : in STD_LOGIC_VECTOR (COUNTER_RES downto 0) := (others => '0');
           spiking_signal : out STD_LOGIC := '0');
end spiking_activation_cell;

architecture Behavioral of spiking_activation_cell is

signal cell_spiking_trigger : STD_LOGIC_VECTOR (16 downto 0);

begin

process(clk, rst) -- compare current count to trigger count
begin 
    if rst = '1' then
        --reset signals
    end if;
        
end process;


end Behavioral;
