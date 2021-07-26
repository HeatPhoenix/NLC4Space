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
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lowpass_cell is
   generic (
            NUM_BITS_PIXEL  : natural := 8; -- 24 total = R + G + B (8-bits each)  
            NUM_BITS_ADDR   : natural := 8;           
            MAX_IMG_WIDTH   : natural := 64;
            MAX_IMG_HEIGHT   : natural := 64
            );
    Port ( rst : in STD_LOGIC;
           clk : in std_logic;
           spike_input : in STD_LOGIC_VECTOR (2*NUM_BITS_PIXEL-1 downto 0);
           filtered_output : out STD_LOGIC_VECTOR (2*NUM_BITS_PIXEL-1 downto 0)
           );
end lowpass_cell;

architecture Behavioral of lowpass_cell is

signal prior_output : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);
signal tau : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);

begin

process(clk, rst) is
begin
    if rst = '1' then
    end if;
    if rising_edge(clk) then
        filtered_output <= prior_output + tau * (spike_input - prior_output);
    end if;
end process;



end Behavioral;