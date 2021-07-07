library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity read_bmp_tb is
end read_bmp_tb;

architecture sim of read_bmp_tb is

  type header_type  is array (0 to 53) of character;

  type pixel_type is record
    red : std_logic_vector(7 downto 0);
    green : std_logic_vector(7 downto 0);
    blue : std_logic_vector(7 downto 0);
  end record;

  type row_type is array (integer range <>) of pixel_type;
  type row_pointer is access row_type;
  type image_type is array (integer range <>) of row_pointer;
  type image_pointer is access image_type;

  -- DUT signals
  signal r_in : std_logic_vector(7 downto 0);
  signal g_in : std_logic_vector(7 downto 0);
  signal b_in : std_logic_vector(7 downto 0);
  signal r_out : std_logic_vector(7 downto 0);
  signal g_out : std_logic_vector(7 downto 0);
  signal b_out : std_logic_vector(7 downto 0);

begin

  DUT :entity work.grayscale(rtl)
  port map (
    r_in => r_in,
    g_in => g_in,
    b_in => b_in,
    r_out => r_out,
    g_out => g_out,
    b_out => b_out
  );

  process
    type char_file is file of character;
    file bmp_file : char_file open read_mode is "boeing.bmp";
    file out_file : char_file open write_mode is "out.bmp";
    variable header : header_type;
    variable image_width : integer;
    variable image_height : integer;
    variable row : row_pointer;
    variable image : image_pointer;
    variable padding : integer;
    variable char : character;
  begin

    -- Read entire header
    for i in header_type'range loop
      read(bmp_file, header(i));
    end loop;

    -- Check ID field
    assert header(0) = 'B' and header(1) = 'M'
      report "First two bytes are not ""BM"". This is not a BMP file"
      severity failure;

    -- Check that the pixel array offset is as expected
    assert character'pos(header(10)) = 54 and
      character'pos(header(11)) = 0 and
      character'pos(header(12)) = 0 and
      character'pos(header(13)) = 0
      report "Pixel array offset in header is not 54 bytes"
      severity failure;

    -- Check that DIB header size is 40 bytes,
    -- meaning that the BMP is of type BITMAPINFOHEADER
    assert character'pos(header(14)) = 40 and
      character'pos(header(15)) = 0 and
      character'pos(header(16)) = 0 and
      character'pos(header(17)) = 0
      report "DIB headers size is not 40 bytes, is this a Windows BMP?"
      severity failure;

    -- Check that the number of color planes is 1
    assert character'pos(header(26)) = 1 and
      character'pos(header(27)) = 0
      report "Color planes is not 1" severity failure;

    -- Check that the number of bits per pixel is 24
    assert character'pos(header(28)) = 24 and
      character'pos(header(29)) = 0
      report "Bits per pixel is not 24" severity failure;

    -- Read image width
    image_width := character'pos(header(18)) +
      character'pos(header(19)) * 2**8 +
      character'pos(header(20)) * 2**16 +
      character'pos(header(21)) * 2**24;

    -- Read image height
    image_height := character'pos(header(22)) +
      character'pos(header(23)) * 2**8 +
      character'pos(header(24)) * 2**16 +
      character'pos(header(25)) * 2**24;

    report "image_width: " & integer'image(image_width) &
      ", image_height: " & integer'image(image_height);

    -- Number of bytes needed to pad each row to 32 bits
    padding := (4 - image_width*3 mod 4) mod 4;

    -- Create a new image type in dynamic memory
    image := new image_type(0 to image_height - 1);

    for row_i in 0 to image_height - 1 loop

      -- Create a new row type in dynamic memory
      row := new row_type(0 to image_width - 1);

      for col_i in 0 to image_width - 1 loop

        -- Read blue pixel
        read(bmp_file, char);
        row(col_i).blue :=
          std_logic_vector(to_unsigned(character'pos(char), 8));

        -- Read green pixel
        read(bmp_file, char);
        row(col_i).green :=
          std_logic_vector(to_unsigned(character'pos(char), 8));

        -- Read red pixel
        read(bmp_file, char);
        row(col_i).red :=
          std_logic_vector(to_unsigned(character'pos(char), 8));

      end loop;

      -- Read and discard padding
      for i in 1 to padding loop
        read(bmp_file, char);
      end loop;

      -- Assign the row pointer to the image vector of rows
      image(row_i) := row;

    end loop;

    -- DUT test
    for row_i in 0 to image_height - 1 loop
      row := image(row_i);

      for col_i in 0 to image_width - 1 loop

        r_in <= row(col_i).red;
        g_in <= row(col_i).green;
        b_in <= row(col_i).blue;
        wait for 10 ns;

        row(col_i).red := r_out;
        row(col_i).green := g_out;
        row(col_i).blue := b_out;

      end loop;
    end loop;

    -- Write header to output file
    for i in header_type'range loop
      write(out_file, header(i));
    end loop;

    for row_i in 0 to image_height - 1 loop
      row := image(row_i);

      for col_i in 0 to image_width - 1 loop

        -- Write blue pixel
        write(out_file,
          character'val(to_integer(unsigned(row(col_i).blue))));

        -- Write green pixel
        write(out_file,
          character'val(to_integer(unsigned(row(col_i).green))));

        -- Write red pixel
        write(out_file,
          character'val(to_integer(unsigned(row(col_i).red))));

      end loop;

      deallocate(row);

      -- Write padding
      for i in 1 to padding loop
        write(out_file, character'val(0));
      end loop;

    end loop;

    deallocate(image);

    file_close(bmp_file);
    file_close(out_file);

    report "Simulation done. Check ""out.bmp"" image.";
    finish;
  end process;

end architecture;