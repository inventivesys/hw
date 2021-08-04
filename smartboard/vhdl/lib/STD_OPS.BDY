-- +---------------------------+
-- |   Copyright 1996 DOULOS   |
-- |      Generic Library      |
-- |    opened: 17 Nov 1995    |
-- +---------------------------+

-- Synthesis script: read -f vhdl mvl_ops.bdy

library ieee;
library vfp;

package body std_operators is
  use ieee.std_logic_1164.all;
	use vfp.generic_functions.all;
  
-- type logical_map is array (mvl) of mvl;
-- type truth_table is array (mvl, mvl) of mvl;
-- 
-- constant not_a : logical_map :=                  -- 22.11.95
-- -------------------------------------------
--  U    X    0    1    Z    W    L    H    -   
-- -------------------------------------------
--   ('u', 'x', '1', '0', 'x', 'x', '1', '0', 'x');
--    
-- constant and_a_b : truth_table := (              -- 22.11.95
-- -------------------------------------------    
--  U    X    0    1    Z    W    L    H    -            
-- -------------------------------------------    
--   ('u', 'u', '0', 'u', 'u', 'u', '0', 'u', 'u'), -- | U |
--   ('u', 'x', '0', 'x', 'x', 'x', '0', 'x', 'x'), -- | X |
--   ('0', '0', '0', '0', '0', '0', '0', '0', '0'), -- | 0 |
--   ('u', 'x', '0', '1', 'x', 'x', '0', '1', 'x'), -- | 1 |
--   ('u', 'x', '0', 'x', 'x', 'x', '0', 'x', 'x'), -- | Z |
--   ('u', 'x', '0', 'x', 'x', 'x', '0', 'x', 'x'), -- | W |
--   ('0', '0', '0', '0', '0', '0', '0', '0', '0'), -- | L |
--   ('u', 'x', '0', '1', 'x', 'x', '0', '1', 'x'), -- | H |
--   ('u', 'x', '0', 'x', 'x', 'x', '0', 'x', 'x')  -- | - |
-- );
-- 
-- constant or_a_b : truth_table := (               -- 22.11.95
-- -------------------------------------------    
--  U    X    0    1    Z    W    L    H    -            
-- -------------------------------------------    
--   ('u', 'u', 'u', '1', 'u', 'u', 'u', '1', 'u'), -- | U |
--   ('u', 'x', 'x', '1', 'x', 'x', 'x', '1', 'x'), -- | X |
--   ('u', 'x', '0', '1', 'x', 'x', '0', '1', 'x'), -- | 0 |
--   ('1', '1', '1', '1', '1', '1', '1', '1', '1'), -- | 1 |
--   ('u', 'x', 'x', '1', 'x', 'x', 'x', '1', 'x'), -- | Z |
--   ('u', 'x', 'x', '1', 'x', 'x', 'x', '1', 'x'), -- | W |
--   ('u', 'x', '0', '1', 'x', 'x', '0', '1', 'x'), -- | L |
--   ('1', '1', '1', '1', '1', '1', '1', '1', '1'), -- | H |
--   ('u', 'x', 'x', '1', 'x', 'x', 'x', '1', 'x')  -- | - |
-- );
-- 
-- constant xor_a_b : truth_table := (              -- 22.11.95
-- -------------------------------------------    
--  U    X    0    1    Z    W    L    H    -            
-- -------------------------------------------    
--   ('u', 'u', 'u', 'u', 'u', 'u', 'u', 'u', 'u'), -- | U |
--   ('u', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'), -- | X |
--   ('u', 'x', '0', '1', 'x', 'x', '0', '1', 'x'), -- | 0 |
--   ('u', 'x', '1', '0', 'x', 'x', '1', '0', 'x'), -- | 1 |
--   ('u', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'), -- | Z |
--   ('u', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'), -- | W |
--   ('u', 'x', '0', '1', 'x', 'x', '0', '1', 'x'), -- | L |
--   ('u', 'x', '1', '0', 'x', 'x', '1', '0', 'x'), -- | H |
--   ('u', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x')  -- | - |
-- );
-- 
-- -- function "not" (      -- 24.11.95
--   a: mvl
-- ) return mvl is
-- begin  
--   return (not_a (a)); 
-- end "not";
-- 
-- function "and" (      -- 24.11.95
--   a, b: mvl
-- ) return mvl is
-- begin  
--   return (and_a_b (a, b)); 
-- end "and";
-- 
-- function "or" (       -- 24.11.95
--   a, b: mvl
-- ) return mvl is
-- begin  
--   return (or_a_b (a, b)); 
-- end "or";
-- 
-- function "xor" (       -- 24.11.95
--   a, b: mvl
-- ) return mvl is
-- begin  
--   return (xor_a_b (a, b)); 
-- end "xor";
-- 
-- function "nand" (      -- 24.11.95
--   a, b: mvl
-- ) return mvl is
-- begin  
--   return not (a and b); 
-- end "nand";
-- 
-- function "nor" (       -- 24.11.95
--   a, b: mvl
-- ) return mvl is
-- begin  
--   return not (a or b); 
-- end "nor";
-- 
-- --function "xnor" (       -- 24.11.95
-- --  a, b: mvl
-- --) return mvl is
-- --begin  
-- --  return not (a xor b); 
-- --end "xnor";
-- 
-- function "not" (                      -- 25.11.95
--   a: mvl_vector 
-- ) return mvl_vector is
--   variable yi: mvl_vector(a'length-1 downto 0);
-- begin
--   for i in 0 to a'length-1 loop
--     yi(i) := not a(i);
--   end loop;
--   return yi;
-- end "not";
--     
-- function "and" (                      -- 24.11.95
--   a, b: mvl_vector 
-- ) return mvl_vector is
--   variable y: mvl_vector(a'length-1 downto 0);
-- begin
--   if (a'length /= b'length) then
--     assert false
--       report "Error 0000." & 
--              "Library = vfp." & 
--              "Package Body = mvl_operators." & 
--              "Function = and." & 
--              "The wordlength of a and b MUST be the same."
--       severity error;
--   else
--     for i in 0 to a'length-1 loop
--       y(i) := a(i) and b(i);
--     end loop;
--   end if;
--   return y;
-- end "and";
--     
-- function "or" (                           -- 25.11.95
--   a, b: mvl_vector 
-- ) return mvl_vector is
--   variable y: mvl_vector(a'length-1 downto 0);
-- begin
--   if (a'length /= b'length) then
--     assert false
--       report "Error 0001." & 
--              "Library = vfp." & 
--              "Package Body = mvl_operators." & 
--              "Function = or." & 
--              "The wordlength of a and b MUST be the same."
--       severity error;
--   else
--     for i in 0 to a'length-1 loop
--       y(i) := a(i) or b(i);
--     end loop;
--   end if;
--   return y;
-- end "or";
--     
-- function "xor" (                          -- 25.11.95
--   a, b: mvl_vector 
-- ) return mvl_vector is
--   variable y: mvl_vector(a'length-1 downto 0);
-- begin
--   if (a'length /= b'length) then
--     assert false
--       report "Error 0002." & 
--              "Library = vfp." & 
--              "Package Body = mvl_operators." & 
--              "Function = xor." & 
--              "The wordlength of a and b MUST be the same."
--       severity error;
--   else
--     for i in 0 to a'length-1 loop
--       y(i) := a(i) xor b(i);
--     end loop;
--   end if;
--   return y;
-- end "xor";
--     
-- function "nand" (                       -- 25.11.95
--   a, b: mvl_vector 
-- ) return mvl_vector is
--   variable yi: mvl_vector(a'length-1 downto 0);
-- begin
--   if (a'length /= b'length) then
--     assert false
--       report "Error 0003." & 
--              "Library = vfp." & 
--              "Package Body = mvl_operators." & 
--              "Function = nand." & 
--              "The wordlength of a and b MUST be the same."
--       severity error;
--   else
--     for i in 0 to a'length-1 loop
--       yi(i) := not (a(i) and b(i));
--     end loop;
--   end if;
--   return yi;
-- end "nand";
--     
-- function "nor" (                     -- 25.11.95
--   a, b: mvl_vector 
-- ) return mvl_vector is
--   variable yi: mvl_vector(a'length-1 downto 0);
-- begin
--   if (a'length /= b'length) then
--     assert false
--       report "Error 0004." & 
--              "Library = vfp." & 
--              "Package Body = mvl_operators." & 
--              "Function = nor." & 
--              "The wordlength of a and b MUST be the same."
--       severity error;
--   else
--     for i in 0 to a'length-1 loop
--       yi(i) := not (a(i) or b(i));
--     end loop;
--   end if;
--   return yi;
-- end "nor";
--     
-- --function "xnor" (                   -- 25.11.95
-- --  a, b: mvl_vector 
-- --) return mvl_vector is
-- --  variable yi: mvl_vector(a'length-1 downto 0);
-- --begin
-- --  if (a'length /= b'length) then
-- --    assert false
-- --      report "Error 0005." & 
-- --             "Library = vfp." & 
-- --             "Package Body = mvl_operators." & 
-- --             "Function = xnor." & 
-- --             "The wordlength of a and b MUST be the same."
-- --      severity error;
-- --  else
-- --    for i in 0 to a'length-1 loop
-- --      yi(i) := not (a(i) xor b(i));
-- --    end loop;
-- --  end if;
-- --  return yi;
-- --end "xnor";
    
function "+" (                      -- 11.03.95
  a, b: std_ulogic_vector 
) return std_ulogic_vector is
  constant y_length: integer := longest (a, b);
  variable a_extended, b_extended: std_ulogic_vector(y_length-1 downto 0);
  variable y: std_ulogic_vector(y_length-1 downto 0);
  variable carry: std_ulogic;
  variable a_add, b_add: std_ulogic_vector(y_length-1 downto 0);
begin
  carry := '0';
  if (a'length < b'length) then
    for i in b'length-1 downto a'length loop
      a_extended(i) := '0';
    end loop;
    a_extended(a'length-1 downto 0) := a;
    b_add := b;
    for i in 0 to b'length-1 loop
      y(i) := a_extended(i) xor b_add(i) xor carry;
      carry := (a_extended(i) and b_add(i)) or
               (a_extended(i) and carry) or
               (b_add(i) and carry);
    end loop;
  elsif (a'length > b'length) then
    for i in a'length-1 downto b'length loop
      b_extended(i) := '0';
    end loop;
    b_extended(b'length-1 downto 0) := b;
    a_add := a;
    for i in 0 to a'length-1 loop
      y(i) := a_add(i) xor b_extended(i) xor carry;
      carry := (a_add(i) and b_extended(i)) or
               (a_add(i) and carry) or
               (b_extended(i) and carry);
    end loop;
  else                            -- i.e., (a'length = b'length)
    a_add := a;
    b_add := b;
    for i in 0 to a'length-1 loop
      y(i) := a_add(i) xor b_add(i) xor carry;
      carry := (a_add(i) and b_add(i)) or
               (a_add(i) and carry) or
               (b_add(i) and carry);
    end loop;
  end if;
  return y;
end "+";
    
function "+" (                      -- 11.03.95
  a, b: std_logic_vector 
) return std_logic_vector is
  constant y_length: integer := longest (a, b);
  variable a_extended, b_extended: std_logic_vector(y_length-1 downto 0);
  variable y: std_logic_vector(y_length-1 downto 0);
  variable carry: std_logic;
  variable a_add, b_add: std_logic_vector(y_length-1 downto 0);
begin
  carry := '0';
  if (a'length < b'length) then
    for i in b'length-1 downto a'length loop
      a_extended(i) := '0';
    end loop;
    a_extended(a'length-1 downto 0) := a;
    b_add := b;
    for i in 0 to b'length-1 loop
      y(i) := a_extended(i) xor b_add(i) xor carry;
      carry := (a_extended(i) and b_add(i)) or
               (a_extended(i) and carry) or
               (b_add(i) and carry);
    end loop;
  elsif (a'length > b'length) then
    for i in a'length-1 downto b'length loop
      b_extended(i) := '0';
    end loop;
    b_extended(b'length-1 downto 0) := b;
    a_add := a;
    for i in 0 to a'length-1 loop
      y(i) := a_add(i) xor b_extended(i) xor carry;
      carry := (a_add(i) and b_extended(i)) or
               (a_add(i) and carry) or
               (b_extended(i) and carry);
    end loop;
  else                            -- i.e., (a'length = b'length)
    a_add := a;
    b_add := b;
    for i in 0 to a'length-1 loop
      y(i) := a_add(i) xor b_add(i) xor carry;
      carry := (a_add(i) and b_add(i)) or
               (a_add(i) and carry) or
               (b_add(i) and carry);
    end loop;
  end if;
  return y;
end "+";
    
function "-" (                      -- 29.11.95
  a, b: std_ulogic_vector 
) return std_ulogic_vector is
  constant y_length: integer := longest (a, b);
  variable a_extended, b_extended: std_ulogic_vector(y_length-1 downto 0);
  variable y: std_ulogic_vector(y_length-1 downto 0);
  variable carry: std_ulogic;
begin
  carry := '1';
  if (a'length < b'length) then
    for i in b'length-1 downto a'length loop
      a_extended(i) := '0';
    end loop;
    a_extended(a'length-1 downto 0) := a;
    for i in 0 to b'length-1 loop
      y(i) := a_extended(i) xor (not b(i)) xor carry;
      carry := (a_extended(i) and (not b(i))) or
               (a_extended(i) and carry) or
               ((not b(i)) and carry);
    end loop;
  elsif (a'length > b'length) then
    for i in a'length-1 downto b'length loop
      b_extended(i) := '0';
    end loop;
    b_extended(b'length-1 downto 0) := b;
    for i in 0 to a'length-1 loop
      y(i) := a(i) xor (not b_extended(i)) xor carry;
      carry := (a(i) and (not b_extended(i))) or
               (a(i) and carry) or
               ((not b_extended(i)) and carry);
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
  a, b: std_ulogic_vector 
) return std_ulogic_vector is
  constant y_length: integer := a'length + b'length;
  variable y_sign: std_ulogic;
  variable multiplicand: std_ulogic_vector(a'length-1 downto 0);
  variable multiplier: std_ulogic_vector(b'length-1 downto 0);
  variable partial_product: std_ulogic_vector(a'length-1 downto 0);
  variable product_lsb: std_ulogic_vector(b'length-1 downto 0);
  variable product: std_ulogic_vector(y_length-1 downto 0);
  variable y: std_ulogic_vector(y_length-1 downto 0);
begin
  multiplicand := a;
  multiplier := b;
  for i in 0 to multiplicand'length-1 loop
    partial_product(i) := '0';
  end loop;
  for i in 0 to multiplier'length-1 loop
    if (multiplier(i) = '1') then
      partial_product := partial_product(a'length-1 downto 1) + multiplicand;
      product_lsb(i) := partial_product(0);
    else
      partial_product := '0' & partial_product(a'length-1 downto 1);
      product_lsb(i) := partial_product(0);
    end if;
  end loop;
  product := partial_product & product_lsb;
  y := product;
  return y;
end "*";

function "/" (                      -- 29.11.95
  a, b: std_ulogic_vector 
) return std_ulogic_vector is
  constant y_length: integer := a'length + b'length;
  constant a_extended_length: integer := b'length-1;
  variable a_extended: std_ulogic_vector(a_extended_length-1 downto 0);
  variable dividend_match: std_ulogic_vector(b'length-1 downto 0);
  variable quotient: std_ulogic_vector(a'length-1 downto 0);
  variable remainder: std_ulogic_vector(b'length-1 downto 0);
  variable y: std_ulogic_vector(y_length-1 downto 0);
begin
  for i in a_extended_length-1 downto 0 loop
    a_extended(i) := '0';
  end loop;
  dividend_match(b'length-1 downto 1) := a_extended;
  for i in a'length-1 downto 0 loop
    dividend_match := dividend_match(b'length-1 downto 1) & a(i);
    if (b <= dividend_match) then
      dividend_match := dividend_match - b;
      quotient(i) := '1';
    else
      quotient(i) := '0';
    end if;
  end loop; 
  remainder := dividend_match;    
  y := quotient & remainder;
  return y;
end "/";

function "mod" (                      -- 2.12.95
  a, b: std_ulogic_vector 
) return std_ulogic_vector is
  constant y_length: integer := a'length + b'length;
  constant a_extended_length: integer := b'length-1;
  variable a_extended: std_ulogic_vector(a_extended_length-1 downto 0);
  variable dividend_match: std_ulogic_vector(b'length-1 downto 0);
  variable remainder: std_ulogic_vector(b'length-1 downto 0);
  variable y: std_ulogic_vector(b'length-1 downto 0);
begin
  for i in a_extended_length-1 downto 0 loop
    a_extended(i) := '0';
  end loop;
  dividend_match(b'length-1 downto 1) := a_extended;
  for i in a'length-1 downto 0 loop
    dividend_match := dividend_match(b'length-1 downto 1) & a(i);
    if (b <= dividend_match) then
      dividend_match := dividend_match - b;
    end if;
  end loop; 
  remainder := dividend_match;    
  y := remainder;
  return y;
end "mod";

function "rem" (                      -- 2.12.95
  a, b: std_ulogic_vector 
) return std_ulogic_vector is
  constant y_length: integer := a'length + b'length;
  constant a_extended_length: integer := b'length-1;
  variable a_extended: std_ulogic_vector(a_extended_length-1 downto 0);
  variable dividend_match: std_ulogic_vector(b'length-1 downto 0);
  variable remainder: std_ulogic_vector(b'length-1 downto 0);
  variable y: std_ulogic_vector(b'length-1 downto 0);
begin
  for i in a_extended_length-1 downto 0 loop
    a_extended(i) := '0';
  end loop;
  dividend_match(b'length-1 downto 1) := a_extended;
  for i in a'length-1 downto 0 loop
    dividend_match := dividend_match(b'length-1 downto 1) & a(i);
    if (b <= dividend_match) then
      dividend_match := dividend_match - b;
    end if;
  end loop; 
  remainder := dividend_match;    
  y := remainder;
  return y;
end "rem";

function "abs" (                      -- 2.12.95
  a: std_ulogic_vector 
) return std_ulogic_vector is
  variable y: std_ulogic_vector(a'length-1 downto 0);
begin
  assert false
    report "Warning 0001." &                                
           "Library = vfp." &                             
           "Package Body = std_ulogic_operators." &   
           "Function = abs." &                              
           "The function abs (std_ulogic_vector) is defined as ... " &
           "    <return_value> := <actual_parameter>    " &
           "Thus there is no point in taking the absolute value of an std_ulogic_vector."                              
    severity warning;
  y := a;
  return y;
end "abs";

function "+" (                      -- 2.12.95
  a: std_ulogic_vector 
) return std_ulogic_vector is
  variable y: std_ulogic_vector(a'length-1 downto 0);
begin
  assert false
    report "Warning 0001." &                                
           "Library = vfp." &                             
           "Package Body = std_ulogic_operators." &   
           "Function = +." &                              
           "The function + (std_ulogic_vector) is defined as ... " &
           "    <return_value> := <actual_parameter>    " &
           "Thus there is no point in taking the positive value of an std_ulogic_vector."                              
    severity warning;
  y := a;
  return y;
end "+";

function "-" (                      -- 2.12.95
  a: std_ulogic_vector 
) return std_ulogic_vector is
  variable y: std_ulogic_vector(a'length-1 downto 0);
begin
  assert false
    report "Error 0001." &                                
           "Library = vfp." &                             
           "Package Body = std_ulogic_operators." &   
           "Function = -." &                              
           "The function - (std_ulogic_vector) is not supported." &
           "However, 0 - <std_ulogic_vector_expression> IS supported."                              
-- See the integer - std_ulogic_vector overloaded operator
    severity error;
  y := a;
  return y;
end "-";

function "**" (                      -- 2.12.95
  a, b: std_ulogic_vector 
) return std_ulogic_vector is
  variable y: std_ulogic_vector(a'length-1 downto 0);
begin
  assert false
    report "Error 0001." &                                
           "Library = vfp." &                             
           "Package Body = std_ulogic_operators." &   
           "Function = **." &                              
           "The function (std_ulogic_vector) ** (std_ulogic_vector) is not supported." &
           "However, to_std_ulogic_vector(to_integer(std_ulogic_vector) ** to_integer(std_ulogic_vector)) is supported."                              
-- See the to_integer and the to_std_ulogic_vector conversion functions
    severity error;
  y := a;
  return y;
end "**";
    
end std_operators;

