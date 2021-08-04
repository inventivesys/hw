-- File:     spi_rcv_shift_reg.vhd
--
    


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity spi_rcv_shift_reg is
    port(

         -- shift control and data
         miso     : in STD_LOGIC;    -- Serial data in
         shift_en     : in STD_LOGIC;    -- Active low shift enable
         
         -- parallel data out
         data_out     : out STD_LOGIC_VECTOR (7 downto 0);  -- Shifted data
         rcv_load     : out std_logic;  -- load signal to uC register
         
         -- rising edge and falling SCK edges
         sck_re   : in  std_logic;  -- rising edge of SCK
         sck_fe   : in  std_logic;  -- falling edge of SCK
         
         -- uC configuration for receive clock polarity
         rcv_cpol     : in STD_LOGIC;   -- receive clock polarity
         cpol     : in std_logic;   -- spi clock polarity
         
         ss_in_int    : in STD_LOGIC;   -- signal indicating another master
                            -- is on the bus
         
         reset        : in STD_LOGIC;       -- reset
         sclk         : in STD_LOGIC        -- clock
        
         );
        
end spi_rcv_shift_reg;




architecture DEFINITION of spi_rcv_shift_reg is

--******************************** Constants ***********************
constant RESET_ACTIVE   : std_logic := '0';

--******************************** Signals ***********************
signal data_int     : STD_LOGIC_VECTOR (7 downto 0);
signal shift_in     : STD_LOGIC;        -- data to be shifted in 
signal miso_neg     : STD_LOGIC;        -- data clocked on neg SCK
signal miso_pos     : STD_LOGIC;        -- data clocked on pos SCK

signal rcv_bitcnt_int   : unsigned(2 downto 0); -- internal bit count
signal rcv_bitcnt   : std_logic_vector(2 downto 0); -- bit count


begin

--******************************** SPI Receive Shift Register ***********************
-- This shift register is clocked on the SCK output from the CPLD
rcv_shift_reg:  process(sclk, reset, ss_in_int)
     begin
          
          -- Clear output register
          if (reset = RESET_ACTIVE or ss_in_int = '0') then
           data_int <= (others => '0');
           
      -- On rising edge of spi clock, shift in data
      elsif sclk'event and sclk = '1' then

           -- If shift enable is high
           if shift_en = '0' then

            -- Shift the data
            data_int <= data_int(6 downto 0) & shift_in;
            
           end if;

      end if;

     end process;

--******************************** MISO Input Registers ***********************  
-- The MISO signal is clocked on both the rising and falling edges of SCK. The output
-- of both these registers is then multiplexed with the RCV_CPOL control bit choosing
-- which data is the valid data for the system. This data is then the input to the
-- shift register.

-- SCK rising edge register
inreg_pos: process (sclk, reset, ss_in_int)
begin
    if reset = RESET_ACTIVE or ss_in_int = '0' then
        miso_pos <= '0';
    elsif sclk'event and sclk = '1' then
    
        miso_pos <= miso; 
    end if;
end process;

-- SCK falling edge register
inreg_neg: process (sclk, reset, ss_in_int)
begin
    if reset = RESET_ACTIVE or ss_in_int = '0' then
        miso_neg <= '0';
    elsif sclk'event and sclk = '0' then
    
        miso_neg <= miso; 
    end if;
end process;

-- RCV_CPOL multiplexor to determine shift in data
miso_mux: process (miso_neg, miso_pos, rcv_cpol)
begin
    if rcv_cpol = '1' then
        shift_in <= miso_pos;
    else
        shift_in <= miso_neg;
    end if;
end process;

--******************************** Parallel Data Out ***********************

data_out <= data_int(6 downto 0) & shift_in;

--******************************** Receive Bit Counter ***********************
-- Count bits loading into the SPI receive shift register based on SCK
-- assert RCV_LOAD when bit count is 0
RCV_BITCNT_PROC: process(sclk, reset, shift_en)
begin
    if reset = RESET_ACTIVE or shift_en = '1' then
        rcv_bitcnt_int <= (others => '0');
    elsif sclk'event and sclk = '1' then
            rcv_bitcnt_int <= rcv_bitcnt_int + 1;
    end if;
end process;

rcv_bitcnt <= STD_LOGIC_VECTOR(rcv_bitcnt_int);

--******************************** Receive Load ***********************
-- If RCV_CPOL = '0', want to assert RCV_LOAD with falling edge of SCK
-- If RCV_CPOL = '1', want to assert RCV_LOAD with rising edge of SCK 
-- only want RCV_LOAD to be 1 system clock pulse in width
rcv_load <= '1' when ( shift_en = '0' and
            (  (rcv_bitcnt="000" and cpol='0' and rcv_cpol='1' and sck_re='1')
            or (rcv_bitcnt="000" and cpol='1' and rcv_cpol='1' and sck_re='1')
            or (rcv_bitcnt="000" and cpol='0' and rcv_cpol='0' and sck_fe='1')
            or (rcv_bitcnt="111" and cpol='1' and rcv_cpol='0' and sck_fe='1') )
              )
        else '0';

end DEFINITION;
  
