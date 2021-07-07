library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;


entity adaptive_synapse is
	port (
		clk_in : in std_logic;
		reset_in : in std_logic;
		pre_spike : in std_logic;
		post_spike : in std_logic;
		
		inje_current : out real
		);	
end entity adaptive_synapse;

architecture behavioral_vhdl of adaptive_synapse is

	signal counter_pre : unsigned(3 downto 0);
	signal counter_post : unsigned(3 downto 0);
	signal weight : real := 0.5;
	signal LT_weight_inc : real := 0.0;
	signal LT_weight_dec : real := 0.0;
	signal ST_weight_dec : real := 0.0;
	
	constant delta_t : time := 10 us;
	constant tau : real := 250.0; --250us
	constant k : real := real(delta_t / us) / tau ;

begin

	LT_weight_increase : process(clk_in, reset_in)
	begin
		if reset_in = '1' then
			counter_pre <= "0000";
			LT_weight_inc <= 0.0;
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
					LT_weight_inc <= LT_weight_inc + (1.0 - weight) * k;
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
			LT_weight_dec <= 0.0;
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
					LT_weight_dec <= LT_weight_dec - weight * k;
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
			ST_weight_dec <= 0.0;
		elsif rising_edge(clk_in) then
			if pre_spike = '1' then
				--ST_weight_dec <= 0.0 - weight * k * 0.333;
				ST_weight_dec <= ST_weight_dec - weight * k * 0.333;
			else
				if (weight * k * 0.333) > ( 0.0 - ST_weight_dec) then
					ST_weight_dec <= 0.0;
				else
					ST_weight_dec <= ST_weight_dec + weight * k * 0.333;
				end if;
			end if;
		end if;
	end process ST_weight_decrease;


	weight_add : process(clk_in, reset_in)
	begin
		if reset_in = '1' then
			weight <= 0.5;
		elsif rising_edge(clk_in) then
			--wait on LT_weight_inc, LT_weight_dec;
			weight <= 0.5 + LT_weight_inc + LT_weight_dec + ST_weight_dec;
		end if;
	end process weight_add;

	injection_current : process(clk_in, reset_in)   
	begin
		if reset_in = '1' then
			inje_current <= 0.0;
		elsif rising_edge(clk_in) then
			if pre_spike = '1' then
				inje_current <= weight;
			else
				inje_current <= 0.0;
			end if;
		end if;
	end process injection_current;
   
end architecture behavioral_vhdl;
