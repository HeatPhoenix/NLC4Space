library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use IEEE.STD_LOGIC_UNSIGNED;
--use IEEE.Std_logic_arith.all;

entity neuron is
	generic (
		address_0 : unsigned(5 downto 0):= "000000";
		address_1 : unsigned(5 downto 0):= "000000";
		post_spike_address : unsigned(5 downto 0) := "000000"
		);               
   
	port(
		clk_in : in std_logic;
		reset_in : in std_logic;

		address_in : in unsigned(5 downto 0);
		pre_spike : in std_logic;
		address_out : out unsigned(5 downto 0);
		post_spike : out std_logic
		);  
           
end entity neuron;




architecture behavioral_vhdl of neuron is


	component adaptive_synapse is
		port (
			clk_in : in std_logic;
			reset_in : in std_logic;
			pre_spike : in std_logic;
			post_spike : in std_logic;
		
			inje_current : out real
			);	
	end component;

	constant SPIKE_THRESHOLD : real := 1.2;

	signal pre_spike_vector : unsigned(1 downto 0) := "00";

	signal voltage_mem : real := 0.0;
	signal inje_current_0 : real := 0.0;
	signal inje_current_1 : real := 0.0;
	signal post_spike_inner : std_logic := '0';

	begin
		synapse_0 : adaptive_synapse
			port map(
				clk_in => clk_in,
				reset_in => reset_in,
				pre_spike => pre_spike_vector(0),
				post_spike => post_spike_inner,
		
				inje_current => inje_current_0
				); 
		synapse_1 : adaptive_synapse
			port map(
				clk_in => clk_in,
				reset_in => reset_in,
				pre_spike => pre_spike_vector(1),
				post_spike => post_spike_inner,
		
				inje_current => inje_current_1
				); 

		
		

		pre_spike_synapse_gen : process(clk_in,reset_in)
		begin
			if reset_in = '1' then
				pre_spike_vector <= "00";
			elsif rising_edge(clk_in) then
				if address_0 = (address_0 and address_in) then
					pre_spike_vector(0) <= '1';
				else
					pre_spike_vector(0) <= '0';
				end if;
				if address_1 = (address_1 and address_in) then
					pre_spike_vector(1) <= '1';
				else
					pre_spike_vector(1) <= '0';
				end if;
			end if;
		end process pre_spike_synapse_gen;


		post_spike_gen : process(clk_in,reset_in)
		begin
			if reset_in = '1' then
				post_spike <= '0';
				voltage_mem <= 0.0;
				address_out <= "000000";
			elsif rising_edge(clk_in) then
				if (voltage_mem + inje_current_0 + inje_current_1) >= SPIKE_THRESHOLD then
					post_spike <= '1';
					post_spike_inner <= '1';
					address_out <= post_spike_address;
					voltage_mem <= (voltage_mem + inje_current_0 + inje_current_1) * 0.1; --mod SPIKE_THRESHOLD;
				else
					post_spike <= '0';
					post_spike_inner <= '0';
					address_out <= "000000";
					voltage_mem <= voltage_mem + inje_current_0 + inje_current_1;
				end if;
			end if;
		end process post_spike_gen;
	
end architecture behavioral_vhdl;
