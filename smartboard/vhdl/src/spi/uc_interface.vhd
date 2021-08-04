-- *****************************************************************************
-- uc_interface.vhd
-- 
-- *****************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;


entity uC_interface is
    generic (UC_ADDRESS : std_logic_vector(15 downto 8):= "00000000"  );
    port(
            -- 8051  bus interface
            clk         : in  std_logic;
            reset       : in  std_logic;     
        
            addr_data   : inout std_logic_vector (7 downto 0);  -- multiplexed address/data bus
            addr        : in    std_logic_vector (7 downto 0);  -- high byte of address 
            ale_n       : in    std_logic;                      -- address latch enable, active low 
            psen_n      : in    std_logic;                      -- program store enable, active low
        
            -- directional pins
            rd_n        : in    std_logic;  -- active low read strobe 
            wr_n        : in    std_logic;  -- active low write strobe
            int_n       : inout std_logic;  -- active low interrupt request
    
            -- internal spi signals
            -- interface to spi_control_sm
            spien       : inout std_logic;  -- enables the spi interface logic
            start       : inout std_logic;  -- start transfer
            done        : in    std_logic;  -- byte transfer is complete
            rcv_load    : in    std_logic;  -- load control signal to spi receive register
            spissr      : inout std_logic_vector(7 downto 0);   -- uc slave select register
            ss_n        : in    std_logic;  -- internal version of ss_n being output
            ss_in_int   : in    std_logic;  -- internal sampled version of ss_in_n needed by
                                -- uc to generate an interrupt
            xmit_empty  : in    std_logic;  -- flag indicating that spitr is empty
            xmit_empty_reset: inout std_logic;  -- xmit empty flag reset when spitr is written
            rcv_full    : in    std_logic;  -- flag indicating that spirr has new data
            rcv_full_reset  : inout std_logic;  -- rcv full flag reset when spirr is read

            -- interface to sck_logic;
            clkdiv      : inout std_logic_vector(1 downto 0);   -- sets the clock divisor for sck clock
            cpha        : inout std_logic;  -- sets clock phase for output sck clock
            cpol        : inout std_logic;  -- sets clock polarity for output sck clock
         
            -- interface to receive and transmit shift registers 
            spitr       : inout std_logic_vector (7 downto 0);  -- data to transmit on spi bus
            rcv_cpol    : inout std_logic;          -- clock polarity for incoming data 
            receive_data: in    std_logic_vector (7 downto 0)   -- data received from SPI bus
        
        );
        

end uC_interface;




architecture BEHAVIOUR of uC_interface is

--**************************** Constants ***************************************
constant RESET_ACTIVE : STD_LOGIC := '0';

-- Base Address for SPI Module (addr_bus[15:8])
constant BASE_ADDR  : STD_LOGIC_VECTOR(15 downto 8) := UC_ADDRESS;

-- Register Addresses (5 Total):
-- Status Register (BASE + 80h)
constant SPISR_ADDR     : STD_LOGIC_VECTOR(7 downto 0) := "10000000";

-- Control Register (BASE + 84h)
constant SPICR_ADDR     : STD_LOGIC_VECTOR(7 downto 0) := "10000100";

-- Slave Select Register (BASE + 88h)
constant SPISSR_ADDR    : STD_LOGIC_VECTOR(7 downto 0) := "10001000";

-- Transmit Data Register (BASE + 8Ah)
constant SPITR_ADDR     : STD_LOGIC_VECTOR(7 downto 0) := "10001010";

-- Receive Data Register (BASE + 8Eh)
constant SPIRR_ADDR : STD_LOGIC_VECTOR(7 downto 0) := "10001110";


--**************************** Signal Definitions ***************************************

-- Internal handshaking lines for microprocessor
signal data_out : STD_LOGIC_VECTOR(7 downto 0); -- holds the data to be output on the data bus
signal data_in  : STD_LOGIC_VECTOR(7 downto 0); -- holds the data to be input to the chip
signal data_oe  : STD_LOGIC;                    -- allows data to be output on the data bus

-- State signals for target state machine
type STATE_TYPE is (IDLE, ADDR_DECODE, DATA_TRS, END_CYCLE);
signal prs_state, next_state : STATE_TYPE;                  

