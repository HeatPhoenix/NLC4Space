----------------------------------------------------------------------------------
-- Company: TU Delft, ESA
-- Engineer: Zacharia Rudge
-- 
-- Create Date: 07/26/2021 02:37:46 PM
-- Design Name: 
-- Module Name: spike_layer_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench for testing the spiking activation layer
-- which follows the RGB Combiner. Spiking activation layer currently only
-- loads the previous layer's data and then multiplies it by the number of timesteps 
-- that we need calculated
--
-- Dependencies:  
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Works as intended
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library std;
use std.textio.all;

entity spike_layer_tb is
end spike_layer_tb;

architecture Behavioral of spike_layer_tb is
    constant IMG_WIDTH      : natural := 64;
    constant IMG_HEIGHT     : natural := 64;
    constant NUM_BITS_PIXEL : natural := 8;    
    constant NUM_BITS_ADDR  : natural := 8;
    constant NUM_BITS_COEFF : natural := 16;

    signal clk              : std_logic;
    signal rst              : std_logic;
    
    --top layer signals
    signal current_timestep : std_logic_vector(7 downto 0) := "00000000";
    
    --convolution signals (general)
    signal pix_data_in      : std_logic_vector(7 downto 0);
    signal pix_valid_in     : std_logic;
    
    signal pix_y            : std_logic_vector(7 downto 0);
    signal pix_x            : std_logic_vector(7 downto 0);
    
    signal img_width_in     : std_logic_vector(NUM_BITS_ADDR-1 downto 0);
    signal img_height_in    : std_logic_vector(NUM_BITS_ADDR-1 downto 0);
    
    signal coeff_in         : std_logic_vector(15 downto 0); -- convolution filter
    signal coeff_in_valid   : std_logic;
    
    --convolution signals (specific)
    signal pix_data_out     : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0); 
    signal pix_valid_out    : std_logic;


    signal buffer_input_en : std_logic := '1';
    signal buffer_input_done : std_logic := '0';
    
    signal buffer_output_en : std_logic;
    signal buffer_output_done : std_logic;
    
    signal pix_valid_out_intermediate : std_logic;
    signal pix_data_out_intermediate : STD_LOGIC_VECTOR (2*NUM_BITS_PIXEL-1 downto 0);
    
    signal buffer_data_out_intermediate : STD_LOGIC_VECTOR(2*NUM_BITS_PIXEL-1 downto 0) := (others => '0');
    signal buffer_valid_out_intermediate : std_logic;
    
    --convolution signals (red)
    signal red_pix_data_out     : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0); 
    signal red_pix_valid_out    : std_logic;

    signal red_buffer_input_en : std_logic := '0';
    signal red_buffer_input_done : std_logic := '0';
    
    signal red_buffer_output_en : std_logic := '0';
    signal red_buffer_output_done : std_logic := '0';
    
    signal red_pix_valid_out_intermediate : std_logic;
    signal red_pix_data_out_intermediate : STD_LOGIC_VECTOR (2*NUM_BITS_PIXEL-1 downto 0);
    
    signal red_buffer_data_out_intermediate : STD_LOGIC_VECTOR(2*NUM_BITS_PIXEL-1 downto 0) := (others => '0');
    signal red_buffer_valid_out_intermediate : std_logic;
    
    --convolution signals (green)
    signal green_pix_data_out     : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);
    signal green_pix_valid_out    : std_logic;

    signal green_buffer_input_en : std_logic := '0';
    signal green_buffer_input_done : std_logic := '0';
    
    signal green_buffer_output_en : std_logic := '0';
    signal green_buffer_output_done : std_logic := '0';
    
    signal green_pix_valid_out_intermediate : std_logic;
    signal green_pix_data_out_intermediate : STD_LOGIC_VECTOR (2*NUM_BITS_PIXEL-1 downto 0);
    
    signal green_buffer_data_out_intermediate : STD_LOGIC_VECTOR(2*NUM_BITS_PIXEL-1 downto 0) := (others => '0');
    signal green_buffer_valid_out_intermediate : std_logic;
    
    --convolution signals (blue)
    signal blue_pix_data_out     : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0); 
    signal blue_pix_valid_out    : std_logic;

    signal blue_buffer_input_en : std_logic := '0';
    signal blue_buffer_input_done : std_logic := '0';
    
    signal blue_buffer_output_en : std_logic := '0';
    signal blue_buffer_output_done : std_logic := '0';
    
    signal blue_pix_valid_out_intermediate : std_logic;
    signal blue_pix_data_out_intermediate : STD_LOGIC_VECTOR (2*NUM_BITS_PIXEL-1 downto 0);
    
    signal blue_buffer_data_out_intermediate : STD_LOGIC_VECTOR(2*NUM_BITS_PIXEL-1 downto 0) := (others => '0');
    signal blue_buffer_valid_out_intermediate : std_logic;
    
    --rgb combiner signals
    signal r_data_in : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);
    signal r_enable_in : std_logic;
    signal g_data_in : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);
    signal g_enable_in : std_logic;
    signal b_data_in : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);
    signal b_enable_in : std_logic;
    signal input_mode_en : std_logic;
    signal output_mode_en : std_logic;
    signal combiner_data_out : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);
    signal combiner_valid_out : std_logic; 
    signal combiner_done_out : std_logic;
    signal combiner_done_in : std_logic;
    
    --spiking activation layer signals
    signal timesteps_in : std_logic_vector(1 downto 0) := "01"; -- 1 step
    
    signal input_en_spiking : std_logic;
    signal input_done_spiking : std_logic;
    
    signal output_en_spiking : std_logic;
    signal output_done_spiking : std_logic;
    
    signal input_valid_out_spiking : std_logic;
    signal input_data_out_spiking : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);
    
    signal spiking_data_out : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);
    signal spiking_valid_out : std_logic;
    
    
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
            coeff_in_valid  : in std_logic := '0';

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
    
    component rgb_combiner is
        generic (
            NUM_BITS_PIXEL  : natural := 8; -- 24 total = R + G + B (8-bits each)  
            NUM_BITS_ADDR   : natural := 8;           
            MAX_IMG_WIDTH   : natural := 64;
            MAX_IMG_HEIGHT   : natural := 64
            );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           r_data : in STD_LOGIC_VECTOR (2*NUM_BITS_PIXEL-1  downto 0) := (others => '0'); --pix_data of R convolution unit
           r_enable : in STD_LOGIC := '0';
           g_data : in STD_LOGIC_VECTOR (2*NUM_BITS_PIXEL-1  downto 0) := (others => '0'); --pix_data of G convolution unit
           g_enable : in STD_LOGIC := '0';
           b_data : in STD_LOGIC_VECTOR (2*NUM_BITS_PIXEL-1  downto 0) := (others => '0'); --pix_data of B convolution unit 
           b_enable : in STD_LOGIC := '0';
           input_mode_en : in STD_LOGIC := '0';
           output_mode_en : in STD_LOGIC := '0';
           combiner_data : out STD_LOGIC_VECTOR (2*NUM_BITS_PIXEL-1  downto 0) := (others => '0');
           combiner_valid_out : out STD_LOGIC := '0';
           combiner_input_done : out STD_LOGIC := '0';
           combiner_output_done : out STD_LOGIC := '0';
           
           img_width       : in std_logic_vector(NUM_BITS_ADDR-1 downto 0);
           img_height      : in std_logic_vector(NUM_BITS_ADDR-1 downto 0)
           );      
    end component;
    
    component spiking_activation_layer is
        generic (
            NUM_BITS_PIXEL  : natural := 8; -- 24 total = R + G + B (8-bits each)  
            NUM_BITS_ADDR   : natural := 8;           
            MAX_IMG_WIDTH   : natural := 64;
            MAX_IMG_HEIGHT   : natural := 64
            );
    Port ( clk          : in STD_LOGIC;
           rst          : in std_logic;
           
           timesteps_to_calculate : in STD_LOGIC_VECTOR (1 downto 0); -- max 4 at once, 
           
           input_en : in STD_LOGIC := '0';
           input_done : out STD_LOGIC := '0';
           
           output_en : in STD_LOGIC := '0';
           output_done : out STD_LOGIC := '0';
            
           input_valid_out : in STD_LOGIC := '0';
           input_data_out : in STD_LOGIC_VECTOR (2*NUM_BITS_PIXEL-1 downto 0); 
           
           spiking_data_out : out STD_LOGIC_VECTOR(2*NUM_BITS_PIXEL-1 downto 0) := (others => '0');
           spiking_valid_out : out STD_LOGIC := '0';--aka buffer has been filled
           
           img_width       : in std_logic_vector(NUM_BITS_ADDR-1 downto 0);
           img_height      : in std_logic_vector(NUM_BITS_ADDR-1 downto 0)         
           );   
    end component;

    

    type bytefile is file of character;
