  --------------------------------------------------------------------------------
  -- Entity declaration of 'i2c_Control'.
  -- Last modified : Wed Feb 19 12:02:24 2003.
  --------------------------------------------------------------------------------


  library ieee ;
  use ieee.std_logic_1164.all ;

  entity i2c_Control is
    port(
      maas          : inout  std_logic ;
      madr          : in     std_logic_vector(7 downto 0) ;
      mal           : inout  std_logic ;
      mal_bit_reset : in     std_logic ;
      mbb           : out    std_logic ;
      mbcr_wr       : in     std_logic ;
      mbdr_i2c      : inout  std_logic_vector(7 downto 0) ;
      mbdr_micro    : in     std_logic_vector(7 downto 0) ;
      mcf           : inout  std_logic ;
      mif           : out    std_logic ;
      mif_bit_reset : in     std_logic ;
      msta          : in     std_logic ;
      msta_rst      : out    std_logic ;
      mtx           : in     std_logic ;
      reset         : in     std_logic ;
      rsta          : in     std_logic ;
      rsta_rst      : out    std_logic ;
      rxak          : out    std_logic ;
      scl           : inout  std_logic ;
      sda           : inout  std_logic ;
      srw           : inout  std_logic ;
      sys_clk       : in     std_logic ;
      txak          : in     std_logic ) ;
  end entity i2c_Control ;

  --------------------------------------------------------------------------------
  -- Architecture 'a0' of 'i2c_Control'
  -- Last modified : Wed Feb 19 12:02:24 2003.
  --------------------------------------------------------------------------------

  architecture a0 of i2c_Control is

  constant    CNT_100KHZ  :   std_logic_vector(4 downto 0) := "10100";-- number of 2MHz clocks in 100KHz
  constant    HIGH_CNT    :   std_logic_vector(3 downto 0) := "1000"; -- number of 2MHz clocks in half
                                          -- 100KHz period -1 since count from 0
                                          -- and -1 for "edge" state
  constant    LOW_CNT :   std_logic_vector(3 downto 0) := "1000"; -- number of 2Mhz clocks in half
                                          -- 100KHZ period -1 since count from 0
                                           -- and -1 for "edge" state
  constant    HIGH_CNT_2  :   std_logic_vector(3 downto 0) := "0100"; -- half of HIGH_CNT

  constant    TBUF        :   std_logic_vector(3 downto 0) := "1001"; -- number of 2MHz clocks in 4.7uS
  constant    DATA_HOLD   :   std_logic_vector(3 downto 0) := "0001"; -- number of 2MHz clocks in 300ns
  constant    START_HOLD  :   std_logic_vector(3 downto 0) := "1000"; -- number of 2MHz clocks in 4.0uS
  constant    CLR_REG :       std_logic_vector (7 downto 0) := "00000000";
  constant    START_CNT       :   std_logic_vector (3 downto 0) := "0000";
  constant    CNT_DONE        :   std_logic_vector (3 downto 0) := "0111";
  constant    ZERO_CNT    :   std_logic_vector (3 downto 0) := "0000";
  constant    ZERO        :   std_logic := '0';
  constant    RESET_ACTIVE:   std_logic := '0';


  -- State Machine Options of process MainFsm:
  --  State assignment      : Enumerate.
  --  State decoding        : If-else construct.
  --  Actions on transitions: Clocked.
  --  Actions on states     : Clocked.

    type state_type is (IDLE, HEADER, ACK_HEADER, RCV_DATA, XMIT_DATA,
              ACK_DATA, WAIT_ACK) ;
    signal state :  state_type ;  -- Current State

  -- State Machine Options of process SlcFsm:
  --  State assignment      : Enumerate.
  --  State decoding        : If-else construct.
  --  Actions on transitions: Comb.(in 1 Block).
  --  Actions on states     : Comb.(in 1 Block).

    type state_type_Scl is (SCL_IDLE_Scl, START_Scl, SCL_LOW_EDGE_Scl,
              SCL_LOW_Scl, SCL_HIGH_EDGE_Scl, SCL_HIGH_Scl, STOP_WAIT_Scl) ;
    signal cur_state_Scl  :  state_type_Scl ;  -- Current State
    signal next_state_Scl :  state_type_Scl ; -- Next State

    component SHIFT8
      port(
        clk       : in     STD_LOGIC ;
        clr       : in     STD_LOGIC ;
        data_in   : in     STD_LOGIC_VECTOR(7 downto 0) ;
        data_ld   : in     STD_LOGIC ;
        data_out  : out    STD_LOGIC_VECTOR(7 downto 0) ;
        shift_en  : in     STD_LOGIC ;
        shift_in  : in     STD_LOGIC ;
        shift_out : out    STD_LOGIC ) ;
    end component SHIFT8 ;
    component upcnt4
      port(
        clk    : in     STD_LOGIC ;
        clr    : in     STD_LOGIC ;
        cnt_en : in     STD_LOGIC ;
        data   : in     STD_LOGIC_VECTOR(3 downto 0) ;
        load   : in     STD_LOGIC ;
        qout   : out    STD_LOGIC_VECTOR(3 downto 0) ) ;
    end component upcnt4 ;
    signal bit_cnt_en     :  std_logic ;
    signal bit_cnt_ld     :  std_logic ;
    signal sda_in         :  std_logic ;
    signal scl_in         :  std_logic ;
    signal msta_d1        :  std_logic ;
    signal sda_out_reg    :  std_logic ;
    signal sda_oe         :  std_logic ;
    signal scl_not        :  std_logic ;
    signal arb_lost       :  std_logic ;
    signal sda_out_reg_d1 :  std_logic ;
    signal master_slave   :  std_logic ;
    signal gen_start      :  std_logic ;
    signal gen_stop       :  std_logic ;
    signal detect_start   :  std_logic ;
    signal detect_stop    :  std_logic ;
    signal bus_busy       :  std_logic ;
    signal i2c_header_en  :  std_logic ;
    signal shift_reg_en   :  std_logic ;
    signal shift_reg_ld   :  std_logic ;
    signal mdbr_micro     :  std_logic_vector(7 downto 0) ;
    signal i2c_header     :  STD_LOGIC_VECTOR(7 downto 0) ;
    signal clk_cnt        :  STD_LOGIC_VECTOR(3 downto 0) ;
    signal clk_cnt_rst    :  std_logic ;
    signal clk_cnt_en     :  std_logic ;
    signal bit_cnt        :  std_logic_vector(3 downto 0) ;
    signal bus_busy_d1    :  std_logic ;
    signal ResetOrStop    :  std_logic ;
    signal sm_stop        :  std_logic ;
    signal slave_sda      :  std_logic ;
    signal shift_reg      :  STD_LOGIC_VECTOR(7 downto 0) ;
    signal addr_match     :  std_logic ;
    signal master_sda     :  std_logic ;
    signal scl_out        :  std_logic ;
    signal sda_out        :  std_logic ;
    signal stop_scl       :  std_logic ;
    signal rep_start      :  std_logic ;
    signal stop_scl_reg   :  std_logic ;
    signal scl_out_reg    :  std_logic ;
    signal mainFsmState   :  state_type ;
    signal shift_out      :  std_logic ;
  begin

    mbb <= bus_busy ;
    mdbr_micro <= mbdr_micro ;

    i2cheader_reg: SHIFT8
      port map(
        clk => scl_not,
        clr => reset,
        data_in => "00000000",
        data_ld => '0',
        data_out => i2c_header,
        shift_en => i2c_header_en,
        shift_in => sda_in,
        shift_out => open ) ;

    BitCnt: upcnt4
      port map(
        clk => scl_not,
        clr => reset,
        cnt_en => bit_cnt_en,
        data => "0000",
        load => bit_cnt_ld,
        qout => bit_cnt ) ;

    i2cdata_reg: SHIFT8
      port map(
        clk => scl_not,
        clr => reset,
        data_in => mdbr_micro,
        data_ld => shift_reg_ld,
        data_out => shift_reg,
        shift_en => shift_reg_en,
        shift_in => sda_in,
        shift_out => shift_out ) ;

    ClkCnt: upcnt4
      port map(
        clk => sys_clk,
        clr => reset,
        cnt_en => clk_cnt_en,
        data => "0000",
        load => clk_cnt_rst,
        qout => clk_cnt ) ;


      -- Counter control lines
      bit_cnt_en <= '1' when (state = HEADER) or (state = RCV_DATA)
                          or (state = XMIT_DATA) else '0';

      bit_cnt_ld <= '1' when (state = IDLE) or (state = ACK_HEADER)
                          or (state = ACK_DATA)
                          or (state = WAIT_ACK)
                          or (detect_start = '1') else '0';



    input_regs: process (reset, sys_clk) is       -- EASE/HDL sens.list
    begin
      if reset = RESET_ACTIVE then
          sda_in <= '1';
          scl_in <= '1';
          msta_d1 <= '0';
          sda_out_reg_d1 <= '1';

      elsif sys_clk'event and sys_clk = '1' then
          -- the following if, then, else clauses are used
          -- because scl may equal 'H' or '1'
          if scl = '0' then
              scl_in <= '0';
          else
              scl_in <= '1';
          end if;
          if sda = '0' then
              sda_in <= '0';
          else
              sda_in <= '1';
          end if;
          sda_out_reg_d1 <= sda_out_reg;
          msta_d1 <= msta;
      end if;

    end process input_regs ;


      -- set SDA and SCL
      sda <= '0' when sda_oe = '1' else 'Z';
      scl <= '0' when scl_out_reg = '0' else 'Z';
      scl_not <= not(scl);

      -- sda_oe is set when master and arbitration is not lost and data to be output = 0 or
      -- when slave and data to be output is 0

      sda_oe <= '1' when ((master_slave = '1' and arb_lost = '0' and sda_out_reg = '0') or
                   (master_slave = '0' and slave_sda = '0')
                    or stop_scl_reg = '1') else '0';



      -- State machine of process: MainFsm



    state_decoding: process (scl, ResetOrStop) is
    begin
      if (ResetOrStop = '1') then
        state <= IDLE ;
          sm_stop <= '0';
      elsif (scl'event and (scl = '0')) then
        if state = IDLE then
          if (detect_start = '1') then -- Start
            state <= HEADER ;
          end if ;
        elsif state = HEADER then
          if (bit_cnt =  CNT_DONE) then -- FullCounter
            state <= ACK_HEADER ;
          end if ;
        elsif state = ACK_HEADER then
          if (arb_lost = '1') then -- ArbiterLost
            state <= IDLE ;
          elsif (
            (master_slave = '1' and mtx = '0') or
            (addr_match = '1' and i2c_header(0) = '0')
            ) then
            state <= RCV_DATA ;
          elsif (
            master_slave = '1' or
            addr_match = '1'
            ) then
            state <= XMIT_DATA ;
          else
            state <= IDLE ;
          end if ;
        elsif state = RCV_DATA then
          if (bit_cnt =  CNT_DONE) then -- FullCounter
            state <= ACK_DATA ;
          elsif (detect_start = '1') then -- Start
            state <= HEADER ;
          end if ;
        elsif state = XMIT_DATA then
          if (bit_cnt =  CNT_DONE) then -- FullCounter
            state <= WAIT_ACK ;
          elsif (detect_start = '1') then -- Start
            state <= HEADER ;
          end if ;
        elsif state = ACK_DATA then
            state <= RCV_DATA ;
        elsif state = WAIT_ACK then
          if (arb_lost = '1') then -- ArbiterLost
            state <= IDLE ;
          elsif (sda = '0') then
            state <= XMIT_DATA ;
          else
            state <= IDLE ;
            -- Stop:
              if master_slave = '1' then
                  sm_stop <= '1';
              end if;
          end if ;
        end if ;
      end if ; -- Reset & Clock
    end process state_decoding ;


    mainFsmState <= state ;


    Arbitration: process (reset, sys_clk, master_slave) is        -- EASE/HDL sens.list
    begin
      if reset = RESET_ACTIVE then
          arb_lost <= '0';
          msta_rst <= '0';
        elsif (sys_clk'event and sys_clk = '1') then
          if cur_state_Scl = SCL_IDLE_Scl then
              arb_lost <= '0';
              msta_rst <= '0';
              elsif (master_slave = '1') then
              -- only need to check arbitration in master mode
                  -- check for SCL high before comparing data and insure that arb_lost is
              -- not already set
              if (scl_in = '1' and scl = '1' and arb_lost = '0'
                  and (state = HEADER or  state = XMIT_DATA or state = IDLE)) then
                  -- when master, will check bus in all states except ACK_HEADER and WAIT_ACK
                  -- this will insure that arb_lost is set if a start or stop condition
                  -- is set at the wrong time
                  if (sda_out_reg_d1 = sda_in) then
                      arb_lost <= '0';
                      msta_rst <= '0';
                  else
                      arb_lost <= '1';
                      msta_rst <= '1';
                  end if;
              else
                  arb_lost <= arb_lost;
                  msta_rst <= '0';
              end if;
          end if;
        end if;

    end process Arbitration ;


    ControlBits: process (reset, sys_clk, detect_start,
          scl_in) is      -- EASE/HDL sens.list
    begin
      if reset = RESET_ACTIVE then
          gen_start <= '0';
          gen_stop <= '0';
          master_slave <= '0';
      elsif sys_clk'event and sys_clk = '1' then
          if msta_d1 = '0' and msta = '1' then
              -- rising edge of MSTA - generate start condition
              gen_start <= '1';
          elsif detect_start = '1' then
              gen_start <= '0';
          end if;
          if arb_lost = '0' and msta_d1 = '1' and msta = '0' then
              -- falling edge of MSTA - generate stop condition only
              -- if arbitration has not been lost
              gen_stop <= '1';
          elsif detect_stop = '1' then
              gen_stop <= '0';
          end if;
          if bus_busy = '0' then
              master_slave <= msta;
          else
              master_slave <= master_slave;
          end if;
      end if;

    end process ControlBits ;


      -- State machine of process: SlcFsm



    next_state_decoding_Scl: process (cur_state_Scl, master_slave, gen_start,
    master_sda, clk_cnt, gen_stop, arb_lost, sm_stop, rep_start, bus_busy,
    stop_scl_reg, bit_cnt, scl_in, sda_out_reg, scl_out_reg) is
    begin
      next_state_Scl <= cur_state_Scl ;
      -- def:
        scl_out <= '1';
        sda_out <= sda_out_reg;
        stop_scl <= stop_scl_reg;
        clk_cnt_en <= '0';
        clk_cnt_rst <= '1';
        rsta_rst <= not(RESET_ACTIVE);

      if cur_state_Scl = SCL_IDLE_Scl then
        -- IDLE:
          sda_out <= '1';
          stop_scl <= '0';
        if (master_slave = '1' and bus_busy = '0' and gen_start = '1') then -- Start
          next_state_Scl <= START_Scl ;
        end if ;
      elsif cur_state_Scl = START_Scl then
        -- START:
          --generate start condition
          clk_cnt_en <= '1';
          clk_cnt_rst <= '0';
          sda_out <= '0';
          stop_scl <= '0';
          --generate reset for repeat start bit if repeat start condition
          if rep_start = '1' then
             rsta_rst <= RESET_ACTIVE;
          end if;

        if (clk_cnt = START_HOLD) then -- Low_edge
          next_state_Scl <= SCL_LOW_EDGE_Scl ;
        end if ;
      elsif cur_state_Scl = SCL_LOW_EDGE_Scl then
        -- LOW_EDGE:
          clk_cnt_rst <= '1';
          scl_out <= '0';
          stop_scl <=  '0';
          next_state_Scl <= SCL_LOW_Scl ;
      elsif cur_state_Scl = SCL_LOW_Scl then
        -- LOW:
          clk_cnt_en <= '1';
          clk_cnt_rst <= '0';
          scl_out <= '0';

          --set SDA_OUT based on control signals
          if arb_lost = '1' then
              stop_scl <= '0';
          elsif ((sm_stop = '1' or gen_stop = '1') and (state /= ACK_DATA and state /= ACK_HEADER and state /= WAIT_ACK)) then
              sda_out <= '0';
              stop_scl <= '1';
          elsif rep_start = '1' then
              sda_out <= '1';
              stop_scl <= '0';
          elsif clk_cnt = DATA_HOLD then
              sda_out <= master_sda;
              stop_scl <= '0';
          else
             stop_scl <= '0';
          end if;
        if (clk_cnt /= LOW_CNT) then -- Back_low_edge
          next_state_Scl <= SCL_LOW_Scl ;
        elsif (bit_cnt = CNT_DONE and arb_lost = '1') then -- Low_idle
          next_state_Scl <= SCL_IDLE_Scl ;
        else
          next_state_Scl <= SCL_HIGH_EDGE_Scl ;
        end if ;
      elsif cur_state_Scl = SCL_HIGH_EDGE_Scl then
        -- HIGH_EDGE:
          clk_cnt_rst <= '1';
          scl_out <= '1';
          if ((sm_stop = '1' or gen_stop = '1') and (state /= ACK_DATA and state /=ACK_HEADER and state /= WAIT_ACK)) then
               stop_scl <= '1';
          else
              stop_scl <= '0';
          end if;
        if (scl_in = '1') then -- High_edge
          next_state_Scl <= SCL_HIGH_Scl ;
        end if ;
      elsif cur_state_Scl = SCL_HIGH_Scl then
        -- HIGH:
          clk_cnt_en <= '1';
          clk_cnt_rst <= '0';
          scl_out <= '1';
        if (clk_cnt = HIGH_CNT_2 and rep_start = '1') then -- High_start
          next_state_Scl <= START_Scl ;
          -- HIGH_startstop:
            clk_cnt_rst <= '1';
        elsif (clk_cnt = HIGH_CNT_2 and stop_scl_reg = '1') then -- High_stop
          next_state_Scl <= STOP_WAIT_Scl ;
          -- HIGH_startstop:
            clk_cnt_rst <= '1';
        elsif (clk_cnt = HIGH_CNT) then -- High_lowedge
          next_state_Scl <= SCL_LOW_EDGE_Scl ;
        end if ;
      elsif cur_state_Scl = STOP_WAIT_Scl then
        -- STOP:
          clk_cnt_en <= '1';
          clk_cnt_rst <= '0';
          sda_out <= '1';
          stop_scl <= '0';
        if (clk_cnt = TBUF) then -- Stop_idle
          next_state_Scl <= SCL_IDLE_Scl ;
        end if ;
      end if ;
    end process next_state_decoding_Scl ;


    state_transition_Scl: process (sys_clk, reset) is
    begin -- State Transition
      if (reset = RESET_ACTIVE) then -- Idle
        cur_state_Scl <= SCL_IDLE_Scl ;
      elsif (sys_clk'event and (sys_clk = '1')) then
        cur_state_Scl <= next_state_Scl ;
      end if ; -- Reset & Clock
    end process state_transition_Scl ;



    StartDetermine: process (sda, reset, mainFsmState) is     -- EASE/HDL sens.list
    begin
      if reset = RESET_ACTIVE or mainFsmState = HEADER then
          detect_start <= '0';
      elsif sda'event and sda = '0' then
          if scl /= '0' then
              detect_start <= '1';
          else
              detect_start <= '0';
          end if;
      end if;
    end process StartDetermine ;


    StopDetermine: process (detect_start, sda, reset) is      -- EASE/HDL sens.list
    begin
      if reset = RESET_ACTIVE or detect_start = '1' then
          detect_stop <= '0';
      elsif sda'event and sda /= '0' then
          if scl /= '0' then
              detect_stop <= '1';
          else
              detect_stop <= '0';
          end if;
      end if;

    end process StopDetermine ;


    SetBusy: process (reset, sys_clk) is      -- EASE/HDL sens.list
    begin
      if reset = RESET_ACTIVE then
          bus_busy <= '0';
          bus_busy_d1 <= '0';
      elsif sys_clk'event and sys_clk = '1' then

          bus_busy_d1 <= bus_busy;

          if detect_start = '1' then
              bus_busy <= '1';
          end if;
          if detect_stop = '1' then
              bus_busy <= '0';
          end if;
      end if;
    end process SetBusy ;


    i2cheader_reg_ctrl: process (reset, sys_clk) is       -- EASE/HDL sens.list

    begin

      if reset = RESET_ACTIVE then
          i2c_header_en <= '0';
      elsif sys_clk'event and sys_clk = '1' then
          if (detect_start = '1') or (state = HEADER) then
              i2c_header_en <= '1';
          else
              i2c_header_en <= '0';
          end if;
      end if;

    end process i2cheader_reg_ctrl ;


    i2cdata_reg_ctrl: process (reset, sys_clk) is     -- EASE/HDL sens.list
    begin

      if reset = RESET_ACTIVE then
          shift_reg_en <= '0';
          shift_reg_ld <= '0';
      elsif sys_clk'event and sys_clk = '1' then

          if ((master_slave = '1' and state = HEADER)
              or (state = RCV_DATA) or (state = XMIT_DATA)) then
              shift_reg_en <= '1';
          else
              shift_reg_en <= '0';
          end if;

          if ((master_slave = '1' and state = IDLE) or (state = WAIT_ACK)
               or (state = ACK_HEADER and i2c_header(0) = '1' and master_slave = '0')
           or (state = ACK_HEADER and mtx = '1' and master_slave = '1')
           or (detect_start = '1')  ) then
                  shift_reg_ld <= '1';
          else
                  shift_reg_ld <= '0';
          end if;
      end if;

    end process i2cdata_reg_ctrl ;


    mcf_bit: process (reset, scl) is      -- EASE/HDL sens.list
    begin

      if reset = RESET_ACTIVE then
          mcf <= '0';
      elsif scl'event and scl = '0' then
          if bit_cnt = CNT_DONE then
              mcf <= '1';
          else
              mcf <= '0';
          end if;
      end if;

    end process mcf_bit ;


    maas_bit: process (reset, sys_clk) is     -- EASE/HDL sens.list
    begin

      if reset = RESET_ACTIVE  then
          maas <= '0';
      elsif sys_clk'event and sys_clk = '1' then
          if mbcr_wr = '1' then
              maas <= '0';
          elsif state = ACK_HEADER then
              maas <= addr_match; -- the signal address match compares MADR with I2_ADDR
          end if;
      end if;

    end process maas_bit ;


    mal_bit: process (reset, sys_clk) is      -- EASE/HDL sens.list
    begin
      if reset = RESET_ACTIVE then
          mal <= '0';
      elsif (sys_clk'event and sys_clk = '1') then
          if mal_bit_reset = '1' then
              mal <= '0';
          elsif master_slave = '1' then
              if  (arb_lost = '1') or
                  (bus_busy_d1 = '1' and gen_start = '1') or
                  (detect_stop = '1' and gen_stop = '0' and sm_stop = '0') then
                      mal <= '1';
              end if;
          elsif rsta = '1' then
              -- repeated start requested while slave
              mal <= '1';
          end if;
      end if;
    end process mal_bit ;


    srw_bit: process (reset, sys_clk) is      -- EASE/HDL sens.list
    begin

      if reset = RESET_ACTIVE then
          srw <= '0';
      elsif sys_clk'event and sys_clk = '1' then
          if state = ACK_HEADER then
              srw <= i2c_header(0);
          end if;
      end if;

    end process srw_bit ;


    rxak_bit: process (scl) is        -- EASE/HDL sens.list
    begin
      if scl'event and scl = '0' then

          if state = ACK_HEADER or state = ACK_DATA or state = WAIT_ACK then
              rxak <= sda_in;
          end if;
      end if;

    end process rxak_bit ;


    ResetOrStop <= '1' when reset = RESET_ACTIVE or detect_stop = '1' else '0';


    -- MIF - M-bus Interrupt
    -- The MIF bit is set when an interrupt is pending, which causes a processor interrupt
    -- request provided MIEN is set. MIF is set when:
    --    1. Byte transfer is complete (set at the falling edge of the 9th clock
    --    2. MAAS is set when in slave receive mode
    --    3. Arbitration is lost
    -- This bit is cleared by reset and software writting a '0'to it


    mif_bit: process (reset, sys_clk) is      -- EASE/HDL sens.list
    begin

      if reset = RESET_ACTIVE then
          mif <= '0';
      elsif sys_clk'event and sys_clk = '1' then
          if mif_bit_reset = '1' then
              mif <= '0';
          elsif mal = '1' or mcf = '1' or
              (maas = '1' and i2c_header(0) = '0' and master_slave = '0') then
              mif <= '1';
          end if;
      end if;

    end process mif_bit ;


    mbdr_i2c_proc: process (reset, sys_clk) is        -- EASE/HDL sens.list
    begin

      if reset = RESET_ACTIVE then
          mbdr_i2c <= (others => '0');
      elsif sys_clk'event and sys_clk = '1' then
          if (state = ACK_DATA) or (state = WAIT_ACK) then
              mbdr_i2c <= shift_reg ;
          end if;
      end if;

    end process mbdr_i2c_proc ;


    slv_mas_sda: process (reset, sys_clk) is      -- EASE/HDL sens.list
    begin
      if reset = RESET_ACTIVE then
          master_sda <= '1';
          slave_sda <= '1';
      elsif sys_clk'event and sys_clk = '1' then
          if state = HEADER or state = XMIT_DATA then
              master_sda <= shift_out;
          elsif state = ACK_DATA then
              master_sda <= txak;--TXAK;
          else
              master_sda <= '1';
          end if;

          -- For the slave SDA, address match (MAAS) only has to be checked when
          -- state is ACK_HEADER because state
          -- machine will never get to state XMIT_DATA or ACK_DATA
          -- unless address match is a one.

          if (maas = '1' and state = ACK_HEADER) or
             (state = ACK_DATA) then
              slave_sda <= TXAK;
          elsif (state = XMIT_DATA) then
              slave_sda <= shift_out;
          else
              slave_sda <= '1';
          end if;
      end if;
    end process slv_mas_sda ;

    addr_match <= '1' when i2c_header(7 downto 1) = madr(7 downto 1)
              else '0';
    rep_start <= rsta;

    scl_generator_regs: process (reset, sys_clk) is       -- EASE/HDL sens.list
    begin
      if reset = RESET_ACTIVE then
          sda_out_reg <= '1';
          scl_out_reg <= '1';
          stop_scl_reg <= '0';
      elsif (rising_edge(sys_clk)) then
          sda_out_reg <= sda_out;
          scl_out_reg <= scl_out;
          stop_scl_reg <= stop_scl;
      end if;
    end process scl_generator_regs ;
  end architecture a0 ; -- of i2c_Control


