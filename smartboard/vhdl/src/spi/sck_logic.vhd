-- File:     sck_logic.vhd
-- 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity sck_logic is
    port(
         
         -- internal uC interface signals
         clkdiv     : in    std_logic_vector(1 downto 0);   -- sets the clock divisor for sck clock
         cpha       : in    std_logic;  -- sets clock phase for output sck clock
         cpol       : in    std_logic;  -- sets clock polarity for output sck clock
         
         -- internal spi interface signals
         clk0_mask  : in    std_logic;  -- clock mask for sck when cpha=0
         clk1_mask  : in    std_logic;  -- clock mask for sck when cpha=1
         sck_1      : inout std_logic;  -- internal sck created from dividing system clock
         sck_int_re : out   std_logic;  -- rising edge of internal sck
         sck_int_fe : out   std_logic;  -- falling edge of internal sck
         sck_re     : out   std_logic;  -- rising edge of external sck
         sck_fe     : out   std_logic;  -- falling edge of external sck
         ss_in_int  : in    std_logic;  -- another master is on the bus
         
         -- external spi interface signals
         sck        : inout std_logic;      -- sck as determined by cpha, cpol, and clkdiv
         
         -- clock and reset
         reset      : in    std_logic;  -- active high reset    
         clk        : in    std_logic   -- clock
        
         );
        
end sck_logic;



architecture DEFINITION of sck_logic is

--**************************** Constants ***************************************

constant RESET_ACTIVE   : std_logic := '0';

--**************************** Signals ***************************************

signal clk_cnt      : STD_LOGIC_VECTOR(4 downto 0); -- clock divider output
signal clk_cnt_en   : STD_LOGIC;            -- count enable for clock divider
signal clk_cnt_rst  : STD_LOGIC;            -- clock count reset


signal sck_int_d1   : STD_LOGIC;    -- sck_int delayed one clock for edge detection
signal sck_int      : STD_LOGIC;    -- version of sck when CPHA=1
signal sck_0        : STD_LOGIC;    -- version of sck when CPHA=0
signal sck_out      : STD_LOGIC;    -- sck to be output if SS_IN_INT is not asserted
signal sck_d1       : std_logic;    -- output sck delayed one clock for edge detection


--**************************** Component Definitions  ********************************
-- 5-bit counter for clock divider
component upcnt5 
    port(
          
         cnt_en       : in STD_LOGIC;                        -- Count enable                      
         clr          : in STD_LOGIC;                        -- Active high clear
         clk          : in STD_LOGIC;                        -- Clock
         qout         : inout STD_LOGIC_VECTOR (4 downto 0)
        
         );
        
end component;


begin

--************************** Clock Divider Instantiation ********************************
CLK_DIVDR : upcnt5
    port map(
          
         cnt_en       => clk_cnt_en,
         clr          => clk_cnt_rst,
         clk          => clk,
         qout         => clk_cnt
        
         );
-- This counter is always enabled, can't instantiate the counter with a literal
clk_cnt_en <= '1';

-- Clock counter is reset whenever reset is active and ss_in_int is asserted
clk_cnt_rst <= RESET_ACTIVE when reset = RESET_ACTIVE or ss_in_int = '0'
        else not(RESET_ACTIVE);

--************************** Internal SCK Generation ***************************************
-- SCK when CPHA=1 is simply the output of the clock divider determined by the CLK_DIV bits
-- SCK_INT is based off the CPHA=1 waveforms and is used as the internal SCK
-- SCK_INT is used to clock the SPI shift register, therefore, it runs before and after SS_N
-- is asserted
-- SCK_1 is SCK_INT when clk1_mask = 1. The clock mask blocks SCK_INT edges that are before
-- and after SS_N
sck_int_process: process (clk,reset)
begin
    if reset = RESET_ACTIVE  then
        sck_int <= '0';
    elsif clk'event and clk = '1' then
    
        -- determine clock divider output based on control register
        case clkdiv is
            when "00" =>
                sck_int <= clk_cnt(1);
            when "01" =>
                sck_int <= clk_cnt(2);
            when "10" =>
                sck_int <= clk_cnt(3);
            when "11" =>
                sck_int <= clk_cnt(4);
            when others =>  -- error in register
                sck_int <= '0';
        end case;
    end if;
end process;

sck_1 <= sck_int and clk1_mask;


-- Detect rising and falling edges of SCK_1 to use as state transition
sck_intedge_process: process(clk, reset)
begin
    if reset = RESET_ACTIVE then
        sck_int_d1 <= '0';
    elsif clk'event and clk = '1' then
        sck_int_d1 <= sck_int;

    end if;
end process;


sck_int_re <= '1' when sck_int = '1' and sck_int_d1 = '0' 
        else '0';
sck_int_fe <= '1' when sck_int = '0' and sck_int_d1 = '1'
        else '0';   

-- SCK when CPHA=0 is out of phase with internal SCK - therefore its toggle needs to be delayed 
-- by the signal clk_mask and then its simply an inversion of the counter bit

sck_0_process: process (clk, reset)
begin
    if reset = RESET_ACTIVE then
        sck_0 <= '0';
    elsif clk'event and clk = '1' then
        
        if clk0_mask = '0' then
            sck_0 <= '0';
        else
            case clkdiv is
                when "00" =>
                    sck_0 <= not(clk_cnt(1));
                when "01" =>
                    sck_0 <= not(clk_cnt(2));
                when "10" =>
                    sck_0 <= not(clk_cnt(3));
                when "11" =>
                    sck_0 <= not(clk_cnt(4));
                when others =>  -- error in register
                    sck_0 <= '0';
            end case;
        end if;
    end if;
end process;

--************************** External SCK Generation **********************************
-- This process outputs SCK based on the CPHA and CPOL parameters set in the control register
sck_out_process: process(clk, reset, cpol)
variable temp:  std_logic_vector(1 downto 0);
begin
    if reset = RESET_ACTIVE then
        sck_out <= '0';
    elsif clk'event and clk = '1' then
        temp := cpol & cpha;
        case temp is
            when "00" =>    -- polarity = 0, phase = 0
                    -- sck = sck_0
                sck_out <= sck_0;
            when "01" =>    -- polarity= 0, phase = 1
                    -- sck = sck_1
                sck_out <= sck_1;
            when "10" =>    -- polarity = 1, phase = 0
                    -- sck = not(sck_0)
                sck_out <= not(sck_0);
            when "11" =>    -- polarity = 1, phase = 1
                    -- sck = not(sck_1)
                sck_out <= not(sck_1);
            when others =>  -- default to sck_0
                sck_out <= sck_0;
        end case;
    end if;
end process;

-- Detect rising and falling edges of SCK_OUT to use to end cycle correctly
-- and to keep RCV_LOAD signal 1 system clock in width
SCK_DELAY_PROCESS: process(clk, reset)
begin
    if reset = RESET_ACTIVE then
        sck_d1 <= '0';
    elsif clk'event and clk = '1' then
        sck_d1 <= sck_out;

    end if;
end process;


sck_re <= '1' when sck_out = '1' and sck_d1 = '0' 
        else '0';
sck_fe <= '1' when sck_out = '0' and sck_d1 = '1'
        else '0';

-- The SCK output is 3-stated if the SS_IN_INT signal is asserted indicating that another
-- master is on the bus
sck <= sck_out when ss_in_int = '1' 
    else    'Z';


end DEFINITION;
  

