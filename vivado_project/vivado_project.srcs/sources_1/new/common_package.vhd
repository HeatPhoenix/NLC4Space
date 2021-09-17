----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/13/2021 11:20:41 PM
-- Design Name: 
-- Module Name: common_package - Behavioral
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

package common_package is

constant NUM_BITS_FIXED_INT_package : integer := 4;
constant NUM_BITS_FIXED_FRAC_package : integer := -11;

type SFIXED_VECTOR is array(INTEGER range <>) of SFIXED(NUM_BITS_FIXED_INT_package downto NUM_BITS_FIXED_FRAC_package);

end common_package;
