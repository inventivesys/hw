
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity upcnt is
    port(
          
         cnt_en       : in STD_LOGIC;                        -- Count enable                       -- Load line enable
         clr          : in STD_LOGIC;                        -- Active low clear
         clk          : in STD_LOGIC;                        -- Clock
         qout         : inout STD_LOGIC_VECTOR (3 downto 0)
        
         );
        
end upcnt;



architecture DEFINITION of upcnt is

constant RESET_ACTIVE : std_logic := '0';

signal q_int : UNSIGNED (3 downto 0);

begin

     process(clk, clr)
     begin
          
          -- Clear output register
          if (clr = RESET_ACTIVE) then
           q_int <= (others => '0');
           
      -- On falling edge of clock count
      elsif (clk'event) and clk = '1' then
           if cnt_en = '1' then
                q_int <= q_int + 1;
           end if;
      end if;

     end process;

     qout <= STD_LOGIC_VECTOR(q_int);

end DEFINITION;
  

