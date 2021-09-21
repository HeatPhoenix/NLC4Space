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
-- Description: Contains convenience procedures, types and so on.
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
type SFIXED_VECTOR_AVG_SET is array(3 downto 0) of  SFIXED(NUM_BITS_FIXED_INT_package downto NUM_BITS_FIXED_FRAC_package);
type SFIXED_VECTOR_AVG_SET_VECTOR is array(511 downto 0) of SFIXED_VECTOR_AVG_SET;

end common_package;
