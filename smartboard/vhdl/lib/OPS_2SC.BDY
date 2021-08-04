-- +---------------------------+
-- |   Copyright 1996 DOULOS   |
-- |      Generic Library      |
-- |    opened: 25 Nov 1995    |
-- +---------------------------+

-- Synthesis script: read -f vhdl ops_2sC.bdy

library ieee;
library vfp;

package body twos_complement_operators is
  use ieee.std_logic_1164.all;
  use vfp.twos_complement_types.all;
  use vfp.generic_functions.all;
  use vfp.generic_conversions.all;
  use vfp.std_operators.all;
  
function "not" (                      -- 25.11.95
  a: twos_complement 
) return twos_complement is
  variable yi: twos_complement(a'length-1 downto 0);
begin
  for i in 0 to a'length-1 loop
    yi(i) := not (a(i));
  end loop;
  return yi;
end "not";
    
function "and" (                      -- 24.11.95
  a, b: twos_complement 
) return twos_complement is
  variable y: twos_complement(a'length-1 downto 0);
begin
  if (a'length /= b'length) then
    assert false
      report "Error 0000." & 
             "Library = vfp." & 
             "Package Body = twos_complement_operators." & 
             "Function = and." & 
             "The wordlength of a and b MUST be the same."
      severity error;
  else
    for i in 0 to a'length-1 loop
      y(i) := a(i) and b(i);
    end loop;
  end if;
  return y;
end "and";
    
function "or" (                           -- 25.11.95
  a, b: twos_complement 
) return twos_complement is
  variable y: twos_complement(a'length-1 downto 0);
begin
  if (a'length /= b'length) then
    assert false
      report "Error 0001." & 
             "Library = vfp." & 
             "Package Body = twos_complement_operators." & 
             "Function = or." & 
             "The wordlength of a and b MUST be the same."
      severity error;
  else
    for i in 0 to a'length-1 loop
      y(i) := a(i) or b(i);
    end loop;
  end if;
  return y;
end "or";
    
function "xor" (                           -- 25.11.95
  a, b: twos_complement 
) return twos_complement is
  variable y: twos_complement(a'length-1 downto 0);
begin
  if (a'length /= b'length) then
    assert false
      report "Error 0001." & 
             "Library = vfp." & 
             "Package Body = twos_complement_operators." & 
             "Function = xor." & 
             "The wordlength of a and b MUST be the same."
      severity error;
  else
    for i in 0 to a'length-1 loop
      y(i) := a(i) xor b(i);
    end loop;
  end if;
  return y;
end "xor";

function "nand" (                           -- 25.11.95
  a, b: twos_complement 
) return twos_complement is
  variable y: twos_complement(a'length-1 downto 0);
begin
  if (a'length /= b'length) then
    assert false
      report "Error 0001." & 
             "Library = vfp." & 
             "Package Body = twos_complement_operators." & 
             "Function = nand." & 
             "The wordlength of a and b MUST be the same."
      severity error;
  else
    for i in 0 to a'length-1 loop
      y(i) := a(i) nand b(i);
    end loop;
  end if;
  return y;
end "nand";

function "nor" (                           -- 25.11.95
  a, b: twos_complement 
) return twos_complement is
  variable y: twos_complement(a'length-1 downto 0);
begin
  if (a'length /= b'length) then
    assert false
      report "Error 0001." & 
             "Library = vfp." & 
             "Package Body = twos_complement_operators." & 
             "Function = nor." & 
             "The wordlength of a and b MUST be the same."
      severity error;
  else
    for i in 0 to a'length-1 loop
      y(i) := a(i) nor b(i);
    end loop;
  end if;
  return y;
end "nor";

-- function "xnor" (                           -- 25.11.95
--   a, b: twos_complement 
-- ) return twos_complement is
--   variable y: twos_complement(a'length-1 downto 0);
-- begin
--   if (a'length /= b'length) then
--     assert false
--       report "Error 0001." & 
--              "Library = vfp." & 
--              "Package Body = twos_complement_operators." & 
--              "Function = xnor." & 
--              "The wordlength of a and b MUST be the same."
--       severity error;
--   else
--     for i in 0 to a'length-1 loop
--       y(i) := a(i) xnor b(i);
--     end loop;
--   end if;
--   return y;
-- end "xnor";
 
function "+" (                      -- 25.11.95
  a, b: twos_complement 
) return twos_complement is
  constant y_length: integer := longest (a, b);
  variable a_sign_extended, b_sign_extended: twos_complement(y_length-1 downto 0);
  variable y: twos_complement(y_length-1 downto 0);
  variable carry: std_ulogic;
begin
  carry := '0';
  if (a'length < b'length) then
    for i in b'length-1 downto a'length loop
      a_sign_extended(i) := a(a'length-1);
    end loop;
    a_sign_extended(a'length-1 downto 0) := a;
    for i in 0 to b'length-1 loop
      y(i) := a_sign_extended(i) xor b(i) xor carry;
      carry := (a_sign_extended(i) and b(i)) or
               (a_sign_extended(i) and carry) or
               (b(i) and carry);
    end loop;
  elsif (a'length > b'length) then
    for i in a'length-1 downto b'length loop
      b_sign_extended(i) := b(b'length-1);
    end loop;
    b_sign_extended(b'length-1 downto 0) := b;
    for i in 0 to a'length-1 loop
      y(i) := a(i) xor b_sign_extended(i) xor carry;
      carry := (a(i) and b_sign_extended(i)) or
               (a(i) and carry) or
               (b_sign_extended(i) and carry);
    end loop;
  else                            -- i.e., (a'length = b'length)
    for i in 0 to a'length-1 loop
      y(i) := a(i) xor b(i) xor carry;
      carry := (a(i) and b(i)) or
               (a(i) and carry) or
               (b(i) and carry);
    end loop;
  end if;
  return y;
end "+";

function "-" (                      -- 29.11.95
  a, b: twos_complement 
) return twos_complement is
  constant y_length: integer := longest (a, b);
  variable a_sign_extended, b_sign_extended: twos_complement(y_length-1 downto 0);
  variable y: twos_complement(y_length-1 downto 0);
  variable carry: std_ulogic;
begin
  carry := '1';
  if (a'length < b'length) then
    for i in b'length-1 downto a'length loop
      a_sign_extended(i) := a(a'length-1);
    end loop;
    a_sign_extended(a'length-1 downto 0) := a;
    for i in 0 to b'length-1 loop
      y(i) := a_sign_extended(i) xor (not b(i)) xor carry;
      carry := (a_sign_extended(i) and (not b(i))) or
               (a_sign_extended(i) and carry) or
               (not (b(i)) and carry);
    end loop;
  elsif (a'length > b'length) then
    for i in a'length-1 downto b'length loop
      b_sign_extended(i) := b(b'length-1);
    end loop;
    b_sign_extended(b'length-1 downto 0) := b;
    for i in 0 to a'length-1 loop
      y(i) := a(i) xor (not b_sign_extended(i)) xor carry;
      carry := (a(i) and (not b_sign_extended(i))) or
               (a(i) and carry) or
               ((not b_sign_extended(i)) and carry);
    end loop;
  else                            -- i.e., (a'length = b'length)
    for i in 0 to a'length-1 loop
      y(i) := a(i) xor (not b(i)) xor carry;
      carry := (a(i) and (not b(i))) or
               (a(i) and carry) or
               ((not b(i)) and carry);
    end loop;
  end if;
  return y;
end "-";
  
function "*" (                      -- 30.11.95
  a, b: twos_complement 
) return twos_complement is
  constant y_length: integer := a'length + b'length;
  variable y_sign: std_ulogic;
--  variable a_1sC, multiplicand: twos_complement(a'length-1 downto 0);
--  variable b_1sC, multiplier: twos_complement(b'length-1 downto 0);
  variable a_1sC, multiplicand: std_ulogic_vector(a'length-1 downto 0);
  variable b_1sC, multiplier: std_ulogic_vector(b'length-1 downto 0);
  variable carry: std_ulogic; 
--  variable partial_product: twos_complement(a'length-1 downto 0);
  variable partial_product: std_ulogic_vector(a'length-1 downto 0);
  variable product_lsb: twos_complement(b'length-1 downto 0);
  variable product: twos_complement(y_length-1 downto 0);
  variable y_1sC: twos_complement(y_length-1 downto 0);
  variable y: twos_complement(y_length-1 downto 0);
begin
-- firstly, the sign of the result is extracted               --   BB x 02
  y_sign := a(a'length-1) xor b(b'length-1);                  --    1
-- second, the operands are converted to absolute values      --
  if (a(a'length-1) = '1') then                               --
    a_1sC := to_std_ulogic_vector (not a);                                           --    44
    carry := '1';                                             --
    for i in 0 to a'length-1 loop                             --  0 1 2 3 4 5 6 7
      multiplicand(i) := a_1sC(i) xor carry;                  --  1 0 1 0 0 0 1 0
      carry := a_1sC(i) and carry;                            --  0 0 0 0 0 0 0 0
    end loop;                                                 --    45 
  else                                                        --
    multiplicand := to_std_ulogic_vector (a);                                        --
  end if;                                                     --
  if (b(b'length-1) = '1') then                               --
    b_1sC := to_std_ulogic_vector (not b);                                           --
    carry := '1';                                             --
    for i in 0 to b'length-1 loop                             --
      multiplier(i) := b_1sC(i) xor carry;                    --
      carry := b_1sC(i) and carry;                            --
    end loop;                                                 --
  else                                                        --
    multiplier := to_std_ulogic_vector (b);                                          --    02
  end if;                                                     --
-- thirdly, the multiplication of the absolute values takes place
  for i in 0 to (multiplicand'length - 1) loop                --
    partial_product(i) := '0';                                --    00
  end loop;                                                   --
  for i in 0 to multiplier'length-1 loop                      --                  0 1 2 3 4 5 6 7
    if (multiplier(i) = '1') then                             --
--      partial_product := partial_product(a'length-1 downto 1) + multiplicand;  -- 
      partial_product := partial_product + multiplicand;  -- 
      product_lsb(i) := partial_product(0);                          --
      partial_product := '0' & partial_product(a'length-1 downto 1);  -- 
    else                                                             --
      product_lsb(i) := partial_product(0);                          --           0
      partial_product := '0' & partial_product(a'length-1 downto 1); --           0
    end if;                                                          --         pp = 00
  end loop;                                                           --        lsb = 8A
-- now the result's absolute value is converted to it's 2's complement value
  product := to_twos_complement (partial_product) & product_lsb;                       --
  if (y_sign = '1') then                                          --
    y_1sC := not product;                                         --   FF75
    carry := '1';                                                 --
    for i in 0 to y_1sC'length-1 loop                             --
      y(i) := y_1sC(i) xor carry;                                 --
      carry := y_1sC(i) and carry;                                --
    end loop;                                                     --   FF76
  else                                                            --
    y := product;                                                 --
  end if;                                                         --
  return y;                                                       --
end "*";

function "/" (                      -- 29.11.95
  a, b: twos_complement 
) return twos_complement is
  constant y_length: integer := a'length + b'length; 
  constant a_extended_length: integer := b'length-1;
  variable y_sign: std_ulogic;
  variable a_1sC, a_abs: twos_complement(a'length-1 downto 0);
  variable b_1sC, b_abs: twos_complement(b'length-1 downto 0);
  variable carry: std_ulogic; 
  variable a_extended: twos_complement(a_extended_length-1 downto 0);
  variable dividend_match: twos_complement(b'length-1 downto 0);
  variable quotient: twos_complement(a'length-1 downto 0);
  variable remainder: twos_complement(b'length-1 downto 0);
  variable quotient_abs, quotient_1sC: twos_complement(a'length-1 downto 0);
  variable remainder_abs, remainder_1sC: twos_complement(b'length-1 downto 0);
  variable y: twos_complement(y_length-1 downto 0);
begin
-- firstly, the sign of the result is extracted
  y_sign := a(a'length-1) xor b(b'length-1);
-- second, the operands are converted to absolute values
  if (a(a'length-1) = '1') then
    a_1sC := not a;
    carry := '1';
    for i in 0 to a'length-1 loop
      a_abs(i) := a_1sC(i) xor carry;
      carry := a_1sC(i) and carry;
    end loop;
  else
    a_abs := a;
  end if;
  if (b(b'length-1) = '1') then
    b_1sC := not b;
    carry := '1';
    for i in 0 to b'length-1 loop
      b_abs(i) := b_1sC(i) xor carry;
      carry := b_1sC(i) and carry;
    end loop;
  else
    b_abs := b;
  end if;
-- thirdly, the division of the absolute values takes place
  for i in a_extended_length-1 downto 0 loop
    a_extended(i) := '0';
  end loop;
  dividend_match(b_abs'length-1 downto 1) := a_extended;
  for i in a_abs'length-1 downto 0 loop
    dividend_match := dividend_match(b_abs'length-1 downto 1) & a_abs(i);
    if (b_abs <= dividend_match) then
      dividend_match := dividend_match - b_abs;
      quotient_abs(i) := '1';
    else
      quotient_abs(i) := '0';
    end if;
  end loop; 
  remainder_abs := dividend_match;
-- now the result's absolute value is converted to it's 2's complement value
-- note that the sign of the remainder follows the sign of the dividend
  if (y_sign = '1') then
    quotient_1sC := not quotient_abs;
    carry := '1';
    for i in 0 to quotient_1sC'length-1 loop
      quotient(i) := quotient_1sC(i) xor carry;
      carry := quotient_1sC(i) and carry;
    end loop;
  else
    quotient := quotient_abs;
  end if;    
  if (a(a'length-1) = '1') then
    remainder_1sC := not remainder_abs;
    carry := '1';
    for i in 0 to remainder_1sC'length-1 loop
      remainder(i) := remainder_1sC(i) xor carry;
      carry := remainder_1sC(i) and carry;
    end loop;
  else
    remainder := remainder_abs;
  end if;    
  y := quotient & remainder;
  return y;
end "/";
    
function "mod" (                      -- 2.12.95
  a, b: twos_complement 
) return twos_complement is
  constant y_length: integer := a'length + b'length; 
  constant a_extended_length: integer := b'length-1;
  variable a_1sC, a_abs: twos_complement(a'length-1 downto 0);
  variable b_1sC, b_abs: twos_complement(b'length-1 downto 0);
  variable carry: std_ulogic; 
  variable a_extended: twos_complement(a_extended_length-1 downto 0);
  variable dividend_match: twos_complement(b'length-1 downto 0);
  variable remainder: twos_complement(b'length-1 downto 0);
  variable remainder_abs, remainder_1sC: twos_complement(b'length-1 downto 0);
  variable y: twos_complement(b'length-1 downto 0);
begin
-- firstly, the operands are converted to absolute values
  if (a(a'length-1) = '1') then
    a_1sC := not a;
    carry := '1';
    for i in 0 to a'length-1 loop
      a_abs(i) := a_1sC(i) xor carry;
      carry := a_1sC(i) and carry;
    end loop;
  else
    a_abs := a;
  end if;
  if (b(b'length-1) = '1') then
    b_1sC := not b;
    carry := '1';
    for i in 0 to b'length-1 loop
      b_abs(i) := b_1sC(i) xor carry;
      carry := b_1sC(i) and carry;
    end loop;
  else
    b_abs := b;
  end if;
-- secondly, the division of the absolute values takes place
  for i in a_extended_length-1 downto 0 loop
    a_extended(i) := '0';
  end loop;
  dividend_match(b_abs'length-1 downto 1) := a_extended;
  for i in a_abs'length-1 downto 0 loop
    dividend_match := dividend_match(b_abs'length-1 downto 1) & a_abs(i);
    if (b_abs <= dividend_match) then
      dividend_match := dividend_match - b_abs;
    end if;
  end loop; 
  remainder_abs := dividend_match;
-- now the result's absolute value is converted to it's 2's complement value
-- note that the sign of the remainder follows the sign of the dividend
  if (a(a'length-1) = '1') then
    remainder_1sC := not remainder_abs;
    carry := '1';
    for i in 0 to remainder_1sC'length-1 loop
      remainder(i) := remainder_1sC(i) xor carry;
      carry := remainder_1sC(i) and carry;
    end loop;
  else
    remainder := remainder_abs;
  end if;    
  y := remainder;
  return y;
end "mod";
    
function "rem" (                      -- 2.12.95
  a, b: twos_complement 
) return twos_complement is
  constant y_length: integer := a'length + b'length; 
  constant a_extended_length: integer := b'length-1;
  variable a_1sC, a_abs: twos_complement(a'length-1 downto 0);
  variable b_1sC, b_abs: twos_complement(b'length-1 downto 0);
  variable carry: std_ulogic; 
  variable a_extended: twos_complement(a_extended_length-1 downto 0);
  variable dividend_match: twos_complement(b'length-1 downto 0);
  variable remainder: twos_complement(b'length-1 downto 0);
  variable remainder_abs, remainder_1sC: twos_complement(b'length-1 downto 0);
  variable y: twos_complement(b'length-1 downto 0);
begin
-- firstly, the operands are converted to absolute values
  if (a(a'length-1) = '1') then
    a_1sC := not a;
    carry := '1';
    for i in 0 to a'length-1 loop
      a_abs(i) := a_1sC(i) xor carry;
      carry := a_1sC(i) and carry;
    end loop;
  else
    a_abs := a;
  end if;
  if (b(b'length-1) = '1') then
    b_1sC := not b;
    carry := '1';
    for i in 0 to b'length-1 loop
      b_abs(i) := b_1sC(i) xor carry;      
      carry := b_1sC(i) and carry;
    end loop;
  else
    b_abs := b;
  end if;
-- secondly, the division of the absolute values takes place
  for i in a_extended_length-1 downto 0 loop
    a_extended(i) := '0';
  end loop;
  dividend_match(b_abs'length-1 downto 1) := a_extended;
  for i in a_abs'length-1 downto 0 loop
    dividend_match := dividend_match(b_abs'length-1 downto 1) & a_abs(i);
    if (b_abs <= dividend_match) then
      dividend_match := dividend_match - b_abs;
    end if;
  end loop; 
  remainder_abs := dividend_match;
-- now the result's absolute value is converted to it's 2's complement value
-- note that the sign of the remainder follows the sign of the dividend
  if (a(a'length-1) = '1') then
    remainder_1sC := not remainder_abs;
    carry := '1';
    for i in 0 to remainder_1sC'length-1 loop
      remainder(i) := remainder_1sC(i) xor carry;
      carry := remainder_1sC(i) and carry;
    end loop;
  else
    remainder := remainder_abs;
  end if;    
  y := remainder;
  return y;
end "rem";        

function "**" (                      -- 2.12.95
  a, b: twos_complement 
) return twos_complement is
  variable y: twos_complement(a'length-1 downto 0);
begin
  assert false
    report "Error 0001." &                                
           "Library = vfp." &                             
           "Package Body = twos_complement_operators." &   
           "Function = **." &                              
           "The function (twos_complement) ** (twos_complement) is not supported." &
           "However, to_twos_complement(to_integer(twos_complementy) ** to_integer(twos_complement)) is supported."                              
-- See the to_integer and the to_twos_complement conversion functions
    severity error;
  y := a;
  return y;
end "**";

function "abs" (                      -- 2.12.95
  a: twos_complement 
) return twos_complement is
-- the function abs_wordlength returns a'length+1 if a is
-- -2(N-1) otherwise it returns a'length
  constant y_length: integer := abs_wordlength(a); 
  variable a_1sC: twos_complement(a'length-1 downto 0);
  variable carry: std_ulogic;
  variable y: twos_complement(y_length-1 downto 0);
begin
  if (y_length = a'length+1) then
    y(a'length) := '1';
  end if;
  if (a(a'length-1) = '1') then
    a_1sC := not a;
    carry := '1';
    for i in 0 to a'length-1 loop
      y(i) := a_1sC(i) xor carry;
      carry := a_1sC(i) and carry;
    end loop;
  else
    y := a;
  end if;
  return y;
end "abs";

function "+" (                      -- 2.12.95
  a: twos_complement 
) return twos_complement is
  variable y: twos_complement(a'length-1 downto 0);
begin
  assert false
    report "Warning 0001." &                                
           "Library = vfp." &                             
           "Package Body = twos_complement_operators." &   
           "Function = +." &                              
           "The function + (twos_complement) is defined as ... " &
           "    <return_value> := <actual_parameter>    " &
           "Thus there is no point in taking the positive value of a twos_complement object."                              
    severity warning;
  y := a;
  return y;
end "+";

function "-" (                      -- 2.12.95
  a: twos_complement 
) return twos_complement is
-- the function abs_wordlength returns a'length+1 if a is
-- -2(N-1) otherwise it returns a'length
  constant y_length: integer := abs_wordlength(a); 
  variable a_1sC: twos_complement(a'length-1 downto 0);
  variable carry: std_ulogic;
  variable y: twos_complement(y_length-1 downto 0);
begin
  if (y_length = a'length+1) then
    y(a'length) := '0';
  end if;
  a_1sC := not a;
  carry := '1';
  for i in 0 to a'length-1 loop
    y(i) := a_1sC(i) xor carry;
    carry := a_1sC(i) and carry;
  end loop;
  return y;
end "-";

-- an alternative body
-- take the 2s complement vectors & convert them to 
-- integers. Then add the integers.

end twos_complement_operators;