-- Address match
signal address_match    : std_logic;

-- Register Enable Lines
signal cntrl_en     : std_logic;    -- control register is addressed
signal stat_en      : std_logic;    -- status register is addressed
signal xmit_en      : std_logic;    -- transmit data register is addressed  
signal rcv_en       : std_logic;    -- receive data register is addressed
signal ssel_en      : std_logic;    -- slave select register is addressed

-- Register reset lines
signal spierr_reset : STD_LOGIC;    -- writing 0 this bit in the status register 
                                    -- generates a reset to the bit
signal int_reset    : STD_LOGIC;    -- writing 0 this bit in the status register 
                                    -- generates a reset to the bit

-- low byte address lines
signal address_low  : STD_LOGIC_VECTOR(7 downto 0);

-- receive data register
signal spirr        : STD_LOGIC_VECTOR(7 downto 0); -- data received from SPI bus

-- control register signals
signal inten        : STD_LOGIC;    -- interrupt enable

-- status register signals
signal dt       : STD_LOGIC;    -- data transferring bit
signal spierr       : STD_LOGIC;    -- spi error bit
signal bb       : STD_LOGIC;    -- bus busy bit



begin

--************************** Bi-directional Data Bus **********************************

-- Bi-directional Data bus
addr_data <= data_out when (data_oe = '1') else (others => 'Z');
data_in <= addr_data when wr_n = '0' else (others => '0');


--************************** uC Interface State Machine *******************************
-- Register process registers next state signals
-- Return to IDLE state whenever RESET is asserted  

UC_SM_REGS: process (clk, reset)
begin
        if reset = RESET_ACTIVE then
            prs_state <= IDLE;
            
        elsif clk'event and clk = '1' then
            prs_state <= next_state;
            
        end if;
    
end process;

-- Combinatorial process determines next state logic
COMBINATIONAL: process (prs_state, ale_n, rd_n, wr_n, address_match, psen_n)
    
begin
    
next_state <= prs_state;
data_oe <= '0';
    
    
    case prs_state is
    
        --****************** IDLE State  *********************
        when IDLE =>

                -- Wait for falling edge of ALE_N with PSEN_N negated
            if ale_n = '0' and psen_n = '1' then
                -- falling edge of ALE_N
                next_state <= ADDR_DECODE;
            end if;

        
        --****************** ADDR_DECODE State  *****************
        when ADDR_DECODE =>
            
            -- Check that this module is being address
            if address_match = '1' then
                    -- Wait for rd_n or wr_n to be asserted
                    if rd_n = '0' or wr_n = '0' then
                        next_state <= DATA_TRS;
                end if;
            else
                -- this module is not being addressed
                  next_state <= IDLE;
            end if;
    
            
        --****************** DATA_TRS State  *********************
        when DATA_TRS =>

                -- Read or write from enabled register (see uC_regs process)
                -- if read cycle, assert the data output enable
                if rd_n = '0' then
                    data_oe <= '1';
                end if;
                
                -- wait until rd_n and wr_n negates before ending cycle
                if rd_n = '1' and wr_n = '1' then
                    next_state <= END_CYCLE;
                end if;

                        
        --****************** END_CYCLE State ********************
        when END_CYCLE =>
                
            
            -- Wait for negation of ale_n
            if (ale_n = '1') then
              next_state <= IDLE;
            end if;
        
             end case;
        
end process;

--************************** Address Registers **********************************
-- This process registers the low byte of address from the multiplexed address/data bus
-- on the falling edge of ale

address_regs: process(reset, ale_n)
begin
        if reset = RESET_ACTIVE then
        
            address_low <= (others => '0');
            
        elsif ale_n'event and ale_n = '0' then
            
            address_low <= addr_data;
        
        end if;
    
end process;

