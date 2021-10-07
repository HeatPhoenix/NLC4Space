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


entity conv2d_4x4 is
    generic (
            NUM_BITS_PIXEL  : natural := 8; -- 24 total = R + G + B (8-bits each) 
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
            img_height      : in std_logic_vector(NUM_BITS_ADDR-1 downto 0);
						
			ready			: out std_logic
		   );
end conv2d_4x4;

architecture Behavioral of conv2d_4x4 is

	constant NUM_BITS_INTERNAL	: natural := NUM_BITS_PIXEL*2;
    constant PIPELINE_LENGTH : natural := 7;
    
    signal pix_x_pipeline       : std_logic_vector(PIPELINE_LENGTH*NUM_BITS_ADDR-1 downto 0)    := (others=>'0');
    signal pix_y_pipeline       : std_logic_vector(PIPELINE_LENGTH*NUM_BITS_ADDR-1 downto 0)    := (others=>'0');
    signal pix_in_pipeline      : std_logic_vector(PIPELINE_LENGTH*NUM_BITS_PIXEL-1 downto 0):= (others=>'0');
    signal pix_valid_pipeline   : std_logic_vector(PIPELINE_LENGTH-1 downto 0)                  := (others=>'0');

    component pixbuf is
        generic (
            NUM_BITS_PIXEL  : natural := 8;
            NUM_BITS_ADDR   : natural := 8;
            MAX_IMG_WIDTH   : natural := 64;
            MAX_IMG_HEIGHT  : natural := 64
       );
        Port ( 
                clk        		: in STD_LOGIC;
                rst             : in std_logic;
                pix_valid_in 	: in STD_LOGIC;
                pix_y_in        : in std_logic_vector(NUM_BITS_ADDR-1 downto 0);
                pix_x_in        : in std_logic_vector(NUM_BITS_ADDR-1 downto 0);

                y1_out          : out std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);
                y2_out          : out std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);
                --y_out_valid     : out std_logic;
                
                y0_in           : in std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);
                y0_in_x         : in std_logic_vector(NUM_BITS_ADDR-1 downto 0);
                y0_in_y         : in std_logic_vector(NUM_BITS_ADDR-1 downto 0);
                y0_we           : in std_logic;

                y1_in           : in std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);
                y1_in_x         : in std_logic_vector(NUM_BITS_ADDR-1 downto 0);
                y1_in_y         : in std_logic_vector(NUM_BITS_ADDR-1 downto 0);
                y1_we           : in std_logic;
				
				img_width		: in std_logic_vector(NUM_BITS_ADDR-1 downto 0)
            );
    end component;

    signal y1_out       : std_logic_vector(NUM_BITS_INTERNAL-1 downto 0) := (others=>'0');
    signal y2_out       : std_logic_vector(NUM_BITS_INTERNAL-1 downto 0) := (others=>'0');

    signal y0_in        : std_logic_vector(NUM_BITS_INTERNAL-1 downto 0) := (others=>'0');
    signal y0_in_x      : std_logic_vector(NUM_BITS_ADDR-1 downto 0)    := (others=>'0');
    signal y0_in_y      : std_logic_vector(NUM_BITS_ADDR-1 downto 0)    := (others=>'0');
    signal y0_we        : std_logic                                     := '0';

    signal y1_in        : std_logic_vector(NUM_BITS_INTERNAL-1 downto 0) := (others=>'0');
    signal y1_in_x      : std_logic_vector(NUM_BITS_ADDR-1 downto 0)    := (others=>'0');
    signal y1_in_y      : std_logic_vector(NUM_BITS_ADDR-1 downto 0)    := (others=>'0');
    signal y1_we        : std_logic                                     := '0';

    type coeff_t is array (0 to 16-1) of signed(NUM_BITS_COEFF-1 downto 0);
    signal coeff        : coeff_t                                       := (others=>(others=>'0'));

    signal y00          : signed(NUM_BITS_INTERNAL-1 downto 0)         := (others=>'0');
    signal y10          : signed(NUM_BITS_INTERNAL-1 downto 0)         := (others=>'0');
    signal y20          : signed(NUM_BITS_INTERNAL-1 downto 0)         := (others=>'0');
    signal y30          : signed(NUM_BITS_INTERNAL-1 downto 0)         := (others=>'0');

    signal y01          : signed(NUM_BITS_INTERNAL-1 downto 0)         := (others=>'0');
    signal y11          : signed(NUM_BITS_INTERNAL-1 downto 0)         := (others=>'0');
    signal y21          : signed(NUM_BITS_INTERNAL-1 downto 0)         := (others=>'0');
    signal y31          : signed(NUM_BITS_INTERNAL-1 downto 0)         := (others=>'0');

    signal y02          : signed(NUM_BITS_INTERNAL-1 downto 0)         := (others=>'0');
    signal y12          : signed(NUM_BITS_INTERNAL-1 downto 0)         := (others=>'0');
    signal y22          : signed(NUM_BITS_INTERNAL-1 downto 0)         := (others=>'0');
    signal y32          : signed(NUM_BITS_INTERNAL-1 downto 0)         := (others=>'0');

    signal y03          : signed(NUM_BITS_INTERNAL-1 downto 0)         := (others=>'0');
    signal y13          : signed(NUM_BITS_INTERNAL-1 downto 0)         := (others=>'0');
    signal y23          : signed(NUM_BITS_INTERNAL-1 downto 0)         := (others=>'0');
    signal y33          : signed(NUM_BITS_INTERNAL-1 downto 0)         := (others=>'0');


    signal coeff_ctr    : unsigned(4 downto 0)                          := (others=>'0');

    signal image_done   : std_logic                                     := '0';
	signal dout			: signed(NUM_BITS_ADDR-1 downto 0);
	signal internal_pix_ctr	: unsigned(NUM_BITS_ADDR-1 downto 0) := (others=>'0');
	
	signal pix_valid_to_pixbuf : std_logic := '0';
	signal pix_x_to_pixbuf : std_logic_vector(NUM_BITS_ADDR-1 downto 0) := (others=>'0');
	signal pix_y_to_pixbuf : std_logic_vector(NUM_BITS_ADDR-1 downto 0) := (others=>'0');
	
	signal pix_data_out_reg : std_logic_vector(NUM_BITS_INTERNAL-1 downto 0) := (others=>'0');
	signal pix_valid_out_reg : std_logic := '0';
