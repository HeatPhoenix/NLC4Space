----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/21/2021 12:02:00 AM
-- Design Name: 
-- Module Name: global_average_pooling - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
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

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

use work.common_package.all;

entity global_average_pooling is
    Port ( clk  : in std_logic;
           rst  : in std_logic;
           lowpass_layer_result : in SFIXED_VECTOR_AVG_SET_VECTOR; -- 512x4 (a, b, c, d)
           pooling_result : out SFIXED_VECTOR (511 downto 0));
end global_average_pooling;

architecture Behavioral of global_average_pooling is

begin

process(clk, rst) is 
begin 
    if (rst = '1') then
    elsif rising_edge(clk) then
        for I in pooling_result'low to pooling_result'high loop
            pooling_result(I) <=    resize(((lowpass_layer_result(I)(0) + 
                                    lowpass_layer_result(I)(1) + 
                                    lowpass_layer_result(I)(2) + 
                                    lowpass_layer_result(I)(3)) srl 2), pooling_result(I)'high, pooling_result(I)'low);
        end loop;
    end if;
end process;


end Behavioral;