--************************** Address Decode **********************************
-- This process decodes the address and sets enables for the registers
address_decode: process (reset, clk)
begin
    if reset = RESET_ACTIVE then
        
        address_match   <= '0'; -- signal indicating that base address matches
        
        xmit_en     <= '0'; -- xmit data register enable
        rcv_en      <= '0'; -- receive data register enable
        cntrl_en    <= '0'; -- control register enable
        stat_en     <= '0'; -- status register enable
        ssel_en     <= '0'; -- slave select register enable
          
          
        -- Synchronize with rising edge of clock
        elsif clk'event and (clk = '1') then
        
          if ale_n = '0' and addr = BASE_ADDR and psen_n = '1' then
            -- base address matches and address is stable   
            address_match <= '1';
            
                -- Check appropriate register address
                case address_low(7 downto 0) is
              
                    when SPISR_ADDR =>  -- status register has been addressed
                        stat_en <= '1';
                    cntrl_en <= '0';
                    xmit_en <= '0';
                    rcv_en  <= '0';
                    ssel_en <= '0';

                    when SPICR_ADDR =>  -- control register has been addressed
                        stat_en <= '0';
                    cntrl_en <= '1';
                    xmit_en <= '0';
                    rcv_en  <= '0';
                    ssel_en <= '0';

                    when SPITR_ADDR =>  -- transmit data register has been addressed
                        stat_en <= '0';
                    cntrl_en <= '0';
                    xmit_en <= '1';
                    rcv_en  <= '0';
                    ssel_en <= '0';

                    when SPIRR_ADDR =>  -- transmit data register has been addressed
                        stat_en <= '0';
                    cntrl_en <= '0';
                    xmit_en <= '0';
                    rcv_en  <= '1';
                    ssel_en <= '0';

                    when SPISSR_ADDR => -- slave select register has been addressed 
                        stat_en <= '0';
                    cntrl_en <= '0';
                    xmit_en <= '0';
                    rcv_en  <= '0';
                    ssel_en <= '1';

                    when others =>      -- error condition, no registers are enabled 
                        stat_en <= '0';
                    cntrl_en <= '0';
                    xmit_en <= '0';
                    rcv_en  <= '0';
                    ssel_en <= '0';
                     
            end case;
          else
            -- this device is not addressed
            address_match <= '0';
                stat_en <= '0';
            cntrl_en <= '0';
            xmit_en <= '0';
            rcv_en  <= '0';
            ssel_en <= '0';
                     
          end if;
          
        end if;
        
    end process;
    
--************************** Read/Write uC registers **********************************
-- This process reads data from or writes data to the enabled register  

register_rw: process(clk, reset)
begin

        -- Initialize all internal registers upon reset
        if reset = RESET_ACTIVE then
            
            -- Status Register
            spierr_reset    <= RESET_ACTIVE;-- write to this bit clears it
            int_reset   <= RESET_ACTIVE;-- write to this bit clears it
            
            
            -- Control Register
            spien   <= '0';         -- enables the SPI interface
            inten   <= '0';         -- enables interrupts
            start   <= '0';         -- instructs SPI interface to start transfer
            clkdiv  <= (others => '0'); -- divisor for SCLK from system clock
            cpha    <= '0';         -- clock phase
            cpol    <= '0';         -- clock polarity
            rcv_cpol <= '0';        -- edge to use to clock incoming data

            -- Slave Select Register
            spissr  <= (others => '0'); -- initialize to no slaves selected

            -- Transmit data register
            spitr <= (others => '0');   -- initialize transmit data to 0
            xmit_empty_reset <= (RESET_ACTIVE); -- when transmit register is written,
                            -- the empty flag is reset
            -- Receive data register
            rcv_full_reset <= (RESET_ACTIVE);   -- when receive register is read, the
                            -- full flag is reset

            -- Initialize data bus
            data_out <= (others => '0');
    
        -- Check for rising edge of clock
        elsif clk'event and (clk = '1') then

          -- Check for data transfer state
          if (prs_state = DATA_TRS) then

                -- Control Register
                if cntrl_en = '1' then
              if wr_n = '0' then
                -- uC write            
                    spien   <= data_in(7);
                    inten   <= data_in(6);
                    start   <= data_in(5);
                    clkdiv  <= data_in(4 downto 3);
                    cpha    <= data_in(2);
                    cpol    <= data_in(1);
                    rcv_cpol<= data_in(0);
                  end if;
                  if rd_n = '0' then
                -- uC read
                data_out <= spien & inten & start &
                        clkdiv & cpha & cpol & rcv_cpol;
              
              end if;
            end if;

                -- Status Register
                if stat_en = '1' then
              if wr_n = '0' then
                            -- uC write to these bits generates a reset
                   if data_in(6) = '0' then
                    spierr_reset <= RESET_ACTIVE;
                   else
                        spierr_reset <= not(RESET_ACTIVE);
                   end if;

              end if;
              if rd_n = '0' then
                -- uC read
                data_out <= dt & spierr & bb & int_n & 
                      xmit_empty & rcv_full & "00";

              end if;
            end if;             

                -- Transmit Data Register
                if xmit_en = '1' then
                    if wr_n = '0' then
                    -- uC write
                     spitr <= data_in;
                     -- reset the empty flag
                     xmit_empty_reset <= RESET_ACTIVE;
                    end if;
                    if rd_n = '0' then
                     -- uC Read
                     data_out <= spitr;
                    end if;
            end if;
            
                -- Receive Data Register
                if rcv_en = '1' then
                    if rd_n = '0' then
                     -- uC Read
                     data_out <= spirr;
                     -- reset the full flag
                     rcv_full_reset <= RESET_ACTIVE;
                    end if;
            end if;     

                -- Slave select Register
                if ssel_en = '1' then
                    if wr_n = '0' then
                    -- uC write
                     spissr <= data_in;
                    end if;
                    if rd_n = '0' then
                     -- uC Read
                     data_out <= spissr;
                    end if;
            end if;         
          else
            xmit_empty_reset<= not(RESET_ACTIVE);
            rcv_full_reset  <= not(RESET_ACTIVE);
            spierr_reset    <= not(RESET_ACTIVE);

          end if;
    end if;
    