begin

ready <= not image_done;

process(clk)
begin
    if rising_edge(clk) then
        pix_valid_out <= '0';
		pix_valid_out_reg <= '0';
        if ((pix_valid_in = '1' or image_done = '1')) then

            -- shift all input data we get into shift registers
            pix_valid_pipeline              <= pix_valid_pipeline(PIPELINE_LENGTH-2 downto 0) & pix_valid_in;
			if (image_done = '0') then
				pix_in_pipeline             <= pix_in_pipeline((PIPELINE_LENGTH-1)*NUM_BITS_PIXEL-1 downto 0) & std_logic_vector(resize(signed(pix_data_in), NUM_BITS_PIXEL));
				pix_y_pipeline              <= pix_y_pipeline((PIPELINE_LENGTH-1)*NUM_BITS_ADDR-1 downto 0) & pix_y;
				pix_x_pipeline              <= pix_x_pipeline((PIPELINE_LENGTH-1)*NUM_BITS_ADDR-1 downto 0) & pix_x;
			else
				pix_in_pipeline             <= pix_in_pipeline((PIPELINE_LENGTH-1)*NUM_BITS_PIXEL-1 downto 0) & std_logic_vector(to_unsigned(0, NUM_BITS_PIXEL));
				pix_y_pipeline              <= pix_y_pipeline((PIPELINE_LENGTH-1)*NUM_BITS_ADDR-1 downto 0) & std_logic_vector(resize(unsigned(img_height)+1, NUM_BITS_ADDR));
				pix_x_pipeline              <= pix_x_pipeline((PIPELINE_LENGTH-1)*NUM_BITS_ADDR-1 downto 0) & std_logic_vector(resize(unsigned(internal_pix_ctr), NUM_BITS_ADDR));
				pix_valid_pipeline          <= pix_valid_pipeline(PIPELINE_LENGTH-2 downto 0) & '1';

				internal_pix_ctr <= internal_pix_ctr + 1;
			end if;
            -- 
            if (unsigned(pix_y) = unsigned(img_height) and unsigned(pix_x) = unsigned(img_width)+1) then
                image_done <= '1';
            elsif (unsigned(internal_pix_ctr) = unsigned(img_width)+3) then
                image_done <= '0';
				internal_pix_ctr <= (others=>'0');
            end if;
			
            -- we can calculate the first row of the filter matrix immediately
            if (pix_valid_in = '1') then
                y00 <= resize(coeff(0) * signed(pix_data_in),y00'length); --P(0,0)*c0
            end if;
			
            if (pix_valid_pipeline(0) = '1') then
                y01 <= resize(coeff(1) * signed(pix_data_in) + y00,y01'length); --P(0,1)*c1
            end if;

            if (pix_valid_pipeline(1) = '1') then
                y02 <= resize(coeff(2) * signed(pix_data_in) + y01, y02'length); --P(0,2)*c2
				if (image_done = '1') then
					y02 <= (others=>'0');
				end if;
            end if;

            -- delay until we get valid data from linebuffers is exactly 2 cycles. we can calculate the second and third row of the filter matrix
            if (pix_valid_pipeline(1) = '1') then
                -- now we can calculate y10 and y20
                y10 <= resize(coeff(3) * signed(pix_in_pipeline(2*NUM_BITS_PIXEL-1 downto 1*NUM_BITS_PIXEL)) + signed(y1_out), NUM_BITS_INTERNAL); --P(1,0)*c3
                y20 <= resize(coeff(6) * signed(pix_in_pipeline(2*NUM_BITS_PIXEL-1 downto 1*NUM_BITS_PIXEL)) + signed(y2_out), NUM_BITS_INTERNAL); --P(2,0)*c6
            end if;
			
            if (pix_valid_pipeline(2) = '1') then
                -- now we can calculate y11 and y21
                y11 <= resize(coeff(4) * signed(pix_in_pipeline(2*NUM_BITS_PIXEL-1 downto 1*NUM_BITS_PIXEL)) + y10, NUM_BITS_INTERNAL); --P(1,1)*c4 
                y21 <= resize(coeff(7) * signed(pix_in_pipeline(2*NUM_BITS_PIXEL-1 downto 1*NUM_BITS_PIXEL)) + y20, NUM_BITS_INTERNAL); --P(2,1)*c7 
				
            end if;

            if (pix_valid_pipeline(3) = '1') then
                -- now we can calculate y11 and y21
                y12 <= resize(coeff(5) * signed(pix_in_pipeline(2*NUM_BITS_PIXEL-1 downto 1*NUM_BITS_PIXEL)) + y11, NUM_BITS_INTERNAL); --P(1,2)*c5 
				if (unsigned(pix_y_pipeline(4*NUM_BITS_ADDR-1 downto 3*NUM_BITS_ADDR)) > unsigned(img_height)) then
					y12 <= (others=>'0');
				end if;                
				-- output data if we have to
                if (unsigned(pix_y_pipeline(4*NUM_BITS_ADDR-1 downto 3*NUM_BITS_ADDR)) > 1 and unsigned(pix_x_pipeline(4*NUM_BITS_ADDR-1 downto 3*NUM_BITS_ADDR)) < unsigned(img_width)) then
                    pix_data_out_reg <= std_logic_vector(resize(coeff(8) * signed(pix_in_pipeline(2*NUM_BITS_PIXEL-1 downto 1*NUM_BITS_PIXEL)) + y21, pix_data_out_reg'length)); --P(2,2)*c8 
                    pix_valid_out_reg <= '1';
                end if;
            end if;
        end if;
		
		pix_valid_out <= pix_valid_out_reg;
		pix_data_out <= pix_data_out_reg;
		
    end if; 
end process;

-- process to load in coefficients
process(clk)
begin
    if rising_edge(clk) then
        if (rst = '1') then
			coeff_ctr <= to_unsigned(0, coeff_ctr'length);
			coeff <= (others=>(others=>'0'));
		else
			if (coeff_in_valid = '1') then
				if (coeff_ctr < 16) then
					coeff(to_integer(coeff_ctr)) <= signed(coeff_in);
					coeff_ctr <= coeff_ctr + 1; 
				else
					-- if we are reloading coefficients this case is reached
					coeff(0) <= signed(coeff_in);
					coeff_ctr <= to_unsigned(1, coeff_ctr'length);
				end if;
			end if;
        end if;
    end if; 
end process;

-- this process ensures we only feed zeros to the line buffers when we are at the bottom padding
-- this will shift out all the remaining data and clear the buffers
process (image_done, pix_x,internal_pix_ctr,pix_valid_in)
begin
if (image_done = '0') then
	pix_valid_to_pixbuf <= pix_valid_in;
	pix_x_to_pixbuf <= pix_x;
	pix_y_to_pixbuf <= pix_y;
else
	pix_valid_to_pixbuf <= '1';
	pix_x_to_pixbuf <= std_logic_vector(internal_pix_ctr);
	pix_y_to_pixbuf <= std_logic_vector(unsigned(img_height) + 1);
end if;

end process;

buf: pixbuf 
Generic map (
    NUM_BITS_PIXEL  => NUM_BITS_PIXEL,
    NUM_BITS_ADDR   => NUM_BITS_ADDR,
    MAX_IMG_WIDTH   => MAX_IMG_WIDTH,
    MAX_IMG_HEIGHT  => MAX_IMG_HEIGHT
)
Port map(
    clk        		=> clk,
    rst             => rst,

    pix_valid_in 	=> pix_valid_to_pixbuf,
    pix_y_in        => pix_y_to_pixbuf,
    pix_x_in        => pix_x_to_pixbuf,

    y1_out          => y1_out,
    y2_out          => y2_out,
    
    y0_in           => std_logic_vector(y02),
    y0_in_x         => pix_x_pipeline(3*NUM_BITS_ADDR-1 downto 2*NUM_BITS_ADDR),
    y0_in_y         => pix_y_pipeline(3*NUM_BITS_ADDR-1 downto 2*NUM_BITS_ADDR),
    y0_we           => pix_valid_pipeline(2),

    y1_in           => std_logic_vector(y12),
    y1_in_x         => pix_x_pipeline(5*NUM_BITS_ADDR-1 downto 4*NUM_BITS_ADDR),
    y1_in_y         => pix_y_pipeline(5*NUM_BITS_ADDR-1 downto 4*NUM_BITS_ADDR),
    y1_we           => pix_valid_pipeline(4),
	
	img_width		=> img_width

);
end Behavioral;