begin

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

-- red channel convolution
r_uut: conv2d 
generic map (
    NUM_BITS_PIXEL          => 8,
    NUM_BITS_ADDR           => 8,
    NUM_BITS_COEFF          => 16,
    MAX_IMG_WIDTH           => 128,
    MAX_IMG_HEIGHT          => 128)
Port map (
	clk                     => clk,
    rst                     => rst,
	pix_data_in 		    => pix_data_in, --should be red pixel data in
	pix_valid_in 	        => pix_valid_in, -- should be red pixel valid in
	pix_y 		            => pix_y,
	pix_x           		=> pix_x,
	pix_data_out    		=> red_pix_data_out, --should be red pixel data out
    pix_valid_out   		=> red_pix_valid_out, --should be red pixel valid out
    coeff_in                => coeff_in,
    coeff_in_valid          => coeff_in_valid,

    img_width               => img_width_in,
    img_height              => img_height_in
);

-- red buffer
r_but: conv_buffer
generic map (
    NUM_BITS_PIXEL          => 8,
    NUM_BITS_ADDR           => 8,
    MAX_IMG_WIDTH           => 128,
    MAX_IMG_HEIGHT          => 128)
Port map (
	clk                     => clk,
    rst                     => rst,
    
	input_en => red_buffer_input_en,
    input_done => red_buffer_input_done,
   
    output_en => red_buffer_output_en,
    output_done => red_buffer_output_done,
    
    pix_valid_out => red_pix_valid_out, --should be red pixel data out 
    pix_data_out => red_pix_data_out, --should be red pixel valid out
    buffer_data_out => red_buffer_data_out_intermediate, --should be red buffer data out intermediate
    buffer_valid_out => red_buffer_valid_out_intermediate, --should be red buffer valid out intermediate
    
    img_width => img_width_in,
    img_height => img_height_in
);

