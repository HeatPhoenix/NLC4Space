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
-- https://github.com/wubinyi/Spiking-Neural-Network. Top level file.
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: MIT Licensed
-- N.B.: Demo of a number of neurons, tested and working
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

use work.common_package.all;

entity spiking_nn is
	port(
		clk_in : in std_logic;
		reset_in : in std_logic;

		input : in unsigned(5 downto 0);
		output : out std_logic
		);  
end entity spiking_nn;

architecture behavioral_vhdl of spiking_nn is
	component neuron is
		generic (
			address_0 : unsigned(5 downto 0):= "000000";
			address_1 : unsigned(5 downto 0):= "000000";
			post_spike_address : unsigned(5 downto 0) := "000000"
			);               
   
		port(
			clk_in : in std_logic;
			reset_in : in std_logic;

			address_in : in unsigned(5 downto 0);
			pre_spike : in std_logic;                   -- unused
			address_out : out unsigned(5 downto 0);
			post_spike : out std_logic                  -- unused expect neuron_2
			); 
	end component;

	signal AER_address : unsigned(5 downto 0) := "000000";
	signal pre_spike: std_logic := '0';
	signal post_spike_0: std_logic := '0';
	signal post_spike_1: std_logic := '0';
		

	signal address_out_0 : unsigned(5 downto 0) := "000000";
	--signal post_spike_0 : std_logic

	signal address_out_1 : unsigned(5 downto 0) := "000000";
	--signal post_spike_1 : std_logic

	signal address_out_2 : unsigned(5 downto 0) := "000000";
	--signal post_spike_2 : std_logic
	

	begin
		
		neuron_0 : neuron
			generic map(
				address_0 => "000001",
				address_1 => "000010",
				post_spike_address => "010100"
				)
			port map(
				clk_in => clk_in,
				reset_in => reset_in,

				address_in => AER_address,
				pre_spike => pre_spike,
				address_out => address_out_0,
				post_spike => post_spike_0
				);	

		neuron_1 : neuron
			generic map(
				address_0 => "000100",
				address_1 => "001000",
				post_spike_address => "100000"
				)
			port map(
				clk_in => clk_in,
				reset_in => reset_in,

				address_in => AER_address,
				pre_spike => pre_spike,
				address_out => address_out_1,
				post_spike => post_spike_1
				);	

		neuron_2 : neuron
			generic map(
				address_0 => "010000",
				address_1 => "100000",
				post_spike_address => "000010"   -- "000000"
				)
			port map(
				clk_in => clk_in,
				reset_in => reset_in,

				address_in => AER_address,
				pre_spike => pre_spike,
				address_out => address_out_2,
				post_spike => output
				);	

		
		AER_BUS : process(clk_in, reset_in)
		begin
			if reset_in = '1' then
				AER_address <= "000000";
			elsif rising_edge(clk_in) then
				AER_address <= input or address_out_0 or address_out_1 or address_out_2;
			end if;
		end process AER_BUS;


    
end architecture behavioral_vhdl;
