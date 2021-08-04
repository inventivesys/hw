------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- Smart Board Controller 
-- for Spartan-3E Board
--	
-- Author: John Qin 
-- History:
--   01/03/07 - created by jq
-- This file instantiates the processor macro and program ROM.
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--
-- Library declarations
--
-- Standard IEEE libraries
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
------------------------------------------------------------------------------------
--
--
entity smartbrd is
    Port (         spi_sck : out std_logic;
                   spi_sdo : in std_logic;
                   spi_sdi : out std_logic;
                spi_rom_cs : out std_logic;
                spi_amp_cs : out std_logic;
              spi_adc_conv : out std_logic;
                spi_dac_cs : out std_logic;
              spi_amp_shdn : out std_logic;
               spi_amp_sdo : in std_logic;
               spi_dac_clr : out std_logic;
            strataflash_oe : out std_logic;
            strataflash_ce : out std_logic;
            strataflash_we : out std_logic;
          platformflash_oe : out std_logic;
                 simple_io : out std_logic_vector (12 downto 9);
                       led : out std_logic_vector (7 downto 0);
                    switch : in std_logic_vector (3 downto 0);
                 btn_north : in std_logic;
                  btn_east : in std_logic;
                 btn_south : in std_logic;
                  btn_west : in std_logic;
                     lcd_d : inout std_logic_vector (7 downto 4);
                    lcd_rs : out std_logic;
                    lcd_rw : out std_logic;
                     lcd_e : out std_logic;						 
							  txd : out std_logic;							  
					        rxd : in std_logic;							
                       clk : in std_logic);
    end smartbrd;
--
------------------------------------------------------------------------------------
--
-- Start of smartbrd architecture
--
architecture Behavioral of smartbrd is
--
-- for simulation
-- CONSTANT BAUD9600 : integer := 4; -- for 9600 at 48MHz
-- on board
CONSTANT BAUD9600 : integer := 312; -- for 9600 at 50MHz
--
CONSTANT INTCNT : integer := 49999999; -- 49, 99 to provide for 1uS interrupts at 50MHz
--
CONSTANT PWM_PERIOD : integer :=400;

------------------------------------------------------------------------------------