-- green channel convolution
g_uut: conv2d 
generic map (
    NUM_BITS_PIXEL          => 8,
    NUM_BITS_ADDR           => 8,
    NUM_BITS_COEFF          => 16,
    MAX_IMG_WIDTH           => 128,
    MAX_IMG_HEIGHT          => 128)
Port map (
	clk                     => clk,
    rst                     => rst,
	pix_data_in 		    => pix_data_in, --should be green pixel data in
	pix_valid_in 	        => pix_valid_in, -- should be green pixel valid in
	pix_y 		            => pix_y,
	pix_x           		=> pix_x,
	pix_data_out    		=> green_pix_data_out, --should be green pixel data out
    pix_valid_out   		=> green_pix_valid_out, --should be green pixel valid out
    coeff_in                => coeff_in,
    coeff_in_valid          => coeff_in_valid,

    img_width               => img_width_in,
    img_height              => img_height_in
);

-- green buffer
g_but: conv_buffer
generic map (
    NUM_BITS_PIXEL          => 8,
    NUM_BITS_ADDR           => 8,
    MAX_IMG_WIDTH           => 128,
    MAX_IMG_HEIGHT          => 128)
Port map (
	clk                     => clk,
    rst                     => rst,
    
	input_en => green_buffer_input_en,
    input_done => green_buffer_input_done,
   
    output_en => green_buffer_output_en,
    output_done => green_buffer_output_done,
    
    pix_valid_out => green_pix_valid_out, --should be green pixel data out 
    pix_data_out => green_pix_data_out, --should be green pixel valid out
    buffer_data_out => green_buffer_data_out_intermediate, --should be green buffer data out intermediate
    buffer_valid_out => green_buffer_valid_out_intermediate, --should be green buffer valid out intermediate
    
    img_width => img_width_in,
    img_height => img_height_in
);

-- blue channel convolution
b_uut: conv2d 
generic map (
    NUM_BITS_PIXEL          => 8,
    NUM_BITS_ADDR           => 8,
    NUM_BITS_COEFF          => 16,
    MAX_IMG_WIDTH           => 128,
    MAX_IMG_HEIGHT          => 128)
Port map (
	clk                     => clk,
    rst                     => rst,
	pix_data_in 		    => pix_data_in, --should be blue pixel data in
	pix_valid_in 	        => pix_valid_in, -- should be blue pixel valid in
	pix_y 		            => pix_y,
	pix_x           		=> pix_x,
	pix_data_out    		=> blue_pix_data_out, --should be blue pixel data out
    pix_valid_out   		=> blue_pix_valid_out, --should be blue pixel valid out
    coeff_in                => coeff_in,
    coeff_in_valid          => coeff_in_valid,

    img_width               => img_width_in,
    img_height              => img_height_in
);

-- blue buffer
b_but: conv_buffer
generic map (
    NUM_BITS_PIXEL          => 8,
    NUM_BITS_ADDR           => 8,
    MAX_IMG_WIDTH           => 128,
    MAX_IMG_HEIGHT          => 128)
