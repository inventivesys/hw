  --------------------------------------------------------------------------------
  -- Entity declaration of 'BusInterface'.
  -- Last modified : Wed Feb 19 12:02:24 2003.
  --------------------------------------------------------------------------------


  library ieee ;
  use ieee.std_logic_1164.all ;

  entity BusInterface is
    generic(
      UC_ADDRESS :  std_logic_vector(15 downto 0) := (OTHERS => '0') ) ;
    port(
      ADDR_BUS      : in     std_logic_vector(23 downto 0) ;
      AS            : in     std_logic ;
      DATA_BUS      : inout  std_logic_vector(7 downto 0) ;
      DS            : in     std_logic ;
      DTACK         : out    std_logic ;
      IRQ           : out    std_logic ;
      R_W           : in     std_logic ;
      clk           : in     std_logic ; -- Clock
      maas          : in     std_logic ;
      madr          : inout  std_logic_vector(7 downto 0) ;
      mal           : in     std_logic ;
      mal_bit_reset : out    std_logic ;
      mbb           : in     std_logic ;
      mbcr_wr       : out    std_logic ;
      mbdr_i2c      : in     std_logic_vector(7 downto 0) ;
      mbdr_micro    : inout  std_logic_vector(7 downto 0) ;
      mbdr_read     : out    std_logic ;
      mcf           : in     std_logic ;
      men           : inout  std_logic ;
      mif           : in     std_logic ;
      mif_bit_reset : out    std_logic ;
      msta          : inout  std_logic ;
      msta_rst      : in     std_logic ;
      mtx           : inout  std_logic ;
      reset         : in     std_logic ; -- Reset
      rsta          : inout  std_logic ;
      rsta_rst      : in     std_logic ;
      rxak          : in     std_logic ;
      srw           : in     std_logic ;
      txak          : inout  std_logic ) ;
  end entity BusInterface ;

  --------------------------------------------------------------------------------
  -- Architecture 'structural' of 'BusInterface'
  -- Last modified : Wed Feb 19 12:02:24 2003.
  --------------------------------------------------------------------------------

  architecture structural of BusInterface is

  constant RESET_ACTIVE  : STD_LOGIC := '0';
      -- Base Address for I2C Module (addr_bus[23:8])
  constant MBASE  : STD_LOGIC_VECTOR(15 downto 0) := UC_ADDRESS;
  -- Register Addresses (5 Total):
  -- Address Register (MBASE + 141h)
  constant MADR_ADDR  : STD_LOGIC_VECTOR(7 downto 0) := "10001101";
  -- Control Register (MBASE + 145h)
  constant MBCR_ADDR  : STD_LOGIC_VECTOR(7 downto 0) := "10010001";
  -- Status Register (MBASE + 147h)
  constant MBSR_ADDR  : STD_LOGIC_VECTOR(7 downto 0) := "10010011";
  -- Data I/O Register (MBASE + 149h)
  constant MBDR_ADDR  : STD_LOGIC_VECTOR(7 downto 0) := "10010101";

  -- State Machine Options of process BusFsm:
  --  State assignment      : Enumerate.
  --  State decoding        : If-else construct.
  --  Actions on transitions: Combinational.
  --  Actions on states     : Combinational.

    type state_type is (IDLE, ADDR, DATA_TRS, ASSERT_DTACK) ;
    signal cur_state  :  state_type ;  -- Current State
    signal next_state :  state_type ; -- Next State

    signal as_int_d1     :  std_logic ;
    signal address_match :  std_logic ;
    signal as_int        :  std_logic ;
    signal dtack_com     :  std_logic ;
    signal addr_en       :  std_logic ;
    signal cntrl_en      :  std_logic ;
    signal stat_en       :  std_logic ;
    signal data_en       :  std_logic ;
    signal data_out      :  std_logic_vector(7 downto 0) ;
    signal data_in       :  std_logic_vector(7 downto 0) ;
    signal mien          :  std_logic ;
    signal ds_int        :  std_logic ;
    signal dtack_int     :  std_logic ;
    signal dtack_oe      :  std_logic ;
    signal StateReg      :  STATE_TYPE ;
  begin



      -- State machine of process: BusFsm



    next_state_decoding: process (cur_state, as_int, address_match, as_int_d1,
    clk, ds_int, AS) is
    begin
      next_state <= cur_state ;
      if cur_state = IDLE then
        if (as_int_d1 = '1' and as = '0') then
          next_state <= ADDR ;
        else
          next_state <= IDLE ;
        end if ;
      elsif cur_state = ADDR then
        if (address_match = '1' and ds_int  = '0') then
          next_state <= DATA_TRS ;
        elsif (ds_int  = '1') then
          next_state <= ADDR ;
        else
          next_state <= IDLE ;
        end if ;
      elsif cur_state = DATA_TRS then
          next_state <= ASSERT_DTACK ;
      elsif cur_state = ASSERT_DTACK then
        if (as_int_d1 = '0' and as_int =  '0') then
          next_state <= ASSERT_DTACK ;
        elsif (as_int_d1 = '1' and as_int = '1') then
          next_state <= IDLE ;
        end if ;
      end if ;
    end process next_state_decoding ;


    state_transition: process (clk, reset) is
    begin -- State Transition
      if (reset = RESET_ACTIVE) then
        cur_state <= IDLE ;
      elsif (clk'event and (clk = '1')) then
        cur_state <= next_state ;
      end if ; -- Reset & Clock
    end process state_transition ;


    state_actions: process (cur_state, as_int, address_match, as_int_d1, clk,
    ds_int, AS) is
    begin -- Combinational
        -- DefaultAssignment:
          dtack_com <= '1';
          dtack_oe  <= '0';
        if cur_state = DATA_TRS then
            dtack_oe <= '1';
        elsif cur_state = ASSERT_DTACK then
            dtack_com <= '0';
            dtack_oe <= '1';
        end if ;
    end process state_actions ;


    StateReg <= cur_state ;


    ADDRESS_DECODE: process (clk, reset) is       -- EASE/HDL sens.list
    begin

      if (reset = RESET_ACTIVE) then
          addr_en  <= '0';
          cntrl_en <= '0';
          stat_en  <= '0';
          data_en  <= '0';

      -- Synchronize with rising edge of clock

        elsif (rising_edge(clk)) then

          --  Just assign the default values any how.
          --  This will make the rest of the code much simpler

          addr_en  <= '0';
          cntrl_en <= '0';
          stat_en  <= '0';
          data_en  <= '0';

          -- I2C bus is specified by uProc and address is stable

          if (address_match = '1') then

              -- Check appropriate register address
              case addr_bus(7 downto 0) is

                when MADR_ADDR =>
                          addr_en  <= '1';

                when MBCR_ADDR =>
                          cntrl_en <= '1';

                when MBSR_ADDR =>
                          stat_en  <= '1';

                when MBDR_ADDR =>
                          data_en  <= '1';

                when others =>
                          --  Default assignment already done.
              end case;

          end if;

        end if;

    end process ADDRESS_DECODE ;


        -- Interrupt signal to uProcessor

        irq <= '0' when (mien = '1') and (mif = '1') else 'Z';

      -- DTACK signal to uProcession
      dtack <= dtack_int when (dtack_oe = '1') else 'Z';

      -- Bi-directional Data bus
      data_bus <= data_out when (r_w = '1' and dtack_oe = '1')
          else (others => 'Z');

      data_in <= data_bus when r_w = '0' else (others => '0');

    SYNC_INPUTS: process (clk, reset) is      -- EASE/HDL sens.list
    begin

        if (reset = RESET_ACTIVE) then
          as_int        <= '1';
          as_int_d1     <= '1';
          ds_int        <= '1';
          address_match <= '0';
        elsif (rising_edge(clk)) then
          as_int        <= as;
          as_int_d1     <= as_int;
          ds_int        <= ds;
          if (as = '0' and as_int_d1 = '1' and addr_bus(23 downto 8) = MBASE) then
              address_match <= '1';
          else
              address_match <= '0';
          end if;
        end if;

    end process SYNC_INPUTS ;


    DATA_DIR: process (reset, clk) is     -- EASE/HDL sens.list
    begin

      -- Initialize all internal registers upon reset
      if reset = RESET_ACTIVE then

          -- Address Register
          madr <= (others => '0');

          -- Control Register
          men  <= '0';
          mien <= '0';
          msta <= '0';
          mtx  <= '0';
          txak <= '0';
          rsta <= '0';

          mbcr_wr <= '0';

          -- Status Register
          mal_bit_reset  <= '0';
          mif_bit_reset  <= '0';

          -- Data Register
          mbdr_micro <= (others => '0');
          mbdr_read <= '0';

          -- Initialize data bus
          data_out <= (others => '0');

      -- Check for rising edge of clock
      elsif rising_edge(clk) then

          if (stateReg    = IDLE) then
              -- reset signals that indicate read from mbdr or write to mbcr
              mbcr_wr <= '0';
              mbdr_read <= '0';

          -- Check for data   transfer state
          elsif (stateReg = DATA_TRS) then

              -- Address register
              if addr_en = '1' then
                  if r_w = '0' then
                      -- uC write
                      madr <= data_in(7 downto 1) & '0';
                  else
                   -- uC read
                      data_out <= madr;
                  end if;
              end if;

               -- Control Register
              if  cntrl_en = '1' then
                  if r_w = '0' then
                  --  uC write
                      mbcr_wr <= '1';
                      men <= data_in(7);
                      mien    <= data_in(6);
                      msta    <= data_in(5);
                      mtx <= data_in(4);
                      txak    <= data_in(3);
                      rsta    <= data_in(2);

                  else
                      -- uC read
                      mbcr_wr <= '0';
                      data_out <= men & mien  & msta & mtx &
                                      txak    & rsta & "0" & "0";
                  end if;
              else
                  mbcr_wr <= '0';
              end if;

              -- Status Register
              if stat_en = '1' then
                  if r_w = '0' then
                      -- uC   write to these bits generates a reset
                      if data_in(4) = '0' then
                          mal_bit_reset <= '1';
                      end if;

                      if data_in(2) = '0' then
                          mif_bit_reset <= '1';
                      end if;
                  else
                  -- uC read
                      data_out <= mcf & maas & mbb & mal &
                              "0" &   srw & mif & rxak;
                      mal_bit_reset <=    '0';
                      mif_bit_reset <=    '0';

                  end if;
              end if;

                  -- Data Register
              if data_en =    '1' then
                  if r_w =    '0' then
                      -- uC write
                       mbdr_read <= '0';
                       mbdr_micro <= data_in;
                  else
                      --  uC Read
                      mbdr_read <= '1';
                      data_out <= mbdr_i2c;
                  end if;
              else
                  mbdr_read <= '0';
              end if;
          end if;
          -- if   arbitration is lost, the I2C Control component will generate a reset for the
          -- MSTA bit to force the design to slave mode
          -- will do this reset   synchronously

          if msta_rst = '1' then
              msta <= '0';
          end if;

          if rsta_rst = RESET_ACTIVE then
              rsta <= '0';
          end if;

      end if; --  Clk

    end process DATA_DIR ;


    dtackClk: process (reset, clk) is     -- EASE/HDL sens.list
    begin
      if (reset = RESET_ACTIVE) then
          dtack_int <= '1';
      elsif (clk'event and clk = '1') then
          dtack_int <= dtack_com;
      end if;
    end process dtackClk ;
  end architecture structural ; -- of BusInterface