end process;

--************************** Status register **********************************
-- This process implements the bits in the status register
statusreg_process: process(clk, reset)

begin
    if reset = RESET_ACTIVE then
        bb <= '0';
        spierr <= '0';
        int_n <= '1';
        dt <= '0';
    elsif clk'event and clk = '1' then
        
        -- bus busy asserts when slave select is asserted
        if ss_n = '0' then
            bb <= '1';
        else
            bb <= '0';
        end if;
        
        -- spi error asserts when the input slave select is asserted 
        -- once asserted, this bit stays asserted until written to by the uC
        if spierr_reset = RESET_ACTIVE then
            spierr <= '0';
        elsif ss_in_int = '0' then
            spierr <= '1';
        end if;
        
        -- interrupt is asserted when the SPITR is empty or an error
        -- occurs IF interrupts are enabled
        -- interrupt service routine should read status register to determine
        -- cause of interrupt. After the first byte transfer, the RCV_FULL flag
        -- should be set when XMIT_EMPTY asserts so that uC can read receive data
        -- once asserted, this bit stays asserted until uC reads the status register.
        if spierr_reset = RESET_ACTIVE or xmit_empty_reset = RESET_ACTIVE or
            rcv_full_reset = RESET_ACTIVE then
            int_n <= '1';
        elsif inten = '1' then
            -- interrupts are enabled
            -- interrupt processor if there is an spierr, the xmit buffer is
            -- empty or if the receive buffer is full and its the end of the 
            -- transmission
            if spierr = '1' or 
            (start = '1' and xmit_empty = '1')  or
            (start = '0' and rcv_full = '1') then
                int_n <= '0';
            end if;
        end if;
        
        -- data transfer bit asserts when done is asserted
        if done = '1' then
            dt <= '1';
        else
            dt <= '0';
        end if;
    end if;
end process;

--************************** Receive data register **********************************
-- This process implements the bits in the receive register
receivereg_process: process(clk, reset)
begin
    if reset = RESET_ACTIVE then
        spirr <= (others => '0');
    elsif clk'event and clk = '1' then
        if spien = '0' then
            spirr <= (others => '0');
        elsif rcv_load = '1' then
            -- load the receive register
            spirr <= receive_data;
        else
            spirr <= spirr;
        end if;

    end if;
end process;


end BEHAVIOUR;
  
