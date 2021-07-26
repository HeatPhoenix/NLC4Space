----------------------------------------------------------------------------------
-- Company: TU Delft, ESA
-- Engineer: Zacharia Rudge
-- 
-- Create Date: 07/08/2021 11:51:45 PM
-- Design Name: 
-- Module Name: spiking_activation_layer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Multiplies the buffer value from the previous layer by the size of a spike
-- this value is then stored in a buffer which can be read by the next layer.
--
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spiking_activation_layer is
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
            
           input_valid_out : in STD_LOGIC := '0'; -- previous layer's output, our input
           input_data_out : in STD_LOGIC_VECTOR (2*NUM_BITS_PIXEL-1 downto 0); 
           
           spiking_data_out : out STD_LOGIC_VECTOR(2*NUM_BITS_PIXEL-1 downto 0) := (others => '0');
           spiking_valid_out : out STD_LOGIC := '0';--aka buffer has been filled 
           
           img_width       : in std_logic_vector(NUM_BITS_ADDR-1 downto 0);
           img_height      : in std_logic_vector(NUM_BITS_ADDR-1 downto 0)         
           );
end spiking_activation_layer;

architecture Behavioral of spiking_activation_layer is
type channel_buffer is array (MAX_IMG_WIDTH-1 downto 0, MAX_IMG_HEIGHT-1 downto 0) of STD_LOGIC_VECTOR (2*NUM_BITS_PIXEL-1 downto 0); -- 64x64 buffer for either R, G or B channel
signal spike_buffer : channel_buffer := (others=>(others=> (others=>'0'))); -- Access as spike_buffer(x, y);

signal x_pos_in : std_logic_vector(NUM_BITS_ADDR-1 downto 0)    := (others=>'0'); -- current position in the data
signal y_pos_in : std_logic_vector(NUM_BITS_ADDR-1 downto 0)    := (others=>'0'); -- for input

signal x_pos_out : std_logic_vector(NUM_BITS_ADDR-1 downto 0)    := (others=>'0'); -- current position in the data
signal y_pos_out : std_logic_vector(NUM_BITS_ADDR-1 downto 0)    := (others=>'0'); -- for output

signal input_done_internal : std_logic := '0';
signal output_done_internal : std_logic := '0';


begin

input_done <= input_done_internal;
output_done <= output_done_internal;

 process (clk, rst) --input process
 begin
    if rst = '1' then
        
    elsif rising_edge(clk) then
        if (input_valid_out = '1') and (input_en = '1') and (input_done_internal = '0') then -- read output for 1 pixel in the image
            x_pos_in <= x_pos_in + 1;
            
            if (x_pos_in > img_width-2) then -- should be img_width
                x_pos_in <= (others => '0');
                y_pos_in <= y_pos_in + 1;
                if(y_pos_in > img_height-2) then --should be img_height
                    y_pos_in <= (others => '0');
                    input_done_internal <= '1';
                end if;
            end if;
            
            --spike_buffer(to_integer(unsigned(x_pos_in)), to_integer(unsigned(y_pos_in))) <= conv_data_out; --update one entry
        end if;
    end if;
end process;


process --input process falling clock
begin
    loop
        wait until falling_edge(clk);
            if timesteps_to_calculate = "01" then -- no multiplication
                spike_buffer(to_integer(unsigned(x_pos_in)), to_integer(unsigned(y_pos_in))) <= input_data_out;
            else
                spike_buffer(to_integer(unsigned(x_pos_in)), to_integer(unsigned(y_pos_in))) <= input_data_out * timesteps_to_calculate; --update one entry
                --multiplication of timesteps (doing it with shifts would be great)
            end if;
    end loop;
end process;

 process (clk, rst) --output process, delay by one cycle
 begin
    if rst = '1' then
        
    elsif rising_edge(clk) then
        spiking_valid_out <= '0';
        spiking_data_out <= (others => '0');
        if (output_en = '1') and (output_done_internal = '0') then -- write output for 1 pixel in the image
            spiking_data_out <= spike_buffer(to_integer(unsigned(x_pos_out)), to_integer(unsigned(y_pos_out))); --reveal one entry on output line
            x_pos_out <= x_pos_out + 1;
            if (x_pos_out > img_width-2) then
                x_pos_out <= (others => '0');
                y_pos_out <= y_pos_out + 1;
                if(y_pos_out > img_height-2) then
                    y_pos_out <= (others => '0');
                    output_done_internal <= '1';
                end if;
            end if;
            spiking_valid_out <= '1';
        end if;
    end if;
end process;


end Behavioral;