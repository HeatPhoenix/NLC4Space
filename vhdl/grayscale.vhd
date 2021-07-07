library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity grayscale is
  port (
    -- RGB input
    r_in : in std_logic_vector(7 downto 0);
    g_in : in std_logic_vector(7 downto 0);
    b_in : in std_logic_vector(7 downto 0);

    -- RGB output
    r_out : out std_logic_vector(7 downto 0);
    g_out : out std_logic_vector(7 downto 0);
    b_out : out std_logic_vector(7 downto 0)
  );
end grayscale; 

architecture rtl of grayscale is

  signal luma : std_logic_vector(7 downto 0);

  signal r_weighted : unsigned(7 downto 0);
  signal g_weighted : unsigned(7 downto 0);
  signal b_weighted : unsigned(7 downto 0);

begin

  r_out <= std_logic_vector(luma);
  g_out <= std_logic_vector(luma);
  b_out <= std_logic_vector(luma);

  r_weighted <= unsigned("00" & r_in(7 downto 2));
  g_weighted <= unsigned("0" & g_in(7 downto 1));
  b_weighted <= unsigned("0000" & b_in(7 downto 4));

  -- Fixed point approximation of luma from RGB
  -- ITU-R BT.2100 from en.wikipedia.org/wiki/Grayscale
  -- Y = 0.2627R + 0.6780G + 0.0593B
  luma <= std_logic_vector(r_weighted + g_weighted + b_weighted);

end architecture;