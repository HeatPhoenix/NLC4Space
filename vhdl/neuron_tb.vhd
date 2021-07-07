library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity neuron_tb is
end entity neuron_tb;

architecture tb_vhdl of neuron_tb is

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
			pre_spike : in std_logic;
			address_out : out unsigned(5 downto 0);
			post_spike : out std_logic
			); 
	end component;

	constant CLKPERIODE    : time := 50 us;
	constant address_in_0 : unsigned(5 downto 0) := "000001";
	constant address_in_1 : unsigned(5 downto 0) := "011000";
	constant address_in_2 : unsigned(5 downto 0) := "011010";
	constant address_in_3 : unsigned(5 downto 0) := "011011";

	signal clk_in : std_logic := '1';
	signal reset_in : std_logic := '0';
	signal address_in : unsigned(5 downto 0) := "000000";
	signal pre_spike : std_logic := '0';
	signal post_spike : std_logic := '0';	
	signal address_out : unsigned(5 downto 0) := "000000";

	signal temp_counter : integer := 0;

    	begin
		neuron_1 : neuron
			generic map(
				address_0 => "000001",
				address_1 => "000010",
				post_spike_address => "110000"
				)
			port map(
				clk_in => clk_in,
				reset_in => reset_in,

				address_in => address_in,
				pre_spike => pre_spike,
				address_out => address_out,
				post_spike => post_spike
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
			wait for CLKPERIODE;
			temp_counter <= temp_counter + 1;
			if temp_counter = 12 then
				address_in <= address_in_0;
			elsif temp_counter mod 29 = 0 then
				address_in <= address_in_1;
			elsif temp_counter mod 43 = 0 then
				address_in <= address_in_2;
			elsif temp_counter mod 58 = 0 then
				address_in <= address_in_3;
			elsif temp_counter mod 72 = 0 then
				address_in <= address_in_0;
			elsif temp_counter mod 80 = 0 then
				address_in <= address_in_2;
			elsif temp_counter > 4321 then
				temp_counter <= 0;
			else 
				address_in <= "000000";
			end if;
			
		end process spike_gen;


end architecture tb_vhdl;
