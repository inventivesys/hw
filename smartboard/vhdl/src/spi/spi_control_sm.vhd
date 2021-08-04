-- File:     spi_control_sm.vhd
-- 



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity spi_control_sm is
    port(
         
         -- internal uC interface signals
         start          : in    std_logic;      -- start transfer
         done           : out   std_logic;  -- byte transfer is complete
         rcv_load       : in    std_logic;  -- load control signal to spi receive register
         ss_mask_reg    : in    std_logic_vector(7 downto 0);   -- uc slave select register
         ss_in_int      : inout std_logic;  -- internal sampled version of ss_in_n needed by
                                -- uc to generate an interrupt
         xmit_empty     : inout std_logic;  -- flag indicating that spitr is empty
         xmit_empty_reset   : in    std_logic;  -- xmit empty flag reset when spitr is written
         rcv_full       : out   std_logic;  -- flag indicating that spirr has new data
         rcv_full_reset : in    std_logic;  -- rcv full flag reset when spirr is read
         cpha           : in    std_logic;  -- clock phase from uc
         cpol           : in    std_logic;  -- clock polarity from uc
    
         -- spi interface signals
         ss_n           : out   std_logic_vector(7 downto 0);  -- slave select signals
         ss_in_n        : in    std_logic;  -- input slave select indicating master bus contention
         ss_n_int       : inout std_logic;  -- internal ss_n that is masked with 
                                            -- slave select register
         
         -- internal interface signals
         sck_int        : in    std_logic;  -- internal version of sck with cpha=1
         sck_int_re     : in    std_logic;  -- indicates rising edge on internal sck
         sck_int_fe     : in    std_logic;  -- indicates falling edge on internal sck
         sck_re         : in    std_logic;  -- indicates rising edge on external sck
         sck_fe         : in    std_logic;  -- indicates falling edge on external sck
         xmit_shift     : out   std_logic;  -- shift control signal to spi xmit shift register
         xmit_load      : inout std_logic;  -- load control signal to the spi xmit shift register
         clk1_mask      : out   std_logic;  -- masks cpha=1 version of sck 
         clk0_mask      : out   std_logic;  -- masks cpha=0 version of sck
         
         
         -- clock and reset
         reset          : in    std_logic;  -- active low reset     
         clk            : in    std_logic   -- clock
        
         );
        
end spi_control_sm;



architecture DEFINITION of spi_control_sm is

--**************************** Constants ***************************************

constant RESET_ACTIVE   : std_logic := '0';
constant EIGHT          : std_logic_vector(3 downto 0) := "1000";   

--**************************** Signals ***************************************

type SPI_STATE_TYPE is (IDLE, ASSERT_SSN1, ASSERT_SSN2, UNMASK_SCK, XFER_BIT, 
                        ASSERT_DONE, CHK_START, MASK_SCK, HOLD_SSN1, HOLD_SSN2,
                        NEGATE_SSN);
signal spi_state, next_spi_state    : SPI_STATE_TYPE;

signal bit_cnt      : STD_LOGIC_VECTOR(3 downto 0); -- bit counter output
signal bit_cnt_en   : STD_LOGIC;        -- count enable for bit counter
signal bit_cnt_rst  : STD_LOGIC;        -- reset for bit counter from SPI
                        -- control state machine
signal bit_cnt_reset    : STD_LOGIC;        -- reset to bit counter that includes
                        -- SS_IN_INT

signal ss_in_neg    : STD_LOGIC;        -- SS_IN_N sampled with rising edge of clk
signal ss_in_pos    : STD_LOGIC;        -- SS_IN_N sampled with negative edge of clk
signal ss_n_out     : STD_LOGIC_VECTOR(7 downto 0); -- output SS_N that are 3-stated if SS_IN_INT
                        -- is asserted indicating another master
                        


--**************************** Component Definitions  ********************************
-- 4-bit counter for bit counter
component upcnt4 
    port(
          
         cnt_en       : in STD_LOGIC;                        -- Count enable                       
         clr          : in STD_LOGIC;                        -- Active high clear
         clk          : in STD_LOGIC;                        -- Clock
         qout         : inout STD_LOGIC_VECTOR (3 downto 0)
        
         );
        
end component;

begin

--************************** Bit Counter Instantiation ********************************
BIT_CNTR : upcnt4
    port map(
          
         cnt_en       => bit_cnt_en,
         clr          => bit_cnt_reset,
         clk          => sck_int,
         qout         => bit_cnt
        
         );
         
--************************** SS_IN_N Input synchronization *******************************
-- When the SS_IN_N input is asserted, it indicates that there is another master on the bus
-- that has selected this master as a slave. When this signal asserts, the SPI master needs
-- to reset and tristate outputs. Therefore, the SS_IN_N input should be synchronized with the
-- system clock to prevent glitches on this signal from reseting the SPI master. The proces
-- below first samples SS_IN_N with the rising edge of the system clock and the falling edge
-- of the system clock. If both of these samples show that the signal is asserted, then the
-- internal SS_IN_INT signal will assert. SS_IN_INT is passed to the uC logic to generate an
-- interrupt if interrupts have been enabled. It is also passed to the SCK logic and the 
-- SPI Xmit shift register to tri-state the SCK and MOSI outputs.

