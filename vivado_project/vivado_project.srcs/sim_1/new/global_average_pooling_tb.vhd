
library ieee;
use ieee.std_logic_1164.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

use work.common_package.all;

entity global_average_pooling_tb is
end global_average_pooling_tb;

architecture tb of global_average_pooling_tb is

    signal clk                  : std_logic;
    signal rst                  : std_logic;
    signal lowpass_layer_result : sfixed_vector_avg_set_vector;
    signal pooling_result       : sfixed_vector (511 downto 0);

    constant TbPeriod : time := 5 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut: entity work.global_average_pooling(Behavioral) 
    port map (clk                  => clk,
              rst                  => rst,
              lowpass_layer_result => lowpass_layer_result,
              pooling_result       => pooling_result);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        lowpass_layer_result <= (others => (others => to_sfixed(2, NUM_BITS_FIXED_INT_package, NUM_BITS_FIXED_FRAC_package)));

        -- Reset generation
        -- EDIT: Check that rst is really your reset signal
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;
        

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_global_average_pooling_tb of global_average_pooling_tb is
    for tb
    end for;
end cfg_global_average_pooling_tb;