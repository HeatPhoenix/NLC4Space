library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity synapse_tb is
end entity synapse_tb;

architecture tb_vhdl of synapse_tb is

	component adaptive_synapse is
		port (
			clk_in : in std_logic;
			reset_in : in std_logic;
			pre_spike : in std_logic;
			post_spike : in std_logic;
		
			inje_current : out real
			);	
	end component;

	constant CLKPERIODE    : time := 50 us; 

	signal clk_in : std_logic := '1';
	signal reset_in : std_logic := '0';
	signal pre_spike : std_logic := '0';
	signal post_spike : std_logic := '0';
		
	signal inje_current : real := 0.0;

	--signal temp_counter_pre : unsigned (4 downto 0) := "00000";
	--signal temp_counter_post : unsigned (5 downto 0) := "111110";

    	begin
		synapse_1 : adaptive_synapse
			port map(
				clk_in => clk_in,
				reset_in => reset_in,
				pre_spike => pre_spike,
				post_spike => post_spike,
				
				inje_current => inje_current
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
			-- pre_spike is before than post_spike
			wait for CLKPERIODE*2;
			pre_spike <= '1';
			wait for CLKPERIODE/2;
			pre_spike <= '0';
			wait for CLKPERIODE/2;
			post_spike <= '1';
			wait for CLKPERIODE/2;
			post_spike <= '0';
			wait for CLKPERIODE/2;
			wait for CLKPERIODE*10;

			-- pre_spike without post_spike
			pre_spike <= '1';
			wait for CLKPERIODE/2;
			pre_spike <= '0';
			wait for CLKPERIODE/2;
			pre_spike <= '1';
			wait for CLKPERIODE/2;
			pre_spike <= '0';
			wait for CLKPERIODE/2;
			pre_spike <= '1';
			wait for CLKPERIODE/2;
			pre_spike <= '0';
			wait for CLKPERIODE/2;
			pre_spike <= '1';
			wait for CLKPERIODE/2;
			pre_spike <= '0';
			wait for CLKPERIODE/2;
			wait for CLKPERIODE*10;

			-- post_spike is before than pre_spike
			wait for CLKPERIODE*2;
			post_spike <= '1';
			wait for CLKPERIODE/2;
			post_spike <= '0';
			wait for CLKPERIODE/2;
			pre_spike <= '1';
			wait for CLKPERIODE/2;
			pre_spike <= '0';
			wait for CLKPERIODE/2;
			wait for CLKPERIODE*10;

			wait;
			
		end process spike_gen;

end architecture tb_vhdl;




--		pre_spike_gen : process
--		begin
--			wait for CLKPERIODE;
--			temp_counter_pre <= temp_counter_pre + 1;
--			--pre_spike <= temp_counter(0);
--			if temp_counter_pre = "00000" then
--				pre_spike <= '1';
--			else
--				pre_spike <= '0';
--			end if;
--			
--		end process pre_spike_gen;
--
--		post_spike_gen : process
--		begin
--			wait for CLKPERIODE;
--			temp_counter_post <= temp_counter_post + 1;
--			--pre_spike <= temp_counter(0);
--			if temp_counter_post = "000000" then
--				post_spike <= '1';
--			else
--				post_spike <= '0';
--			end if;
--			
--		end process post_spike_gen;