----------------------------------------------------------------------------------
-- Company: TU Delft, ESA
-- Engineer: B. Koch, Zacharia Rudge
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: conv2d - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Conv2d unit, adapted from B. Koch's work from https://github.com/bkarl/conv2d-vhdl
-- Testbench which tests the conv2d unit, this file was adapted to serve as a testbench for other parts as well
--
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: This code is licensed under MIT license (see LICENSE.txt for details)
-- N.B.: Still needs to be changed to sfixed format for calculations *and* 4x4 kernels
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library std;
use std.textio.all;

entity conv2d_4x4_tb is
end conv2d_4x4_tb;

architecture Behavioral of conv2d_4x4_tb is
    constant IMG_WIDTH      : natural := 64;
    constant IMG_HEIGHT     : natural := 64;
    constant NUM_BITS_PIXEL : natural := 8;    constant NUM_BITS_ADDR  : natural := 8;
    constant NUM_BITS_COEFF : natural := 16;

    signal clk              : std_logic;
    
    signal pix_data_in      : std_logic_vector(7 downto 0);
    signal pix_valid_in     : std_logic;
    signal pix_y            : std_logic_vector(7 downto 0);
    signal pix_x            : std_logic_vector(7 downto 0);
    
    signal pix_data_out     : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);
    signal pix_valid_out    : std_logic;
    signal rst              : std_logic;

    signal img_width_in     : std_logic_vector(NUM_BITS_ADDR-1 downto 0);
    signal img_height_in    : std_logic_vector(NUM_BITS_ADDR-1 downto 0);
    signal coeff_in         : std_logic_vector(15 downto 0);
    signal coeff_in_valid   : std_logic;

    signal total_in_pixels     : integer := 0;
    signal total_out_pixels     : integer := 0;
    signal skip_pixel       : std_logic := '0';
    signal skip_line        : std_logic := '0';

    component conv2d_4x4 is
        generic (
            NUM_BITS_PIXEL  : natural := 8;
            NUM_BITS_ADDR   : natural := 8;
            NUM_BITS_COEFF  : natural := 16;
            MAX_IMG_WIDTH   : natural := 64;
            MAX_IMG_HEIGHT  : natural := 64
    );
    Port (  
            clk        		: in STD_LOGIC;
            rst             : in std_logic;

            pix_data_in 	: in STD_LOGIC_VECTOR (NUM_BITS_PIXEL-1 downto 0);
            pix_valid_in 	: in STD_LOGIC;
            pix_y           : in std_logic_vector(NUM_BITS_ADDR-1 downto 0);
            pix_x           : in std_logic_vector(NUM_BITS_ADDR-1 downto 0);

            pix_data_out 	: out STD_LOGIC_VECTOR (2*NUM_BITS_PIXEL-1 downto 0) := (others=>'0');
            pix_valid_out 	: out STD_LOGIC := '0';

            coeff_in        : in std_logic_vector(NUM_BITS_COEFF-1 downto 0);
            coeff_in_valid  : in std_logic;

            img_width       : in std_logic_vector(NUM_BITS_ADDR-1 downto 0);
            img_height      : in std_logic_vector(NUM_BITS_ADDR-1 downto 0)
		   );
    end component;

    type bytefile is file of character;
begin

uut: conv2d_4x4 
generic map (
    NUM_BITS_PIXEL          => 8,
    NUM_BITS_ADDR           => 8,
    NUM_BITS_COEFF          => 16,
    MAX_IMG_WIDTH           => 128,
    MAX_IMG_HEIGHT          => 128)
Port map (
	clk                     => clk,
    rst                     => rst,
	pix_data_in 		    => pix_data_in,
	pix_valid_in 	        => pix_valid_in,
	pix_y 		            => pix_y,
	pix_x           		=> pix_x,
	pix_data_out    		=> pix_data_out,
    pix_valid_out   		=> pix_valid_out,
    coeff_in                => coeff_in,
    coeff_in_valid          => coeff_in_valid,

    img_width               => img_width_in,
    img_height              => img_height_in
);

clk_proc: process
begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;        
end process;


process	--input process
begin
    img_width_in <= std_logic_vector(to_unsigned(64, img_width_in'length));
    img_height_in <= std_logic_vector(to_unsigned(64, img_width_in'length));

    rst <= '1';
    coeff_in_valid <= '0';
    pix_data_in <= (others=>'0');
    pix_x <= (others=>'0');
    pix_y <= (others=>'0');
    pix_valid_in <= '0';
    wait for 100 us;
    rst <= '0';
    -- write coefficients
    coeff_in_valid <= '1';
    for i in 0 to 16 -1 loop
        coeff_in <= std_logic_vector(to_unsigned(1, coeff_in'length)); -- all 1
        wait until rising_edge(clk); -- every rising clk, next entry in (3x3) filter 
    end loop;
    coeff_in_valid <= '0';
    
    -- feed input data
    for y in 0 to IMG_HEIGHT loop -- we need to feed an extra line of input data (the first line zero padding) important: the last line is not needed!
            for x in 0 to IMG_WIDTH+1 loop -- we need to feed zero padding left and right
                    pix_x <= std_logic_vector(to_unsigned(x, pix_x'length));
                    pix_y <= std_logic_vector(to_unsigned(y, pix_y'length));
                    if (x = 0 or x = IMG_WIDTH+1 or y = 0 or y = IMG_HEIGHT+1) then
                        pix_data_in <= (others=>'0');
                    else
                        pix_data_in <= std_logic_vector(to_unsigned(2, pix_data_in'length)); -- all 2
                    end if;
                    pix_valid_in <= '1'; -- completed one pixel of the convolved image
                    wait until rising_edge(clk);
                    pix_valid_in <= '0';
                    -- add some extra clock cycles to stress the pipeline and check if everything is still working
                    wait until rising_edge(clk);
                    wait until rising_edge(clk);
                    wait until rising_edge(clk);
                    total_in_pixels <= total_in_pixels + 1;
            end loop;  
            skip_line <= NOT skip_line;
    end loop;

    pix_x <= (others=>'0');
    pix_y <= (others=>'0');
    pix_data_in <= (others=>'0');

    pix_valid_in <= '0';

	wait for 100 us;
    assert FALSE report "Done writing packet data." severity FAILURE;
end process;

process --output process
file result_file : bytefile open write_mode is "data_sim.bin";
variable byte_out : character;
begin
    loop
        wait until rising_edge(clk);
        if (pix_valid_out = '1' ) and (skip_pixel = '0') and (skip_line = '0') then -- read output for 1 pixel in the image
            total_out_pixels <= total_out_pixels + 1;
            skip_pixel <= NOT skip_pixel;
            byte_out := character'VAL(to_integer(unsigned(pix_data_out(7 downto 0))));
            
            if(skip_line = '1') then
                skip_pixel <= '0';
            end if;
            write(result_file,byte_out);
        elsif (pix_valid_out = '1') and (skip_pixel = '1') then
            skip_pixel <= NOT skip_pixel;
        end if;
    end loop;
end process;


end Behavioral;
