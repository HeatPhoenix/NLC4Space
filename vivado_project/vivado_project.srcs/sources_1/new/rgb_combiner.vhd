----------------------------------------------------------------------------------
-- Company: TU Delft, ESA
-- Engineer: Zacharia Rudge
-- 
-- Create Date: 07/06/2021 01:37:46 AM
-- Design Name: 
-- Module Name: rgb_combiner - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Accepts three buffers, which are then combined into one buffer for the next layer.
-- The operation performed on the data is currently addition.
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

entity rgb_combiner is
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
           combiner_output_done : out STD_LOGIC := '0';
           combiner_input_done : out STD_LOGIC := '0';
           
           img_width       : in std_logic_vector(NUM_BITS_ADDR-1 downto 0);
           img_height      : in std_logic_vector(NUM_BITS_ADDR-1 downto 0)
           );      
end rgb_combiner;

architecture Behavioral of rgb_combiner is

type channel_buffer is array (MAX_IMG_WIDTH-1 downto 0, MAX_IMG_HEIGHT-1 downto 0) of STD_LOGIC_VECTOR (2*NUM_BITS_PIXEL-1 downto 0); -- 64x64 buffer for either R, G or B channel
signal result_buffer : channel_buffer := (others=>(others=> (others=>'0'))); -- Access as result_buffer(x, y);

signal x_pos_in : std_logic_vector(NUM_BITS_ADDR-1 downto 0)    := (others=>'0'); -- current position in the data
signal y_pos_in : std_logic_vector(NUM_BITS_ADDR-1 downto 0)    := (others=>'0'); --

signal x_pos_out : std_logic_vector(NUM_BITS_ADDR-1 downto 0)    := (others=>'0'); -- current position in the data
signal y_pos_out : std_logic_vector(NUM_BITS_ADDR-1 downto 0)    := (others=>'0'); --

signal input_done_internal : std_logic := '0';
signal output_done_internal : std_logic := '0';

signal intermediate_data : std_logic_vector(2*NUM_BITS_PIXEL-1  downto 0) := (others=>'0');
signal intermediate_r_data : std_logic_vector(2*NUM_BITS_PIXEL-1  downto 0) := (others=>'0');
signal intermediate_g_data : std_logic_vector(2*NUM_BITS_PIXEL-1  downto 0) := (others=>'0');
signal intermediate_b_data : std_logic_vector(2*NUM_BITS_PIXEL-1  downto 0) := (others=>'0');

signal dummy_output_cycle_flag : std_logic := '0';

begin

combiner_output_done <= output_done_internal;
combiner_input_done <= input_done_internal;
intermediate_r_data <= r_data;
intermediate_g_data <= g_data;
intermediate_b_data <= b_data;

process --input process
begin
    loop
        wait until rising_edge(clk);
        if (input_mode_en = '1') and (input_done_internal = '0') then -- read output for 1 pixel in the image
            
            if (dummy_output_cycle_flag = '1') then
                x_pos_in <= x_pos_in + 1;
            elsif(dummy_output_cycle_flag = '0') and (x_pos_in = 0) then
                dummy_output_cycle_flag <= '1';
            end if;
            
            if (x_pos_in > img_width-2) then -- should be img_width
                x_pos_in <= (others => '0');
                y_pos_in <= y_pos_in + 1;
                if(y_pos_in > img_height-2) then --should be img_height
                    y_pos_in <= (others => '0');
                    input_done_internal <= '1';
                end if;
            end if;
            
            --collect the pix_data into r, g and b value (combinational)
            
            --do operation here (addition)
            result_buffer(to_integer(unsigned(x_pos_in)), to_integer(unsigned(y_pos_in))) <= std_logic_vector(unsigned(intermediate_r_data) + unsigned(intermediate_g_data) + unsigned(intermediate_b_data));   
            intermediate_data <= std_logic_vector(unsigned(intermediate_r_data) + unsigned(intermediate_g_data) + unsigned(intermediate_b_data));    --for simulation purposes only

        end if;
    end loop;
end process;


process --input process
begin
    loop
        wait until falling_edge(clk);
        --falling edge logic (moved to rising edge)
    end loop;
end process;

process --output process (WIP)
begin
    loop
        wait until rising_edge(clk);
        if (output_mode_en = '1') and (output_done_internal = '0') then -- write output for 1 pixel in the image
            combiner_valid_out <= '0';
            combiner_data <= result_buffer(to_integer(unsigned(x_pos_out)), to_integer(unsigned(y_pos_out))); --reveal one entry on output line
            x_pos_out <= x_pos_out + 1;
            if (x_pos_out > img_width-2) then
                x_pos_out <= (others => '0');
                y_pos_out <= y_pos_out + 1;
                if(y_pos_out > img_height-2) then
                    y_pos_out <= (others => '0');
                    output_done_internal <= '1';
                end if;
            end if;
            combiner_valid_out <= '1';
        end if;
    end loop;
end process;

end Behavioral;
