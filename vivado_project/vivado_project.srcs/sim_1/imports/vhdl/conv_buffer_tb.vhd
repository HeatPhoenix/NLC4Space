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
-- Description: Testbench for the buffers for each conv2d unit when done on R, G or B channels.
-- Adapted from conv2d_tb.
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

entity conv_buffer_tb is
end conv_buffer_tb;

architecture Behavioral of conv_buffer_tb is
    constant IMG_WIDTH      : natural := 64;
    constant IMG_HEIGHT     : natural := 64;
    constant NUM_BITS_PIXEL : natural := 8;    
    constant NUM_BITS_ADDR  : natural := 8;
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

    signal buffer_input_en : std_logic := '1';
    signal buffer_input_done : std_logic := '0';
    
    signal buffer_output_en : std_logic := '0';
    signal buffer_output_done : std_logic := '0';
    
    signal buffer_data_out_intermediate : STD_LOGIC_VECTOR(2*NUM_BITS_PIXEL-1 downto 0) := (others => '0');
    signal buffer_valid_out_intermediate : std_logic;

    component conv2d is
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
    
    component conv_buffer is 
        generic (
            NUM_BITS_PIXEL  : natural := 8; -- 24 total = R + G + B (8-bits each)  
            NUM_BITS_ADDR   : natural := 8;           
            MAX_IMG_WIDTH   : natural := 64;
            MAX_IMG_HEIGHT   : natural := 64
            );
        Port (
           clk          : in STD_LOGIC;
           rst          : in std_logic;
           
           input_en : in STD_LOGIC := '0';
           input_done : out STD_LOGIC := '0';
           
           output_en : in STD_LOGIC := '0';
           output_done : out STD_LOGIC := '0';
            
           pix_valid_out : in STD_LOGIC := '0';
           pix_data_out : in STD_LOGIC_VECTOR (2*NUM_BITS_PIXEL-1 downto 0);
           buffer_data_out : out STD_LOGIC_VECTOR(2*NUM_BITS_PIXEL-1 downto 0) := (others => '0');
           buffer_valid_out : out STD_LOGIC := '0';--aka buffer has been filled
           
           img_width       : in std_logic_vector(NUM_BITS_ADDR-1 downto 0);
           img_height      : in std_logic_vector(NUM_BITS_ADDR-1 downto 0)   
           );
    end component;
    

    type bytefile is file of character;
begin

uut: conv2d 
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

but: conv_buffer
generic map (
    NUM_BITS_PIXEL          => 8,
    NUM_BITS_ADDR           => 8,
    MAX_IMG_WIDTH           => 128,
    MAX_IMG_HEIGHT          => 128)
Port map (
	clk                     => clk,
    rst                     => rst,
    
	input_en => buffer_input_en,
    input_done => buffer_input_done,
   
    output_en => buffer_output_en,
    output_done => buffer_output_done,
    
    pix_valid_out => pix_valid_out,
    pix_data_out => pix_data_out,
    buffer_data_out => buffer_data_out_intermediate,
    buffer_valid_out => buffer_valid_out_intermediate,
    
    img_width => img_width_in,
    img_height => img_height_in
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
    buffer_input_en <= '1';
    -- write coefficients
    coeff_in_valid <= '1';
    for i in 0 to 9 -1 loop
        coeff_in <= x"0001"; -- all ones in our case
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
                pix_data_in <= std_logic_vector(to_unsigned((x-1)+(y-1)*IMG_WIDTH, pix_data_in'length)); -- enter data
            end if;
            pix_valid_in <= '1'; -- completed one pixel of the convolved image
            wait until rising_edge(clk);
            pix_valid_in <= '0';
            -- add some extra clock cycles to stress the pipeline and check if everything is still working
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            wait until rising_edge(clk);

            --pix_x <= (others=>'0');
            --pix_y <= (others=>'0');
            --pix_data_in <= (others=>'0');
            --pix_valid_in <= '0';
            --wait until rising_edge(clk);
        end loop;    end loop;

    pix_x <= (others=>'0');
    pix_y <= (others=>'0');
    pix_data_in <= (others=>'0');

    pix_valid_in <= '0';
	buffer_input_en <= '0'; -- disable input on buffer
	buffer_output_en <= '1'; -- enable output buffer

	wait for 50 us;
	
    assert FALSE report "Done writing packet data." severity FAILURE;
end process;

process --output process
file result_file : bytefile open write_mode is "data_sim.bin";
variable byte_out : character;
begin
    loop
        wait until rising_edge(clk);
        if (pix_valid_out = '1') then -- read output for 1 pixel in the image
            byte_out := character'VAL(to_integer(unsigned(pix_data_out(7 downto 0))));
            write(result_file,byte_out);
        end if;
    end loop;
end process;


end Behavioral;
