-- File:     spi_xmit_shift_reg.vhd
--

    


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity spi_xmit_shift_reg is
    port(

    
         data_ld      : in STD_LOGIC;    -- Data load enable
         data_in      : in STD_LOGIC_VECTOR (7 downto 0); -- Data to load in
         shift_in     : in STD_LOGIC;    -- Serial data in
         shift_en     : in STD_LOGIC;    -- Shift enable
         
         mosi     : out STD_LOGIC;   -- Shift serial data out
         
         ss_in_int    : in STD_LOGIC;   -- another master is on bus
         
         reset        : in STD_LOGIC;       -- reset
         sclk         : in STD_LOGIC;       -- clock
         sys_clk      : in STD_LOGIC    -- system clock
        
         );
        
end spi_xmit_shift_reg;




architecture DEFINITION of spi_xmit_shift_reg is

--******************************** Constants ***********************
constant RESET_ACTIVE : std_logic := '0';

--******************************** Signals ***********************
signal data_int     : STD_LOGIC_VECTOR (7 downto 0);
signal mosi_int     : STD_LOGIC;


begin

--******************************** SPI Xmit Shift Register ***********************
-- This shift register is clocked on SCK_1
xmit_shift_reg:  process(sclk, reset, ss_in_int)
     begin
          
          -- Clear output register
          if (reset = RESET_ACTIVE or ss_in_int = '0') then
           data_int <= (others => '0');
           
      -- On rising edge of spi clock, shift data
      elsif sclk'event and sclk = '1' then

           -- Load data
           if (data_ld = '1') then
            data_int <= data_in;

           -- If shift enable is high
           elsif shift_en = '1' then

            -- Shift the data
            data_int <= data_int(6 downto 0) & shift_in;

           end if;

      end if;

     end process;

--******************************** MOSI Output Register ***********************  
-- This output register is clocked on the system clock and aligns the data from the
-- shift register with the outgoing SCK
outreg: process (sys_clk, reset)
begin
    if reset = RESET_ACTIVE then
        mosi_int <= '0';
    elsif sys_clk'event and sys_clk = '1' then
    
        mosi_int <= data_int(7); 
    end if;
end process;

-- The MOSI output is 3-stated if the SS_IN_INT signal is asserted indicating that another
-- master is on the bus
mosi <= mosi_int when ss_in_int = '1' 
    else    'Z';

end DEFINITION;
  