ss_in_rising: process(clk, reset)
begin
    if reset = RESET_ACTIVE then
        ss_in_pos <= '1';
    elsif clk'event and clk = '1' then
        ss_in_pos <= ss_in_n;
    end if;
end process;

ss_in_falling: process (clk, reset)
begin
    if reset = RESET_ACTIVE then
        ss_in_neg <= '1';
    elsif clk'event and clk = '0' then
        ss_in_neg <= ss_in_n;
    end if;
end process;

ss_in_sample: process(clk,reset)
begin
    if reset = RESET_ACTIVE then
        ss_in_int <= '1';
    elsif clk'event and clk = '1' then
        if ss_in_pos = '0' and ss_in_neg = '0' then
            ss_in_int <= '0';
        else
            ss_in_int <= '1';
        end if;
    end if;
end process;

--************************** Bit Counter reset ***************************************
-- The bit counter needs to be reset when the reset signal is asserted from the SPI control
-- state machine is asserted and when SS_IN_INT is asserted
-- is asserted
bit_cnt_reset <= RESET_ACTIVE when bit_cnt_rst = RESET_ACTIVE or ss_in_int = '0'
        else not(RESET_ACTIVE);

--************************** SPI Control State Machine *******************************
-- Register process registers next state signals
-- Return to IDLE state whenever SS_IN_INT is asserted

spi_sm_reg:process(clk, reset, ss_in_int)

begin
          
          -- Set state to IDLE upon reset
          if (reset = RESET_ACTIVE or ss_in_int = '0') then
            spi_state <= IDLE;
           
     elsif clk'event and clk = '1' then

        spi_state <= next_spi_state;
      end if;

end process;

-- Combinatorial process determines next state logic

spi_sm_comb: process(spi_state, start,bit_cnt, sck_re, sck_fe, sck_int_re, sck_int_fe,
            xmit_empty, cpha, cpol)

begin

-- set defaults
clk0_mask   <= '0';
clk1_mask   <= '0';
bit_cnt_en  <= '0';
bit_cnt_rst <= RESET_ACTIVE;
next_spi_state <= spi_state;
done        <= '0';
xmit_shift  <= '0';
xmit_load   <= '0';

    case spi_state is
    
        --********************* IDLE State *****************
        when IDLE =>
            if start = '1' and xmit_empty = '0' then
                next_spi_state <= ASSERT_SSN1;
            end if;

        --********************* ASSERT_SSN1 State *****************
        when ASSERT_SSN1 =>
            -- this state asserts SS_N and waits for first edge of SCK_INT
            -- SS_N must be asserted ~1 SCK before SCK is output from chip

            if sck_int_re = '1' then
                next_spi_state <= ASSERT_SSN2;
            end if;
            
         --********************* ASSERT_SSN2 State *****************
        when ASSERT_SSN2 =>
            -- this state asserts SS_N and waits for next edge of SCK_INT
            -- SS_N must be asserted ~1 SCK before SCK is output from chip

            if sck_int_fe = '1' then
                next_spi_state <= UNMASK_SCK;
            end if;
            
       --********************* UNMASK_SCK State *****************
        when UNMASK_SCK =>
            bit_cnt_rst <= not(RESET_ACTIVE); -- release bit counter from reset
            bit_cnt_en <= '1';  -- enable bit counter
            clk1_mask <= '1';   -- unmask sck_1
            xmit_load <= '1';   -- load SPI shift register
        
            if sck_int_re = '1' then
                -- first rising edge of CPHA=1 clock with SS_N asserted
                -- transition to XFER_BIT state and unmask CPHA=0 clk
                next_spi_state <= XFER_BIT;
            end if;

        --********************* XFER_BIT State *****************
        when XFER_BIT =>
            clk0_mask <= '1';   -- unmask CPHA=0 clock
            clk1_mask <= '1';   -- unmask CPHA=1 clock
            bit_cnt_en <= '1';  -- enable bit counter
            bit_cnt_rst <= not(RESET_ACTIVE); -- release bit counter from reset
            
            xmit_shift <= '1';  -- enable shifting of SPI shift registers
            
            if bit_cnt = EIGHT  then
                -- all 8 bits have transferred
                next_spi_state <= ASSERT_DONE;
            end if;

        --********************* ASSERT_DONE State *****************
        when ASSERT_DONE =>
            -- this state asserts done to the uC so that new data
            -- can be written into the transmit register or data
            -- can be read from the receive register
            done <= '1';
            clk0_mask <= '1';
            clk1_mask <= '1';
            xmit_shift <= '1';
            if sck_int_fe = '1' then
                next_spi_state <= CHK_START;
            end if;
            
        --********************* CHK_START State *****************
        when CHK_START =>
            clk0_mask <= '1';
            clk1_mask <= '1';
            done <= '1';
            bit_cnt_en <= '1';
            bit_cnt_rst <= not(RESET_ACTIVE); -- release bit counter from reset
            if cpha = '0' then
                -- when CPHA = 0, have to negate slave select and then
                -- re-assert it. Need to wait for last SCK pulse to complete
                -- and mask SCK before negating SS_N. 
                if (sck_re = '1' and cpol = '1') or (sck_fe = '1' and cpol = '0') then
                    clk0_mask <= '0';
                    clk1_mask <= '0';
                    next_spi_state <= MASK_SCK;
                end if;
            elsif start = '1' and xmit_empty = '0' then 
                -- CPHA=1 and have more data to transfer, go back to 
                -- UNMASK_CK state
                clk1_mask <= '1';
            xmit_load <= '1';   -- load SPI shift register
                next_spi_state <= UNMASK_SCK;
            else 
                -- CPHA=1 and no more data to transfer
                -- wait for last SCKs and then mask SCK
                if (sck_re = '1' and cpol = '1') or (sck_fe = '1' and cpol = '0') then
                    clk0_mask <= '0';
                    clk1_mask <= '0';
                    next_spi_state <= MASK_SCK;
                end if;
                clk0_mask <= '0';
                clk1_mask <= '1';
            end if;
            
        --********************* MASK_SCK State *****************
        when MASK_SCK =>
            done <= '1';
            -- wait for next internal SCK edge 
            -- to help provide SS_N hold time
            if sck_int_fe <= '1' then
                next_spi_state <= HOLD_SSN1;
            end if;
            
        --********************* HOLD_SSN1 State *****************
        when HOLD_SSN1 =>
            -- This state waits for another SCK edge
            -- to provide SS_N hold time
            if  sck_int_fe = '1' then
                next_spi_state <= HOLD_SSN2;
            end if;
            
        --********************* HOLD_SSN2 State *****************
        when HOLD_SSN2 =>
            -- This state waits for another SCK edge
            -- to provide SS_N hold time
            if  sck_int_fe = '1' then
                next_spi_state <= NEGATE_SSN;
            end if;

        --********************* NEGATE_SSN State *****************
        when NEGATE_SSN =>
            -- SS_N should negate for an entire SCK
            -- This state waits for an SCK edge
            if sck_int_fe = '1' then
                next_spi_state <= IDLE;
            end if;
    
        --********************* Default State *****************
        when others =>
                next_spi_state <= IDLE;
    end case;
