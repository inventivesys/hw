   --------------------------------------------------------------------------------
   -- Entity declaration of 'SHIFT8'.
   -- Last modified : Wed Feb 19 12:02:24 2003.
   --------------------------------------------------------------------------------
 
 
   library ieee ;
   use ieee.std_logic_1164.all ;
   use ieee.std_logic_arith.all ;
 
   entity SHIFT8 is
     port(
       clk       : in     STD_LOGIC ;
       clr       : in     STD_LOGIC ;
       data_in   : in     STD_LOGIC_VECTOR(7 downto 0) ;
       data_ld   : in     STD_LOGIC ;
       data_out  : out    STD_LOGIC_VECTOR(7 downto 0) ;
       shift_en  : in     STD_LOGIC ;
       shift_in  : in     STD_LOGIC ;
       shift_out : out    STD_LOGIC ) ;
   end entity SHIFT8 ;
 
   --------------------------------------------------------------------------------
   -- Architecture 'behaviour' of 'SHIFT8'
   -- Last modified : Wed Feb 19 12:02:24 2003.
   --------------------------------------------------------------------------------
 
   architecture behaviour of SHIFT8 is
 
   constant RESET_ACTIVE : std_logic := '0';
 
   signal data_int : STD_LOGIC_VECTOR (7 downto 0);
 
   begin
 
       process(clk, clr)
       begin
 
           -- Clear output register
           if (clr =   RESET_ACTIVE) then
               data_int    <= (others => '0');
           -- On   rising edge of clock, shift in data
           elsif   clk'event and clk = '1' then
               -- Load data
               if (data_ld = '1') then
                   data_int <= data_in;
               -- If shift enable is high
               elsif shift_en =    '1' then
                   -- Shift the data
                   data_int <= data_int(6 downto 0) & shift_in;
               end if;
           end if;
       end process;
 
       shift_out <= data_int(7);
       data_out <= data_int;
 
   end architecture behaviour ; -- of SHIFT8
 
 