--
-- declaration of uP
--
  component uP 
    Port (      address : out std_logic_vector (9 downto 0);
            instruction : in std_logic_vector (17 downto 0);
                port_id : out std_logic_vector (7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector (7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector (7 downto 0);
              interrupt : in std_logic;
          interrupt_ack : out std_logic;
                  reset : in std_logic;
                    clk : in std_logic);
    end component;
--
-- declaration of adc_ctrl
--
  component adc_ctrl
    Port (      address : in std_logic_vector (9 downto 0);
            instruction : out std_logic_vector (17 downto 0);
             --proc_reset : out std_logic;                       --JTAG Loader version
                    clk : in std_logic);
    end component;
--
-- declaration of io_ctrl
--
  component io_ctrl
    Port (      address : in std_logic_vector (9 downto 0);
            instruction : out std_logic_vector (17 downto 0);
          --check_address : in std_logic_vector (10 downto 0);   
             --check_data : out std_logic_vector (8 downto 0);
                    clk : in std_logic);
    end component;
--
--
-- declaration of UART transmitter with integral 16 byte FIFO buffer
--
  component uart_tx
    Port (            data_in : in std_logic_vector (7 downto 0);
                 write_buffer : in std_logic;
                 reset_buffer : in std_logic;
                 en_16_x_baud : in std_logic;
                   serial_out : out std_logic;
                  buffer_full : out std_logic;
             buffer_half_full : out std_logic;
                          clk : in std_logic);
    end component; --uart_tx

--
-- declaration of UART Receiver with integral 16 byte FIFO buffer
--
  component uart_rx
    Port (            serial_in : in std_logic;
                       data_out : out std_logic_vector (7 downto 0);
                    read_buffer : in std_logic;
                   reset_buffer : in std_logic;
                   en_16_x_baud : in std_logic;
            buffer_data_present : out std_logic;
                    buffer_full : out std_logic;
               buffer_half_full : out std_logic;
                            clk : in std_logic);
  end component; -- uart_rx

--
-- declaration of 'Bucket Brigade' 16-byte FIFO Buffer 
--
component bbfifo_16x8 
    Port (       data_in : in std_logic_vector (7 downto 0);
                data_out : out std_logic_vector (7 downto 0);
                   reset : in std_logic;               
                   write : in std_logic; 
                    read : in std_logic;
                    full : out std_logic;
               half_full : out std_logic;
            data_present : out std_logic;
                     clk : in std_logic);
    end component;

--
-- declaration of SPI master
--
  component spi_interface
      Port (        clk	 : in std_logic; 
                 clkdiv	 : in std_logic_vector (1 downto 0); 
                   cpha	 : in std_logic; 
                   cpol	 : in std_logic; 
                   miso	 : in std_logic; 
               rcv_cpol	 : in std_logic; 
         rcv_full_reset	 : in std_logic; 
                  reset	 : in std_logic; 
                ss_in_n	 : in std_logic; 
            ss_mask_reg	 : in std_logic_vector(7 downto 0); 
                  start  : in std_logic; 
              xmit_data	 : in std_logic_vector (7 downto 0); 
       xmit_empty_reset	 : in std_logic; 
               rcv_load	 : inout std_logic; 
                    sck	 : inout std_logic; 
              ss_in_int	 : inout std_logic; 
               ss_n_int	 : inout std_logic; 
             xmit_empty	 : inout std_logic; 
                   done	 : out std_logic; 
                   mosi	 : out std_logic; 
               rcv_data	 : out std_logic_vector (7 downto 0); 
               rcv_full	 : out std_logic; 
                   ss_n	 : out std_logic_vector (7 downto 0));

  end component; -- spi_interface
--
-- declaration of I2C interface
--
component i2c_control 
  port(
	-- I2C bus signals
		sda : inout std_logic;
      scl : inout std_logic;
	
	-- interface signals from uP interface
		txak		: in		std_logic;	-- value for acknowledge when xmit
		msta		: in		std_logic; 	-- master/slave select
		msta_rst	: out		std_logic;	-- resets MSTA bit if arbitration is lost
		rsta		: in		std_logic;	-- repeated start 
		mtx		: in		std_logic;	-- master read/write 
	mbdr_micro	: in		std_logic_vector(7 downto 0);	-- uP data to output on I2C bus
		madr		: in		std_logic_vector(7 downto 0); -- I2C slave address
		mbb		: out		std_logic;	-- bus busy
		mcf		: inout	std_logic;	-- data transfer
		maas		: inout	std_logic;	-- addressed as slave
		mal		: inout	std_logic;	-- arbitration lost
		srw		: inout	std_logic;	-- slave read/write
		mif		: out		std_logic; 	-- interrupt pending
		rxak		: out		std_logic;	-- received acknowledge
		mbdr_i2c	: inout	std_logic_vector(7 downto 0); -- I2C data for uP
		mbcr_wr	: in	std_logic;	-- indicates that MCBR register was written
 mif_bit_reset : in	std_logic;	-- indicates that the MIF bit should be reset
 mal_bit_reset : in	std_logic;	-- indicates that the MAL bit should be reset
   
		 sys_clk : in std_logic;
			reset : in std_logic);
			
  end component; -- i2c_control
--
------------------------------------------------------------------------------------
--
-- Signals 
--
--
-- Signals for adc_ctrl
--
signal adc_ctrl_address         : std_logic_vector (9 downto 0);
signal adc_ctrl_instruction     : std_logic_vector (17 downto 0);
signal adc_ctrl_port_id         : std_logic_vector (7 downto 0);
signal adc_ctrl_out_port        : std_logic_vector (7 downto 0);
signal adc_ctrl_in_port         : std_logic_vector (7 downto 0);
signal adc_ctrl_write_strobe    : std_logic;
signal adc_ctrl_read_strobe     : std_logic;
signal adc_ctrl_interrupt       : std_logic :='0';
signal adc_ctrl_interrupt_ack   : std_logic;
signal adc_ctrl_kcpsm3_reset    : std_logic;
--
--
-- Signals for io_ctrl
--
signal io_ctrl_address          : std_logic_vector (9 downto 0);
signal io_ctrl_instruction      : std_logic_vector (17 downto 0);
signal io_ctrl_port_id          : std_logic_vector (7 downto 0);
signal io_ctrl_out_port         : std_logic_vector (7 downto 0);
signal io_ctrl_in_port          : std_logic_vector (7 downto 0);
signal io_ctrl_write_strobe     : std_logic;
signal io_ctrl_read_strobe      : std_logic;
signal io_ctrl_interrupt        : std_logic :='0';
signal io_ctrl_interrupt_ack    : std_logic;
signal io_ctrl_kcpsm3_reset     : std_logic;
--
-- Signals for fifo
--
signal link_fifo_data           : std_logic_vector (7 downto 0);
signal read_link_fifo           : std_logic;
signal reset_link_fifo          : std_logic;
signal link_fifo_buffer_full    : std_logic;
signal link_fifo_half_full      : std_logic;
signal link_fifo_data_present   : std_logic;
signal write_link_fifo          : std_logic;    
--
-- Signals used to generate interrupt 
--
signal int_count			    : integer range 0 to 49999999 :=0;
signal event_1hz                : std_logic;
signal io_int_count			    : integer range 0 to 49999999 :=0;
signal io_event_1hz                : std_logic;
--
--   Signals for safety control
--   includes main clock which can also be disabled to bring entire device to a halt.
--
-- signal clk						   : std_logic;
signal safety_disable_interrupts : std_logic :='0';
signal safety_disable_outputs    : std_logic :='0';
signal safety_disable_clock      : std_logic :='0';
signal safety_data               : std_logic_vector(8 downto 0);
signal safety_address            : std_logic_vector(10 downto 0) :="00000000000";
--
-- Signals for LCD operation
--
-- Tri-state output requires internal signals
-- 'lcd_drive' is used to differentiate between LCD and StrataFLASH communications 
-- which share the same data bits.
--
signal   lcd_rw_control          : std_logic;
signal  lcd_output_data          : std_logic_vector (7 downto 4);
signal        lcd_drive          : std_logic;
--
--
-- Signals for peripherals
--
signal uart_status_port          : std_logic_vector (7 downto 0);
signal valve_io				     : std_logic_vector (7 downto 0);
--
-- Signals to form an timer generating an interrupt every microsecond
--
signal timer_count   : integer range 0 to 49999999 := 0; --255 :=0;
signal timer_pulse   : std_logic;
--
-- Signals for UART connections
--
signal       write_to_uart		: std_logic;
signal             tx_full		: std_logic;
signal        tx_half_full		: std_logic;
signal      read_from_uart		: std_logic;
signal             rx_data		: std_logic_vector(7 downto 0);
signal     rx_data_present		: std_logic;
signal             rx_full		: std_logic;
signal        rx_half_full		: std_logic;
signal			  tx_write		: std_logic;
signal				tx_out		: std_logic;
signal			   tx_data		: std_logic_vector (7 downto 0 );
--
--	Signals for Baud Rate generators
--
signal     baud_9600_count    : integer range 0 to 500 :=0;
signal	 en_9600_16_x_baud   : std_logic;
--
--	signals for SPI
--
  -- SPI bus signals
signal     sck_io		: std_logic;   -- SPI clock, not connected
signal    miso_io		: std_logic;   --	data in, slave to master, not connected
signal    mosi_io	   : std_logic;   -- data out, master to slave, not connected
  -- signals to/from uP
signal     clkdiv		: std_logic_vector (1 downto 0); -- clock divider
                                                                 -- 00: 1/4
													             -- 01: 1/8
													             -- 10: 1/16
													             -- 11: 1/32
signal    	cpha	   : std_logic;   -- clock phase bit, 0: 1st edge; 1: 2nd edge
signal       cpol	 	: std_logic;   --	clock polarity bit, 0:high; 1:low
signal 	rcv_cpol    : std_logic;   -- receive polarity bit
signal rcv_full_reset: std_logic;   -- receive register full	reset
signal      spien		: std_logic;
signal    ss_in_n		: std_logic;   -- slave select input
signal ss_mask_reg   : std_logic_vector (7 downto 0); 
signal    start		: std_logic;  -- start
signal  xmit_data	   : std_logic_vector (7 downto 0); 
signal xmit_empty_reset	: std_logic; 
signal      done		: std_logic; 
signal   rcv_data	   : std_logic_vector (7 downto 0); 
signal   rcv_full	   : std_logic; 
signal      ss_n		: std_logic_vector (7 downto 0); 
signal   rcv_load	   : std_logic; 
signal  ss_in_int	   : std_logic; 
signal   ss_n_int	   : std_logic; 
signal xmit_empty	   : std_logic; 
signal     spissr		: std_logic_vector (7 downto 0);
signal      spitr		: std_logic_vector (7 downto 0);
--
-- signals for i2c
--
	-- I2C bus signals 
signal	sda_io        : std_logic;   -- not connected
signal   scl_io        : std_logic;   -- not connected
	-- signals to/from uP 
signal   sys_clk       : std_logic;	
signal   men			  : std_logic;	-- i2c enable - used as i2c reset
signal	txak	        : std_logic;	-- value for acknowledge when xmit
signal	msta	        : std_logic; 	-- master/slave select
signal	msta_rst	     : std_logic;	-- resets MSTA bit if arbitration is lost
signal	rsta		     : std_logic;	-- repeated start 
signal	mtx		     : std_logic;	-- master read/write 
signal	mbdr_micro	  : std_logic_vector(7 downto 0);	-- uP data to output on I2C bus
signal	madr		     : std_logic_vector(7 downto 0); -- I2C slave address
signal	mbb		     : std_logic;	-- bus busy
signal	mcf		     : std_logic;	-- data transfer
signal   maas		     : std_logic;	-- addressed as slave
signal   mal		     : std_logic;	-- arbitration lost
signal	srw		     : std_logic;	-- slave read/write
signal	mif	        : std_logic; 	-- interrupt pending
signal	rxak		     : std_logic;	-- received acknowledge
signal   mbdr_i2c      : std_logic_vector(7 downto 0); -- I2C data for uP
signal	mbcr_wr	     : std_logic;	-- indicates that MCBR register was written
signal	mif_bit_reset : std_logic;	-- indicates that the MIF bit should be reset
signal	mal_bit_reset : std_logic;	-- indicates that the MAL bit should be reset
--
--	signals for PWM
--
  -- pwm i/o signal
signal		   	  pwm_io    :  std_logic_vector (3 downto 0); --not connected
  -- signals to/from uP
signal              pwm_count :  std_logic_vector (7 downto 0);
signal				  pwm_duty0 :  std_logic_vector (7 downto 0);
signal				  pwm_duty1 :  std_logic_vector (7 downto 0);
signal				  pwm_duty2 :  std_logic_vector (7 downto 0);
signal				  pwm_duty3 :  std_logic_vector (7 downto 0);


------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Start of circuit description
--
begin
  --
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Disable unused components  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --StrataFLASH must be disabled to prevent it driving the SDI line with its D0 output
  --or conflicting with the LCD display 
  --
  strataflash_oe <= '1';
  strataflash_ce <= '1';
  strataflash_we <= '1';
  --
  --Platform FLASH must be disabled to prevent it driving the SDI line with its D0 output.
  --Since the CE is via the 9500 device, the OE/RESET is the easier direct control (OE active high).
  --
  platformflash_oe <= '0';
  --
  --
  --
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Safety check and turn on alrm and turn off the power if necessary  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --led(0) <= '1' when (safety_disable_outputs='1') else 'Z';
  --
  --
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- adc_ctrl uP and the program memory 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  adc_ctrl_processor: uP
    port map(      address => adc_ctrl_address,
               instruction => adc_ctrl_instruction,
                   port_id => adc_ctrl_port_id,
              write_strobe => adc_ctrl_write_strobe,
                  out_port => adc_ctrl_out_port,
               read_strobe => adc_ctrl_read_strobe,
                   in_port => adc_ctrl_in_port,
                 interrupt => adc_ctrl_interrupt,
             interrupt_ack => adc_ctrl_interrupt_ack,
                     reset => adc_ctrl_kcpsm3_reset, 
                       clk => clk);
 
  adc_ctrl_program_rom: adc_ctrl
    port map(      address => adc_ctrl_address,
               instruction => adc_ctrl_instruction,
              --proc_reset => adc_ctrl_kcpsm3_reset, --Used in JTAG_loader version
                       clk => clk);

  adc_ctrl_kcpsm3_reset <= '0';	--For normal processor memory
  --
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Interrupt 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --
  -- Interrupt is used to set the 1 second sample rate which is typical of environment monitoring 
  -- applications. 
  --
  -- A simple binary counter is used to divide the 50MHz system clock and provide interrupt pulses.
  --

  adc_interrupt_control: process(clk)
  begin
    if clk'event and clk='1' then

      --divide 50MHz by 50,000,0000 to form 1Hz pulses
      if int_count=49999999 then
         int_count <= 0;
         event_1hz <= '1';
       else
         int_count <= int_count + 1;
         event_1hz <= '0';
      end if;

      -- processor interrupt waits for an acknowledgement
      if adc_ctrl_interrupt_ack='1' then
         adc_ctrl_interrupt <= '0';
        elsif event_1hz='1' then
         adc_ctrl_interrupt <= '1';
        else
         adc_ctrl_interrupt <= adc_ctrl_interrupt;
      end if;

    end if; 
  end process adc_interrupt_control;

  simple_io(12) <= adc_ctrl_interrupt;  --Test point



  io_interrupt_control: process(clk)
  begin
    if clk'event and clk='1' then

      --divide 50MHz by 50,000,0000 to form 1Hz pulses
      if io_int_count=49999999 then
         io_int_count <= 0;
         io_event_1hz <= '1';
       else
         io_int_count <= int_count + 1;
         io_event_1hz <= '0';
      end if;

      -- processor interrupt waits for an acknowledgement
      if io_ctrl_interrupt_ack='1' then
         io_ctrl_interrupt <= '0';
        elsif event_1hz='1' then
         io_ctrl_interrupt <= '1';
        else
         io_ctrl_interrupt <= io_ctrl_interrupt;
      end if;

    end if; 
  end process io_interrupt_control;

  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- adc_ctrl input ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --
  -- The inputs connect via a pipelined multiplexer
  --

  adc_ctrl_input_ports: process(clk)
  begin
    if clk'event and clk='1' then

      case adc_ctrl_port_id(3 downto 0) is

        -- read simple toggle switches and buttons at address 00 hex
        when "0000" =>    adc_ctrl_in_port <= switch & btn_west & btn_south & btn_east & btn_north;

        -- read SPI data input SDO at address 01 hex
        -- called SDO because it connects to the data outputs of all the slave devices 
        -- Normal SDO data is bit7. 
        -- SDI data from the amplifier is at bit 6 because it is always driving and needs a separate pin.
        when "0001" =>    adc_ctrl_in_port <= spi_sdo & spi_amp_sdo & "000000";

        -- read LCD data at address 02 hex
        when "0010" =>    adc_ctrl_in_port <= lcd_d & "0000";
		  
        -- read UART status at address 04 hex
        when "0100" =>    adc_ctrl_in_port <= uart_status_port;

        -- read UART receive data at address 06 hex
        when "0110" =>    adc_ctrl_in_port <= rx_data;		  

        -- Don't care used for all other addresses to ensure minimum logic implementation
        when others =>    adc_ctrl_in_port <= "XXXXXXXX";  

      end case;

     end if;

  end process adc_ctrl_input_ports;

  -- UART FIFO status signals to form a bus
  -- 
  uart_status_port <= "000" & rx_full & rx_half_full & rx_data_present & tx_full & tx_half_full;

  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- adc_ctrl output ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
   
  adc_ctrl_output_ports: process(clk)
  begin

    if clk'event and clk='1' then
      if adc_ctrl_write_strobe='1' then

        -- Write to LEDs at address 80 hex.

        if adc_ctrl_port_id(7)='1' then
          led <= adc_ctrl_out_port;
        end if;

        -- Write to SPI data output at address 04 hex.
        -- called SDI because it connects to the data inputs of all the slave devices

        if adc_ctrl_port_id(2)='1' then
          spi_sdi <= adc_ctrl_out_port(7);
        end if;

        -- Write to SPI control at address 08 hex.

        if adc_ctrl_port_id(3)='1' then
          spi_sck <= adc_ctrl_out_port(0);
          spi_rom_cs <= adc_ctrl_out_port(1);
          --spare control <= out_port(2);
          spi_amp_cs <= adc_ctrl_out_port(3);
          spi_adc_conv <= adc_ctrl_out_port(4);
          spi_dac_cs <= adc_ctrl_out_port(5);
          spi_amp_shdn <= adc_ctrl_out_port(6);
          spi_dac_clr <= adc_ctrl_out_port(7);

          simple_io(10) <= adc_ctrl_out_port(3);  --Test point is copy of amp_cs
          simple_io(11) <= adc_ctrl_out_port(4);  --Test point is copy of adc_conv

        end if;

        -- LCD data output and controls at address 40 hex.

        if adc_ctrl_port_id(6)='1' then
          lcd_output_data <= adc_ctrl_out_port(7 downto 4);
          lcd_drive <= adc_ctrl_out_port(3);  
          lcd_rs <= adc_ctrl_out_port(2);
          lcd_rw_control <= adc_ctrl_out_port(1);
          lcd_e <= adc_ctrl_out_port(0);
        end if;

      end if;

    end if; 

  end process adc_ctrl_output_ports;

  --
  -- write to UART transmitter FIFO buffer at address 01 hex.
  -- This is a combinatorial decode because the FIFO is the 'port register'.
  --
  write_to_uart <= adc_ctrl_write_strobe and adc_ctrl_port_id(0);	-- address 01
  --
  -- write to link FIFO buffer at address 10 hex.
  -- This is a combinatorial decode because the FIFO is the 'port register'.
  --
  write_link_fifo <= '1' when (adc_ctrl_write_strobe='1' and adc_ctrl_port_id(4)='1') else '0';


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- FIFO buffer for IPC  
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  link_fifo: bbfifo_16x8 
  port map (       data_in => adc_ctrl_out_port,
                  data_out => link_fifo_data,
                     reset => reset_link_fifo,              
                     write => write_link_fifo,
                      read => read_link_fifo,
                      full => link_fifo_buffer_full,
                 half_full => link_fifo_half_full,
              data_present => link_fifo_data_present,
                       clk => clk);
  
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- io_ctrl uP and program memory 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  io_ctrl_processor: uP
    port map(      address => io_ctrl_address,
               instruction => io_ctrl_instruction,
                   port_id => io_ctrl_port_id,
              write_strobe => io_ctrl_write_strobe,
                  out_port => io_ctrl_out_port,
               read_strobe => io_ctrl_read_strobe,
                   in_port => io_ctrl_in_port,
                 interrupt => io_ctrl_interrupt,        --interrupt signal generated by application processor
             interrupt_ack => io_ctrl_interrupt_ack,
                     reset => io_ctrl_kcpsm3_reset,
                       clk => clk);

  io_ctrl_kcpsm3_reset <= '0';  


  io_ctrl_program_rom: io_ctrl
    port map(      address => io_ctrl_address,
               instruction => io_ctrl_instruction,
             --check_address => safety_address,       --additional access port for content verification
                --check_data => safety_data,
                       clk => clk);
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- io_ctrl input ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --
  -- The inputs connect via a pipelined multiplexer
  --

  io_ctrl_input_ports: process(clk)
  begin
    if clk'event and clk='1' then

      case io_ctrl_port_id(3 downto 0) is

        -- read simple toggle switches and buttons at address 00 hex
        when "0000" =>    io_ctrl_in_port <= switch & btn_west & btn_south & btn_east & btn_north;

        -- read LCD data at address 01 hex
        when "0001" =>    io_ctrl_in_port <= lcd_d & "0000";

        -- read status of FIFO buffer link at 02 hex
        when "0010" =>    io_ctrl_in_port <= "00000" & link_fifo_buffer_full & link_fifo_half_full & link_fifo_data_present;		  

        -- read FIFO buffer link at 04 hex
        when "0100" =>    io_ctrl_in_port <= link_fifo_data;

        -- Don't care used for all other addresses to ensure minimum logic implementation
        when others =>    io_ctrl_in_port <= "XXXXXXXX";  

      end case;

     end if;

  end process io_ctrl_input_ports;

 --
 ----------------------------------------------------------------------------------------------------------------------------------
 -- io_ctrl output ports 
 ----------------------------------------------------------------------------------------------------------------------------------
 --
   
  io_ctrl_output_ports: process(clk)
  begin

    if clk'event and clk='1' then
      if io_ctrl_write_strobe='1' then


        -- Write to valve output at address 04 hex.

        if io_ctrl_port_id(2)='1' then
          valve_io <= io_ctrl_out_port;
        end if;

        -- safety signals at address 10 hex.

        if io_ctrl_port_id(4)='1' then
          safety_disable_interrupts <= io_ctrl_out_port(0);
          safety_disable_outputs <= io_ctrl_out_port(1);
        end if;

      end if;

    end if; 

  end process io_ctrl_output_ports;

  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- UARTS  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- Connect the 8-bit, 1 stop-bit, no parity transmit and receive macros.
  -- Each contains an embedded 16-byte FIFO buffer.
  --

  transmit: uart_tx 
  port map (            data_in => adc_ctrl_out_port, 
                   write_buffer => write_to_uart,
                   reset_buffer => '0',
                   en_16_x_baud => en_9600_16_x_baud,
                     serial_out => txd,
                    buffer_full => tx_full,
               buffer_half_full => tx_half_full,
                            clk => clk );

  receive: uart_rx
  port map (            serial_in => rxd,
                         data_out => rx_data,
                      read_buffer => read_from_uart,
                     reset_buffer => '1',
                     en_16_x_baud => en_9600_16_x_baud,
              buffer_data_present => rx_data_present,
                      buffer_full => rx_full,
                 buffer_half_full => rx_half_full,
                              clk => clk ); 
  --  
  ----------------------------------------------------------------------------------------------------------------------------------
  -- BAUD Rate Generators  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- Set baud rate for the UART communications
  -- Requires en_16_x_baud to be 614400Hz which is a single cycle pulse every 90 cycles at 55MHz 
  --   --
  -- NOTE : If the highest value for baud_count exceeds 127 you will need to adjust 
  --        the range of integers in the signal declaration for baud_count.
  --

  baud96_timer: process(clk)
  begin
    if clk'event and clk='1' then
      if baud_9600_count= BAUD9600 then				 
      	baud_9600_count <= 0;
         en_9600_16_x_baud <= '1';
       else
         baud_9600_count <= baud_9600_count + 1;
         en_9600_16_x_baud <= '0';
      end if;
    end if;
  end process baud96_timer;


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- SPI Interface  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --

   spi : spi_interface
   port map (	          clk => clk, 
		                clkdiv => clkdiv, 
      			         cpha => cpha, 
					         cpol => cpol, 
					         miso => miso_io, 
					     rcv_cpol => rcv_cpol,
              rcv_full_reset => rcv_full_reset, 
					        reset => spien, 
					      ss_in_n => ss_in_n,
                 ss_mask_reg => spissr,  
					        start => start,
                   xmit_data => spitr,  
            xmit_empty_reset => xmit_empty_reset, 
					     rcv_load => rcv_load, 
					          sck => sck_io,
                   ss_in_int => ss_in_int, 
					     ss_n_int => ss_n_int, 
				      xmit_empty => xmit_empty,
                        done => done, 
					         mosi => mosi_io, 
				        rcv_data => rcv_data, 
				        rcv_full => rcv_full, 
					         ss_n => ss_n );
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- I2C port
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --
  i2c_port : i2c_control

	port map (
			-- I2C bus signals
						sda => sda_io,
						scl => scl_io,
	
			-- interface signals from uP interface
				txak		=> txak,
				msta		=> msta,
				msta_rst	=> msta_rst,
				rsta		=> rsta,
				mtx		=> mtx,
			mbdr_micro	=> mbdr_micro,
				madr		=> madr,
				mbb		=> mbb,
				mcf		=> mcf,
				maas		=> maas,
				mal		=> mal,
				srw		=> srw,
				mif		=> mif,
				rxak		=> rxak,
				mbdr_i2c	=> mbdr_i2c,
				mbcr_wr	=> mbcr_wr,
		 mif_bit_reset => mif_bit_reset,
	  	 mal_bit_reset => mal_bit_reset,

				 sys_clk => clk,
			      reset => men 
		);

  
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- pwm ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --

 pwm_ports: process(clk)
  begin

    if clk'event and clk='1' then
      if io_ctrl_write_strobe='1' then
			-- use at address 0x02 and 0x04. If statement will use less logic than case
			if io_ctrl_port_id(1) = '0' and io_ctrl_port_id(2) = '0' then	
				pwm_duty0 <= io_ctrl_out_port;---std_logic_vector(unsigned(pwm_duty_reg)
			end if;
			if io_ctrl_port_id(1) = '1' and io_ctrl_port_id(2) = '0' then	
				pwm_duty1 <= io_ctrl_out_port;
			end if;

      end if;
    end if; 

  end process pwm_ports;

  --
  ----
  --
  --
  pwm_timer: process(clk)
  begin
    if clk'event and clk='1' then
      if pwm_count = "11111111" then				 
      	pwm_count <= "00000000";
			pwm_io(0) <= '0';
      else
         pwm_count <= pwm_count + '1';
         pwm_io(0) <= '0';
      end if;
		if pwm_count < pwm_duty0 then
		  pwm_io(0) <= '1';
      else
		  pwm_io(0) <= '0';
      end if;
    end if;
  end process pwm_timer;
  --
  --
 
  --
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- LCD interface  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- The 4-bit data port is bidirectional.
  -- lcd_rw is '1' for read and '0' for write 
  -- lcd_drive is like a master enable signal which prevents either the 
  -- FPGA outputs or the LCD display driving the data lines.
  --
  --Control of read and write signal
  lcd_rw <= lcd_rw_control and lcd_drive;

  --use read/write control to enable output buffers.
  lcd_d <= lcd_output_data when (lcd_rw_control='0' and lcd_drive='1') else "ZZZZ";

  ----------------------------------------------------------------------------------------------------------------------------------

  simple_io(9) <= spi_amp_sdo;   --Test point

end Behavioral;

------------------------------------------------------------------------------------------------------------------------------------
--
-- END OF FILE smartbrd.vhd
--
------------------------------------------------------------------------------------------------------------------------------------

