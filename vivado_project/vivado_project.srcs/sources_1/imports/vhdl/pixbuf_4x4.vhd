-- (c) 2020 B. Koch
-- This code is licensed under MIT license (see LICENSE.txt for details)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity pixbuf_4x4 is
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
end pixbuf_4x4;

architecture Behavioral of pixbuf_4x4 is 

    type lineBuffer_t is array (0 to MAX_IMG_WIDTH-1) of std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);

    signal linebuffer0 : lineBuffer_t := (others=>(others=>'0'));
    signal linebuffer1 : lineBuffer_t := (others=>(others=>'0'));
    signal linebuffer2 : lineBuffer_t := (others=>(others=>'0'));

    -- data coming from the linebuffers will be registered to reduce the critical path
    signal data_from_linebuffer0   		 : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0) := (others=>'0');
    signal data_from_linebuffer1    	 : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0) := (others=>'0');   
    signal data_from_linebuffer2    	 : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0) := (others=>'0');  
	
	signal lb0_we, lb1_we, lb2_we : std_logic := '0';
	signal lb0_addrin, lb1_addrin, lb2_addrin : std_logic_vector(8 downto 0) := (others=>'0');
	
	signal lb0_din, lb1_din, lb2_din : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0) := (others=>'0');
	signal y1_out_test, y2_out_test, y3_out_test : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0) := (others=>'0');
	-- this signal decides wo which output the last word read from the linebuffer will go
	signal output_map		: std_logic := '0';
begin

-- the most important thing is that vivado infers a block ram for our linebuffers
process(clk)
	variable lb0_data : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);
	variable lb1_data : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);
	variable lb2_data : std_logic_vector(2*NUM_BITS_PIXEL-1 downto 0);
    begin
        if rising_edge(clk) then
			lb0_we <= '0';
			lb1_we <= '0';
			lb2_we <= '0';
            if (rst = '1') then
            else
                if (pix_valid_in = '1' and unsigned(pix_x_in) < unsigned(img_width)+2) then
                    -- as long as we have input data and are not at the zero padding we need to read data from the linebuffer
				    data_from_linebuffer0 <= linebuffer0(to_integer(unsigned(pix_x_in)));
                    data_from_linebuffer1 <= linebuffer1(to_integer(unsigned(pix_x_in)));
                    data_from_linebuffer2 <= linebuffer2(to_integer(unsigned(pix_x_in)));
                    -- depending on the current y data has to be written on y1 or y2
                    if (unsigned(pix_y_in) mod 2 = 1) then
						 output_map <= '0';
                    else
						output_map <= '1';
                    end if;
					if (output_map = '0') then
						y2_out <= data_from_linebuffer1;
						y1_out <= data_from_linebuffer0;
					else
						y2_out <= data_from_linebuffer0;
						y1_out <= data_from_linebuffer1;
					end if;
                end if;
                
                if (y0_we = '1' and unsigned(y0_in_x) < unsigned(img_width)) then
                    -- as long as we have input data and the current row is not the bottom zero padding write into the linebuffer
                    if (unsigned(y0_in_y) mod 2 = 0) then
                        lb0_din <= y0_in;
						lb0_we <= '1';
						lb0_addrin <= std_logic_vector(resize(unsigned(y0_in_x), lb0_addrin'length));
                    else
                        lb1_din <= y0_in;
						lb1_we <= '1';
						lb1_addrin <= std_logic_vector(resize(unsigned(y0_in_x), lb1_addrin'length));
                    end if;
                end if;
                
                if (y1_we = '1' and unsigned(y1_in_x) < unsigned(img_width)) then				
                    if (unsigned(y1_in_y) mod 2 = 0) then
						lb1_din <= y1_in;
						lb1_we <= '1';
						lb1_addrin <= std_logic_vector(resize(unsigned(y1_in_x), lb1_addrin'length));
                    else
						lb0_din <= y1_in;
						lb0_we <= '1';
						lb0_addrin <= std_logic_vector(resize(unsigned(y1_in_x), lb0_addrin'length));
                    end if;
                end if;
                
                -- writes are also registered to reduce critical path
				if (lb0_we = '1') then
					linebuffer0(to_integer(unsigned(lb0_addrin))) <= lb0_din;
				end if;
			
				if (lb1_we = '1') then
					linebuffer1(to_integer(unsigned(lb1_addrin))) <= lb1_din;
				end if;
			end if;
        end if;
    end process;
end Behavioral;
