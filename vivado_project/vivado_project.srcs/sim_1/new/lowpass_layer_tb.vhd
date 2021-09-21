----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/14/2021 03:24:33 PM
-- Design Name: 
-- Module Name: tb_lowpass_layer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Test bench for the lowpass layer
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Work as intended
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

use work.common_package.all;

entity lowpass_layer_tb is
end lowpass_layer_tb;

architecture tb of lowpass_layer_tb is

    component lowpass_layer
        generic (
                NUM_BITS_PIXEL  : natural := 8; -- 24 total = R + G + B (8-bits each)  
                NUM_BITS_FIXED_INT : integer := NUM_BITS_FIXED_INT_package;
                NUM_BITS_FIXED_FRAC : integer := NUM_BITS_FIXED_FRAC_package;
                NUM_BITS_ADDR   : natural := 8;           
                MAX_IMG_WIDTH   : natural := 4;
                MAX_IMG_HEIGHT   : natural := 4
                );
        port (rst                  : in std_logic;
              clk                  : in std_logic;
              spike_inputs_in      : in sfixed_vector (max_img_width*max_img_height downto 0);
              filtered_outputs_out : out sfixed_vector (max_img_width*max_img_height downto 0));
    end component;

    constant MAX_IMG_WIDTH : integer := 4;
    constant MAX_IMG_HEIGHT : integer := 4;
    
    signal rst                  : std_logic;
    signal clk                  : std_logic;
    signal lowpass_layer_enable : std_logic;
    signal spike_inputs_in      : sfixed_vector (max_img_width*max_img_height downto 0);
    signal filtered_outputs_out : sfixed_vector (max_img_width*max_img_height downto 0);

    constant TbPeriod : time := 5 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    
    dut: entity work.lowpass_layer(Behavioral) 
    generic map(NUM_BITS_FIXED_INT => NUM_BITS_FIXED_INT_package,
            NUM_BITS_FIXED_FRAC => NUM_BITS_FIXED_FRAC_package,
            NUM_BITS_ADDR => 8,         
            MAX_IMG_WIDTH => 4,
            MAX_IMG_HEIGHT => 4
            )
    port map (rst                  => rst,
              clk                  => clk,
              lowpass_layer_enable => lowpass_layer_enable,
              spike_inputs_in      => spike_inputs_in,
              filtered_outputs_out => filtered_outputs_out);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        
        spike_inputs_in <= (others => to_sfixed(0, NUM_BITS_FIXED_INT_package, NUM_BITS_FIXED_FRAC_package));
        -- EDIT: Check that rst is really your reset signal
        rst <= '1';
        
        wait for 10 ns;
        rst <= '0';
        lowpass_layer_enable <= '1';
        wait for 10 ns;
        spike_inputs_in <= (others => to_sfixed(1.5, NUM_BITS_FIXED_INT_package, NUM_BITS_FIXED_FRAC_package));
        wait for 20 ns;
        spike_inputs_in <= (others => to_sfixed(1.75, NUM_BITS_FIXED_INT_package, NUM_BITS_FIXED_FRAC_package));
        wait for 20 ns;
        spike_inputs_in <= (others => to_sfixed(0, NUM_BITS_FIXED_INT_package, NUM_BITS_FIXED_FRAC_package));
        wait for 20 ns;
        rst <= '1';

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;