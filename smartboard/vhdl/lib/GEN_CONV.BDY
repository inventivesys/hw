-- +---------------------------+
-- |   Copyright 1996 DOULOS   |
-- |      Generic Library      |
-- |    opened: 26 Nov 1995    |
-- +---------------------------+

-- Synthesis script: read -f vhdl gen_conv.bdy

library ieee;
library vfp;

package body generic_conversions is
  use ieee.std_logic_1164.all;
  use vfp.twos_complement_types.all;
  use vfp.generic_functions.all;

-- std_ulogic_vector -> integer
function to_integer (
  a: std_ulogic_vector
) return integer is
  variable y: integer := 0;
begin
  y := 0;
  if (a'length < 32) then
    for i in a'length-1 downto 0 loop
      y := y * 2;
      if (a(i) = '1') or (a(i) = 'H') then
        y := y + 1;
      elsif (a(i) = 'U') or (a(i) = 'X') or (a(i) = 'Z') or
            (a(i) = 'W') or (a(i) = '-') then
			  y := y + 0;
--        assert false
--          report "Error 0001." & 
--                 "Library = vfp." & 
--                 "Package Body = generic_conversions." & 
--                 "Function = to_integer." & 
--                 "The std_ulogic_vector input to this function MUST contain 0, 1, L, or H."
--          severity error;
--      upon this assertion, 0 will have effectively been added to y
--    else y := y + 0; thus there's no update to y for this "bit" anyway
      end if;       
    end loop;
  else
    assert false
      report "Error 0002." & 
             "Library = vfp." & 
             "Package Body = generic_conversions." & 
             "Function = to_integer." & 
             "The std_ulogic_vector input to this function MUST be less than 32 bits."
      severity error;
  end if;
  return y;      -- y returns 0 if std_ulogic_vector is > 31 bits
end to_integer; 

-- std_logic_vector -> integer
function to_integer (
  a: std_logic_vector
) return integer is
  variable y: integer := 0;
begin
  y := 0;
  if (a'length < 32) then
    for i in a'length-1 downto 0 loop
      y := y * 2;
      if (a(i) = '1') or (a(i) = 'H') then
        y := y + 1;
      elsif (a(i) = 'U') or (a(i) = 'X') or (a(i) = 'Z') or
            (a(i) = 'W') or (a(i) = '-') then
			  y := y + 0;
--        assert false
--          report "Error 0001." & 
--                 "Library = vfp." & 
--                 "Package Body = generic_conversions." & 
--                 "Function = to_integer." & 
--                 "The std_logic_vector input to this function MUST contain 0, 1, L, or H."
--          severity error;
--      upon this assertion, 0 will have effectively been added to y
--    else y := y + 0; thus there's no update to y for this "bit" anyway
      end if;       
    end loop;
  else
    assert false
      report "Error 0002." & 
             "Library = vfp." & 
             "Package Body = generic_conversions." & 
             "Function = to_integer." & 
             "The std_logic_vector input to this function MUST be less than 32 bits."
      severity error;
  end if;
  return y;      -- y returns 0 if std_logic_vector is > 31 bits
end to_integer; 

-- 2's complement -> integer
function to_integer (
  a: twos_complement
) return integer is
  variable y: integer := 0;
begin
  if (a(a'length-1) = '1') or (a(a'length-1) = 'H') then
    y := -1;
  elsif (a(a'length-1) = 'U') or (a(a'length-1) = 'X') or (a(a'length-1) = 'Z') or
        (a(a'length-1) = 'W') or (a(a'length-1) = '-') then
		y := 0; -- was integer'low
--    assert false
--      report "Warning 0001." & 
--             "Library = vfp." & 
--             "Package Body = generic_conversions." & 
--             "Function = to_integer (input = 2's complement)." & 
--             "The 2's complement input to this function MUST contain 0, 1, L, or H."
--      severity warning;
--  upon this assertion, y will still be uninitialized
  else       -- a(i'length-1) is '0' or 'L'
    y := 0;       
  end if;         
  for i in a'length-2 downto 0 loop
    y := y * 2;
    if (a(i) = '1') or (a(i) = 'H') then
      y := y + 1;
    elsif (a(i) = 'U') or (a(i) = 'X') or (a(i) = 'Z') or
          (a(i) = 'W') or (a(i) = '-') then
		  y := y + 0;
--      assert false
--        report "Warning 0002." & 
--               "Library = vfp." & 
--               "Package Body = generic_conversions." & 
--               "Function = to_integer (input = 2's complement)." & 
--               "The 2's complement input to this function MUST contain 0, 1, L, or H."
--        severity warning;
--    upon this assertion, 0 will have effectively been added to y
--  else y := y + 0; thus there's no update to y for this "bit" anyway
    end if;       
  end loop;
  return y;
end to_integer; 

-- integer -> std_ulogic_vector
function to_std_ulogic_vector (
  a: integer
) return std_ulogic_vector is
  constant y_length: integer := integer_wordlength (a);
  constant a_threshold: integer := next_greater_binary_power_minus_1 (a);
  variable y_ref: integer;
  variable y: integer;
  variable y_std_ulogic_vector: std_ulogic_vector(y_length-1 downto 0);
begin
  y := a;                               -- y is a temp variable for conversion
  if (a >= 0) then
    y_ref := (a_threshold / 2) + 1;    -- set the initial threshold for comparison
    y_std_ulogic_vector(y_length-1) := '0';
    for i in y_length-2 downto 0 loop   -- perform algorithmic conversion of positive
      if (y < y_ref) then
        y_std_ulogic_vector(i) := '0';
      else
        y := y - y_ref;                 -- y = 0 signifies the end of the process    
        y_std_ulogic_vector(i) := '1';
      end if;                           
      y_ref := y_ref / 2;
    end loop;
  else
    y_ref := -(a_threshold / 2) - 1;   -- set the initial threshold for comparison
    y_std_ulogic_vector(y_length-1) := '1';
    for i in y_length-2 downto 0 loop   -- perform algorithmic conversion of negative
      if (y >= y_ref) then
        y_std_ulogic_vector(i) := '1';
      else
        y := y - y_ref;                 -- y = -1 at the end of the process     
        y_std_ulogic_vector(i) := '0';
      end if; 
      y_ref := y_ref / 2;
    end loop;  
  end if;
  return y_std_ulogic_vector;
end to_std_ulogic_vector; 

-- integer -> std_logic_vector
function to_std_logic_vector (
  a: integer
) return std_logic_vector is
  constant y_length: integer := integer_wordlength (a);
  constant a_threshold: integer := next_greater_binary_power_minus_1 (a);
  variable y_ref: integer;
  variable y: integer;
  variable y_std_logic_vector: std_logic_vector(y_length-1 downto 0);
begin
  y := a;                               -- y is a temp variable for conversion
  if (a >= 0) then
    y_ref := (a_threshold / 2) + 1;    -- set the initial threshold for comparison
    y_std_logic_vector(y_length-1) := '0';
    for i in y_length-2 downto 0 loop   -- perform algorithmic conversion of positive
      if (y < y_ref) then
        y_std_logic_vector(i) := '0';
      else
        y := y - y_ref;                 -- y = 0 signifies the end of the process    
        y_std_logic_vector(i) := '1';
      end if;                           
      y_ref := y_ref / 2;
    end loop;
  else
    y_ref := -(a_threshold / 2) - 1;   -- set the initial threshold for comparison
    y_std_logic_vector(y_length-1) := '1';
    for i in y_length-2 downto 0 loop   -- perform algorithmic conversion of negative
      if (y >= y_ref) then
        y_std_logic_vector(i) := '1';
      else
        y := y - y_ref;                 -- y = -1 at the end of the process     
        y_std_logic_vector(i) := '0';
      end if; 
      y_ref := y_ref / 2;
    end loop;  
  end if;
  return y_std_logic_vector;
end to_std_logic_vector; 

-- integer -> std_ulogic_vector
function to_std_ulogic_vector (
  a: integer;
  width: integer
) return std_ulogic_vector is
  constant y_length: integer := width;
  constant a_threshold: integer := 2 ** (width-2);
  variable y_ref: integer;
  variable y: integer;
  variable y_std_ulogic_vector: std_ulogic_vector(y_length-1 downto 0);
begin
  y := a;                               -- y is a temp variable for conversion
  if (a >= 0) then
    y_ref := a_threshold;    -- set the initial threshold for comparison
    y_std_ulogic_vector(y_length-1) := '0';
    for i in y_length-2 downto 0 loop   -- perform algorithmic conversion of positive
      if (y < y_ref) then
        y_std_ulogic_vector(i) := '0';
      else
        y := y - y_ref;                 -- y = 0 signifies the end of the process    
        y_std_ulogic_vector(i) := '1';
      end if;                           
      y_ref := y_ref / 2;
    end loop;
  else
    y_ref := -a_threshold;   -- set the initial threshold for comparison
    y_std_ulogic_vector(y_length-1) := '1';
    for i in y_length-2 downto 0 loop   -- perform algorithmic conversion of negative
      if (y >= y_ref) then
        y_std_ulogic_vector(i) := '1';
      else
        y := y - y_ref;                 -- y = -1 at the end of the process     
        y_std_ulogic_vector(i) := '0';
      end if; 
      y_ref := y_ref / 2;
    end loop;  
  end if;
  return y_std_ulogic_vector;
end to_std_ulogic_vector; 

-- 2's complement -> std_ulogic_vector  
function to_std_ulogic_vector (
  a: twos_complement
) return std_ulogic_vector is
  variable y: std_ulogic_vector(a'length-1 downto 0);
begin
  for i in a'length-1 downto 0 loop
    y(i) := a(i);
  end loop;
  return y;
end to_std_ulogic_vector;

-- integer -> 2's complement
function to_twos_complement (
  a: integer
) return twos_complement is
  constant y_length: integer := integer_wordlength (a);
  constant a_threshold: integer := next_greater_binary_power_minus_1 (a);
  variable y_ref: integer;
  variable y: integer;
  variable y_2sC: twos_complement(y_length-1 downto 0);
begin
  y := a;                               -- y is a temp variable for conversion
  if (a >= 0) then                     
    y_ref := (a_threshold / 2) + 1;    -- set the initial threshold for comparison
    y_2sC(y_length-1) := '0';
    for i in y_length-2 downto 0 loop   -- perform algorithmic conversion of positive
      if (y < y_ref) then
        y_2sC(i) := '0';
      else
        y := y - y_ref;                 -- y = 0 signifies the end of the process    
        y_2sC(i) := '1';
      end if;                           
      y_ref := y_ref / 2;
    end loop;
  else
    y_ref := -(a_threshold / 2) - 1;   -- set the initial threshold for comparison
    y_2sC(y_length-1) := '1';
    for i in y_length-2 downto 0 loop   -- perform algorithmic conversion of negative
      if (y >= y_ref) then
        y_2sC(i) := '1';
      else
        y := y - y_ref;                 -- y = -1 at the end of the process     
        y_2sC(i) := '0';
      end if; 
      y_ref := y_ref / 2;
    end loop;
  end if;
  return y_2sC;
end to_twos_complement;

-- std_ulogic_vector -> 2's complement
function to_twos_complement (
  a: std_ulogic_vector
) return twos_complement is
  variable y: twos_complement(a'length-1 downto 0);
begin
  for i in a'length-1 downto 0 loop
    y(i) := a(i);
  end loop;
  return y;
end to_twos_complement;

end generic_conversions;