end process;


-- assert slave select when spi_state machine is in any state but IDLE or NEGATE_SSN
ss_n_int <= '1' when (spi_state = IDLE or spi_state = NEGATE_SSN) else '0';

--xmit_load <= '1' when (spi_state = UNMASK_SCK) else '0';


--************************** Register Full/Empty flags *******************************
-- When data is loaded into the SPI transmit shift register from SPITR, the XMIT_EMPTY
-- flag is set, indicating to the uC that new data can be written into SPITR. Note that
-- the SPI transmit shift register is clocked from SCK, therefore, this flag is clocked
-- from SCK.
mt_flag_process: process (sck_int, xmit_empty_reset, reset)
begin
    if xmit_empty_reset = RESET_ACTIVE or reset = RESET_ACTIVE then
        xmit_empty <= '0';
    elsif sck_int'event and sck_int = '1' then
        if xmit_empty_reset = RESET_ACTIVE then
            -- reset empty flag because uC has written data to SPITR
            xmit_empty <= '0';
        elsif xmit_load = '1' then
            -- set empty flag because SPITR data has been loaded into 
            -- SPI transmit shift register
            xmit_empty <= '1';
        end if;
    end if;
end process;



-- When data is loaded into SPIRR, the RCV_FULL flag is set, indicating to the uC that
-- new data from the SPI bus has been received.
full_flag_process: process (reset, clk)
begin
    if reset = RESET_ACTIVE then
        rcv_full <= '0';
    elsif clk'event and clk = '1' then
        if rcv_full_reset = RESET_ACTIVE then
            -- reset the full flag because the spirr has been read
            rcv_full <= '0';
        elsif rcv_load = '1' then
            -- set the full flag because data has been loaded in spirr
            rcv_full <= '1';
        end if;
    end if;
end process;

--************************** Slave Selects *******************************
-- The internal slave select signal generated by the SPI Control state machine 
-- is masked by the uC slave select register. The SS_N outputs are clocked on the
-- falling edge of the system clock. 
ss_n_process: process ( reset, clk)
variable i : integer;

begin
    if reset = RESET_ACTIVE then
        ss_n_out <= (others => '1');
    elsif clk'event and clk = '0' then
        for i in 0 to 7 loop
            if ss_n_int = '0' and ss_mask_reg (i) = '1' then
                ss_n_out(i) <= '0';  -- assert corresponding slave select
            else
                ss_n_out(i) <= '1';
            end if;
        end loop;
    end if;
end process;
    
-- Slave selects are 3-stated if SS_IN_INT is asserted  
ss_n <= ss_n_out when ss_in_int = '1'
    else (others => 'Z');

end DEFINITION;