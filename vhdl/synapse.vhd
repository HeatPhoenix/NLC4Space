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
-- https://github.com/wubinyi/Spiking-Neural-Network. Synapse VHDL, adapted to use SFIXED
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: MIT Licensed, tested
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

use work.common_package.all;

entity adaptive_synapse is
	port (
		clk_in : in std_logic;
		reset_in : in std_logic;
		pre_spike : in std_logic;
		post_spike : in std_logic;
		
		inje_current : out SFIXED_COMMON_SIZE
		);	
end entity adaptive_synapse;

architecture behavioral_vhdl of adaptive_synapse is

	signal counter_pre : unsigned(3 downto 0);
	signal counter_post : unsigned(3 downto 0);
	signal weight : sfixed (NUM_BITS_FIXED_INT_package downto NUM_BITS_FIXED_FRAC_package) := to_sfixed(0.5, NUM_BITS_FIXED_INT_package, NUM_BITS_FIXED_FRAC_package);
	signal LT_weight_inc : sfixed (NUM_BITS_FIXED_INT_package downto NUM_BITS_FIXED_FRAC_package) := to_sfixed(0.0, NUM_BITS_FIXED_INT_package, NUM_BITS_FIXED_FRAC_package);
	signal LT_weight_dec : sfixed (NUM_BITS_FIXED_INT_package downto NUM_BITS_FIXED_FRAC_package) := to_sfixed(0.0, NUM_BITS_FIXED_INT_package, NUM_BITS_FIXED_FRAC_package);
	signal ST_weight_dec : sfixed (NUM_BITS_FIXED_INT_package downto NUM_BITS_FIXED_FRAC_package) := to_sfixed(0.0, NUM_BITS_FIXED_INT_package, NUM_BITS_FIXED_FRAC_package);
	
	constant delta_t : time := 10 us;
	constant tau : sfixed (NUM_BITS_FIXED_INT_package downto NUM_BITS_FIXED_FRAC_package) := to_sfixed(250.0, NUM_BITS_FIXED_INT_package, NUM_BITS_FIXED_FRAC_package); --250us
	constant k : sfixed (NUM_BITS_FIXED_INT_package downto NUM_BITS_FIXED_FRAC_package) := to_sfixed((real(delta_t / us) / to_real(tau)), NUM_BITS_FIXED_INT_package, NUM_BITS_FIXED_FRAC_package);

begin

	LT_weight_increase : process(clk_in, reset_in)
	begin
		if reset_in = '1' then
			counter_pre <= "0000";
			LT_weight_inc <= to_sfixed(0.0, LT_weight_inc);
		elsif rising_edge(clk_in) then 
		--elsif clk_in = '1' then 
			if pre_spike = '1' then
				counter_pre <= "0001";
				--LT_weight_inc <= 0.0;
			-- pre-spike dauert "0101" - "0001" = 4 clock periode 
			-- during this time windows, check the signal post_spike,
			elsif counter_pre > "0000" and counter_pre < "0100" then --"1010" then
				if post_spike = '1' then
					counter_pre <= "0000";
					--LT_weight_inc <= LT_weight_inc + 0.1;
					LT_weight_inc <= resize(LT_weight_inc + (1.0 - weight) * k, LT_weight_inc);
				else
					counter_pre <= counter_pre + 1;
					--LT_weight_inc <= 0.0;
				end if; 
			else
				counter_pre <= "0000";
				--LT_weight_inc <= 0.0;
			end if;
		end if;
	end process LT_weight_increase;

	LT_weight_decrease : process(clk_in, reset_in)
	begin
		if reset_in = '1' then
			counter_post <= "0000";	
			LT_weight_dec <= to_sfixed(0.0, LT_weight_dec);
		elsif rising_edge(clk_in) then 
		--elsif clk_in = '1' then 
			if post_spike = '1' then
				counter_post <= "0001";
				--LT_weight_dec <= 0.0;
			-- post-spike dauert "0101" - "0001" = 4 clock periode 
			-- during this time windows, check the signal pre_spike,
			elsif counter_post > "0000" and counter_post < "0100" then --"1010" then
				if pre_spike = '1' then
					counter_post <= "0000";
					--LT_weight_dec <= LT_weight_dec + 0.1;
					LT_weight_dec <= resize(LT_weight_dec - weight * k, LT_weight_dec);
				else
					counter_post <= counter_post + 1;
					--LT_weight_dec <= 0.0;
				end if; 
			else
				counter_post <= "0000";
				--LT_weight_dec <= 0.0;
			end if;
		end if;
	end process LT_weight_decrease;
	

	ST_weight_decrease : process(clk_in, reset_in)
	begin
		if reset_in = '1' then
			ST_weight_dec <= to_sfixed(0.0, ST_weight_dec);
		elsif rising_edge(clk_in) then
			if pre_spike = '1' then
				--ST_weight_dec <= 0.0 - weight * k * 0.333;
				ST_weight_dec <= resize(ST_weight_dec - weight * k * 0.333, ST_weight_dec'high, ST_weight_dec'low);
			else
				if (weight * k * 0.333) > ( 0.0 - ST_weight_dec) then
					ST_weight_dec <= to_sfixed(0.0, ST_weight_dec);
				else
					ST_weight_dec <= resize(ST_weight_dec + weight * k * 0.333, ST_weight_dec'high, ST_weight_dec'low);
				end if;
			end if;
		end if;
	end process ST_weight_decrease;


	weight_add : process(clk_in, reset_in)
	begin
		if reset_in = '1' then
			weight <= to_sfixed(0.0, weight);
		elsif rising_edge(clk_in) then
			--wait on LT_weight_inc, LT_weight_dec;
			weight <= resize(0.5 + LT_weight_inc + LT_weight_dec + ST_weight_dec, weight'high, weight'low);
		end if;
	end process weight_add;

	injection_current : process(clk_in, reset_in)   
	begin
		if reset_in = '1' then
			inje_current <= to_sfixed(0.0, inje_current'high, inje_current'low);
		elsif rising_edge(clk_in) then
			if pre_spike = '1' then
				inje_current <= weight;
			else
				inje_current <= to_sfixed(0.0, inje_current'high, inje_current'low);
			end if;
		end if;
	end process injection_current;
   
end architecture behavioral_vhdl;
