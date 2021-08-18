----------------------------------------------------------------------------------
-- Company: TU Delft, ESA
-- Engineer: wubinyi, Zacharia Rudge
-- 
-- Create Date: 05/18/2021 10:23:59 PM
-- Design Name: 
-- Module Name: conv_buffer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Based on an SNN model implementation in VHDL by wubinyi
-- https://github.com/wubinyi/Spiking-Neural-Network. Top level testbench.
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: MIT Licensed
-- N.B.: Still lots of work to be done w.r.t. the contents of this stuff, have to
-- scrap stuff that's unnecessary for our purposes and make everything use
-- sfixed among other things
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity spiking_nn_tb is
end entity spiking_nn_tb;

architecture tb_vhdl of spiking_nn_tb is

	component spiking_nn is
		port(
			clk_in : in std_logic;
			reset_in : in std_logic;

			input : in unsigned(5 downto 0);
			output : out std_logic
			); 
	end component;

	constant CLKPERIODE    : time := 50 us;
	constant address_in_0 : unsigned(5 downto 0) := "000001";
	constant address_in_1 : unsigned(5 downto 0) := "001000";
	constant address_in_2 : unsigned(5 downto 0) := "001001";
	--constant address_in_3 : unsigned(5 downto 0) := "000011";
	--constant address_in_4 : unsigned(5 downto 0) := "000010";
	--constant address_in_5 : unsigned(5 downto 0) := "001001";

	signal clk_in : std_logic := '1';
	signal reset_in : std_logic := '0';
	signal input : unsigned(5 downto 0) := "000000";
	signal output : std_logic := '0';

	--signal temp_counter : integer := 1;

    	begin
		spiking_nn_1 : spiking_nn
			port map(
				clk_in => clk_in,
				reset_in => reset_in,

				input => input,
				output => output
				);	

		clk_gen : process
		begin
			wait for CLKPERIODE/2;
			clk_in <= not clk_in;
		end process clk_gen;

		reset_gen : process
		begin
			reset_in <= '1';
			wait for CLKPERIODE/2;
			reset_in <= '0';
			wait;
		end process reset_gen;

		spike_gen : process
		begin
			for I in 0 to 3 loop
				input <= "000000";
				wait for CLKPERIODE * 10;
				input <= address_in_0;
				wait for CLKPERIODE;
				input <= "000001";
	
				wait for CLKPERIODE * 7;
				input <= address_in_1;
				wait for CLKPERIODE;
				input <= "000000";
	
				wait for CLKPERIODE * 13;
				input <= address_in_2;
				wait for CLKPERIODE;
				input <= "000001";
			
				wait for CLKPERIODE * 8;
				input <= address_in_1;
				wait for CLKPERIODE;
				input <= "000000";

				wait for CLKPERIODE * 25;
				input <= address_in_1;			
				wait for CLKPERIODE;
				input <= "000001";	

				wait for CLKPERIODE * 17;
				input <= address_in_2;			
				wait for CLKPERIODE;
				input <= "000000";	

				wait for CLKPERIODE * 2;
				input <= address_in_0;			
				wait for CLKPERIODE;
				input <= "000001";		
			end loop;
			wait;
		end process spike_gen;


end architecture tb_vhdl;