Port map (
	clk                     => clk,
    rst                     => rst,
    
	input_en => blue_buffer_input_en,
    input_done => blue_buffer_input_done,
   
    output_en => blue_buffer_output_en,
    output_done => blue_buffer_output_done,
    
    pix_valid_out => blue_pix_valid_out, --should be blue pixel data out 
    pix_data_out => blue_pix_data_out, --should be blue pixel valid out
    buffer_data_out => blue_buffer_data_out_intermediate, --should be blue buffer data out intermediate
    buffer_valid_out => blue_buffer_valid_out_intermediate, --should be blue buffer valid out intermediate
    
    img_width => img_width_in,
    img_height => img_height_in
);

-- rgb combiner unit
cut: rgb_combiner
generic map (
    NUM_BITS_PIXEL          => 8,
    NUM_BITS_ADDR           => 8,
    MAX_IMG_WIDTH           => 128,
    MAX_IMG_HEIGHT          => 128)
Port map (
	clk                     => clk,
    rst                     => rst,
    
    r_data                  => r_data_in,
    r_enable                => r_enable_in,
    
    g_data                  => g_data_in,
    g_enable                => g_enable_in,
    
    b_data                  => b_data_in,
    b_enable                => b_enable_in,
    
    input_mode_en           => input_mode_en,
    output_mode_en          => output_mode_en,
    combiner_data           => combiner_data_out,
    combiner_valid_out      => combiner_valid_out,
    
    combiner_output_done    => combiner_done_out,
    combiner_input_done     => combiner_done_in,
    
    img_width               => img_width_in,
    img_height              => img_height_in
);

-- Spiking Activation Layer
sut: spiking_activation_layer
generic map(
            NUM_BITS_PIXEL  => 8, -- 24 total = R + G + B (8-bits each)  
            NUM_BITS_ADDR   => 8,         
            MAX_IMG_WIDTH   => 128,
            MAX_IMG_HEIGHT   => 128
            )
    Port map( 
	        clk                     => clk,
            rst                     => rst,
           
            timesteps_to_calculate => timesteps_in, -- max 4 at once, 
           
            input_en => input_en_spiking,
            input_done => input_done_spiking,
           
            output_en => output_en_spiking,
            output_done => output_done_spiking,
            
            input_valid_out => input_valid_out_spiking,
            input_data_out => input_data_out_spiking,
           
            spiking_data_out => spiking_data_out,
            spiking_valid_out => spiking_valid_out,
           
            img_width       => img_width_in,
            img_height      => img_height_in         
            );



--red channel    
r_data_in <= red_buffer_data_out_intermediate;
r_enable_in <= red_buffer_valid_out_intermediate;
red_buffer_input_en <= buffer_input_en;
red_buffer_output_en <= buffer_output_en;

--green channel
g_data_in <= green_buffer_data_out_intermediate;
g_enable_in <= green_buffer_valid_out_intermediate;
green_buffer_input_en <= buffer_input_en;
green_buffer_output_en <= buffer_output_en;

--blue channel
b_data_in <= blue_buffer_data_out_intermediate;
b_enable_in <= blue_buffer_valid_out_intermediate;
blue_buffer_input_en <= buffer_input_en;
blue_buffer_output_en <= buffer_output_en;

--combiner to spiking activation
input_data_out_spiking <= combiner_data_out;
input_valid_out_spiking <= combiner_valid_out;
timesteps_in <= "01";



clk_proc: process
begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;        
end process;

process --buffer to combiner control process
begin
    loop
        wait until falling_edge(clk);
    end loop;
end process;


process	--input process simulation only
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

        end loop;    
    end loop;

    --end convolution calculations    

    pix_x <= (others=>'0');
    pix_y <= (others=>'0');
    pix_data_in <= (others=>'0');

    pix_valid_in <= '0';
    
	buffer_input_en <= '0'; -- disable input on buffers
	buffer_output_en <= '1'; -- enable output buffer
	
	input_mode_en <= '1'; -- enable rgb combiner
	
	while combiner_done_in = '0' loop
            wait until rising_edge(clk);	
	end loop;

    --combiner input done, activate spiking activation layer
    input_mode_en <= '0';
    output_mode_en <= '1'; 
    
    input_en_spiking <= '1';
    
    while input_done_spiking = '0' loop
            wait until rising_edge(clk);	
	end loop;
    

	wait for 200 us;
    --assert FALSE report "Done writing packet data." severity FAILURE;
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
