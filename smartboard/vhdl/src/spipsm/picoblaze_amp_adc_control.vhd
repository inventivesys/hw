--
-- KCPSM3 reference design - PicoBlaze controlling the two channel programmable 
-- amplifier type LTC6912-1 and two channel A/D converter type LTC1407A-1 from 
-- Linear Technology.
--
-- Design provided and tested on the Spartan-3E Starter Kit (Revision C)
--
-- Ken Chapman - Xilinx Ltd - 15th November 2005
--
-- The JTAG loader utility is also available for rapid program development.
--
-- The design is set up for a 50MHz system clock.
-- Measurements from the VINA input are amplified and displayed on the LCD display.
-- North and South press buttons are used to change the amplifier gain.
-- One measurement is made every second.
--
-- The simple LEDs and J4 connector are utilised for development and monitoring.
-- The switches and remaining press buttons are connected just for fun!
--  
------------------------------------------------------------------------------------
--
-- NOTICE:
--
-- Copyright Xilinx, Inc. 2005.   This code may be contain portions patented by other 
-- third parties.  By providing this core as one possible implementation of a standard,
-- Xilinx is making no representation that the provided implementation of this standard 
-- is free from any claims of infringement by any third party.  Xilinx expressly 
-- disclaims any warranty with respect to the adequacy of the implementation, including 
-- but not limited to any warranty or representation that the implementation is free 
-- from claims of any third party.  Furthermore, Xilinx is providing this core as a 
-- courtesy to you and suggests that you contact all third parties to obtain the 
-- necessary rights to use this implementation.
--
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
entity picoblaze_amp_adc_control is
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
                 simple_io : out std_logic_vector(12 downto 9);
                       led : out std_logic_vector(7 downto 0);
                    switch : in std_logic_vector(3 downto 0);
                 btn_north : in std_logic;
                  btn_east : in std_logic;
                 btn_south : in std_logic;
                  btn_west : in std_logic;
                     lcd_d : inout std_logic_vector(7 downto 4);
                    lcd_rs : out std_logic;
                    lcd_rw : out std_logic;
                     lcd_e : out std_logic;
                       clk : in std_logic);
    end picoblaze_amp_adc_control;
--
------------------------------------------------------------------------------------
--
-- Start of test architecture
--
architecture Behavioral of picoblaze_amp_adc_control is
--
------------------------------------------------------------------------------------

--
-- declaration of KCPSM3
--
  component kcpsm3 
    Port (      address : out std_logic_vector(9 downto 0);
            instruction : in std_logic_vector(17 downto 0);
                port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
          interrupt_ack : out std_logic;
                  reset : in std_logic;
                    clk : in std_logic);
    end component;
--
-- declaration of program ROM
--
  component adc_ctrl
    Port (      address : in std_logic_vector(9 downto 0);
            instruction : out std_logic_vector(17 downto 0);
             proc_reset : out std_logic;                       --JTAG Loader version
                    clk : in std_logic);
    end component;
--
------------------------------------------------------------------------------------
--
-- Signals used to connect KCPSM3 to program ROM and I/O logic
--
signal address          : std_logic_vector(9 downto 0);
signal instruction      : std_logic_vector(17 downto 0);
signal port_id          : std_logic_vector(7 downto 0);
signal out_port         : std_logic_vector(7 downto 0);
signal in_port          : std_logic_vector(7 downto 0);
signal write_strobe     : std_logic;
signal read_strobe      : std_logic;
signal interrupt        : std_logic :='0';
signal interrupt_ack    : std_logic;
signal kcpsm3_reset     : std_logic;
--
--
-- Signals used to generate interrupt 
--
signal int_count        : integer range 0 to 49999999 :=0;
signal event_1hz        : std_logic;
--
--
-- Signals for LCD operation
--
-- Tri-state output requires internal signals
-- 'lcd_drive' is used to differentiate between LCD and StrataFLASH communications 
-- which share the same data bits.
--
signal   lcd_rw_control : std_logic;
signal  lcd_output_data : std_logic_vector(7 downto 4);
signal        lcd_drive : std_logic;
--
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
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 and the program memory 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  processor: kcpsm3
    port map(      address => address,
               instruction => instruction,
                   port_id => port_id,
              write_strobe => write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     reset => kcpsm3_reset,
                       clk => clk);
 
  program_rom: adc_ctrl
    port map(      address => address,
               instruction => instruction,
                proc_reset => kcpsm3_reset,
                       clk => clk);

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

  interrupt_control: process(clk)
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
      if interrupt_ack='1' then
         interrupt <= '0';
        elsif event_1hz='1' then
         interrupt <= '1';
        else
         interrupt <= interrupt;
      end if;

    end if; 
  end process interrupt_control;

  simple_io(12) <= interrupt;  --Test point

  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 input ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --
  -- The inputs connect via a pipelined multiplexer
  --

  input_ports: process(clk)
  begin
    if clk'event and clk='1' then

      case port_id(1 downto 0) is

        -- read simple toggle switches and buttons at address 00 hex
        when "00" =>    in_port <= switch & btn_west & btn_south & btn_east & btn_north;

        -- read SPI data input SDO at address 01 hex
        -- called SDO because it connects to the data outputs of all the slave devices 
        -- Normal SDO data is bit7. 
        -- SDI data from the amplifier is at bit 6 because it is always driving and needs a separate pin.
        when "01" =>    in_port <= spi_sdo & spi_amp_sdo & "000000";

        -- read LCD data at address 02 hex
        when "10" =>    in_port <= lcd_d & "0000";

        -- Don't care used for all other addresses to ensure minimum logic implementation
        when others =>    in_port <= "XXXXXXXX";  

      end case;

     end if;

  end process input_ports;


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 output ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  -- adding the output registers to the processor
   
  output_ports: process(clk)
  begin

    if clk'event and clk='1' then
      if write_strobe='1' then

        -- Write to LEDs at address 80 hex.

        if port_id(7)='1' then
          led <= out_port;
        end if;

        -- Write to SPI data output at address 04 hex.
        -- called SDI because it connects to the data inputs of all the slave devices

        if port_id(2)='1' then
          spi_sdi <= out_port(7);
        end if;

        -- Write to SPI control at address 08 hex.

        if port_id(3)='1' then
          spi_sck <= out_port(0);
          spi_rom_cs <= out_port(1);
        --spare control <= out_port(2);
          spi_amp_cs <= out_port(3);
          spi_adc_conv <= out_port(4);
          spi_dac_cs <= out_port(5);
          spi_amp_shdn <= out_port(6);
          spi_dac_clr <= out_port(7);

          simple_io(10) <= out_port(3);  --Test point is copy of amp_cs
          simple_io(11) <= out_port(4);  --Test point is copy of adc_conv

        end if;

        -- LCD data output and controls at address 40 hex.

        if port_id(6)='1' then
          lcd_output_data <= out_port(7 downto 4);
          lcd_drive <= out_port(3);  
          lcd_rs <= out_port(2);
          lcd_rw_control <= out_port(1);
          lcd_e <= out_port(0);
        end if;

      end if;

    end if; 

  end process output_ports;

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
-- END OF FILE picoblaze_amp_adc_control.vhd
--
------------------------------------------------------------------------------------------------------------------------------------

