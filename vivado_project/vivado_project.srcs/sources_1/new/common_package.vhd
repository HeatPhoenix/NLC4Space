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

constant SFIXED_COMMON_ZERO : SFIXED(NUM_BITS_FIXED_INT_package downto NUM_BITS_FIXED_FRAC_package) := to_sfixed(0, NUM_BITS_FIXED_INT_package, NUM_BITS_FIXED_FRAC_package);
subtype SFIXED_COMMON_SIZE is SFIXED(NUM_BITS_FIXED_INT_package downto NUM_BITS_FIXED_FRAC_package);

type SFIXED_VECTOR is array(INTEGER range <>) of SFIXED(NUM_BITS_FIXED_INT_package downto NUM_BITS_FIXED_FRAC_package);
type SFIXED_VECTOR_AVG_SET is array(3 downto 0) of  SFIXED(NUM_BITS_FIXED_INT_package downto NUM_BITS_FIXED_FRAC_package);
type SFIXED_VECTOR_AVG_SET_VECTOR is array(511 downto 0) of SFIXED_VECTOR_AVG_SET;


function to_sfixed_common(X : real)
                            return SFIXED_COMMON_SIZE;
                            
function resize_common(X : SFIXED) 
                            return SFIXED_COMMON_SIZE;                        

end common_package;
                            
package body common_package is
    function to_sfixed_common(X : real)
                                return SFIXED_COMMON_SIZE is
    begin
        return to_sfixed(X, SFIXED_COMMON_SIZE'high, SFIXED_COMMON_SIZE'low);
    end to_sfixed_common;
    
    function resize_common(X : SFIXED)
                                return SFIXED_COMMON_SIZE is
    begin
        return resize(X, SFIXED_COMMON_SIZE'high, SFIXED_COMMON_SIZE'low);
    end resize_common;
end common_package;
