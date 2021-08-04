-- Picoblaze Controller 
--	for Spartan 3 Board
--	
--	John Qin 
-- 01/03/06
-- This file instantiates the KCPSM3 processor macro and connects the 
-- program ROM.
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
entity pico_processor is
    Port (
         reset 		: in std_logic;
         clk 			: in std_logic;
			txd			: out std_logic;
			rxd			: in std_logic;
			dip_sw		: in std_logic_vector(7 downto 0);
			leds			: out std_logic_vector(7 downto 0);
			segments		: out std_logic_vector(6 downto 0);	
			an				: out std_logic_vector(3 downto 0);
			pwm		   : out std_logic_vector(3 downto 0)
			);
    end pico_processor;
--
------------------------------------------------------------------------------------
--
-- Start of architecture
--
architecture Behavioral of pico_processor is
--
-- for simulation
--CONSTANT BAUD9600 : integer := 4; -- for 9600 at 48MHz
-- on board
CONSTANT BAUD9600 : integer := 313; -- for 9600 at 50MHz
--
CONSTANT INTCNT : integer := 99; -- 49, 99 to provide for 1uS interrupts at 50MHz
--
CONSTANT PWM_PERIOD : integer :=400;

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
    end component; --kcpsm3

--
-- declaration of program ROM
--
  component app_rom
    Port (      address : in std_logic_vector(9 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                    clk : in std_logic);
    end component; -- app_rom

--
-- declaration of UART transmitter with integral 16 byte FIFO buffer
--
  component uart_tx
    Port (            data_in : in std_logic_vector(7 downto 0);
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
                       data_out : out std_logic_vector(7 downto 0);
                    read_buffer : in std_logic;
                   reset_buffer : in std_logic;
                   en_16_x_baud : in std_logic;
            buffer_data_present : out std_logic;
                    buffer_full : out std_logic;
               buffer_half_full : out std_logic;
                            clk : in std_logic);
  end component; -- uart_rx



------------------------------------------------------------------------------------
--
-- Signals used to connect KCPSM3 to program ROM and I/O logic
--
signal address         : std_logic_vector(9 downto 0);
signal instruction     : std_logic_vector(17 downto 0);
signal port_id         : std_logic_vector(7 downto 0);
signal out_port        : std_logic_vector(7 downto 0);
signal in_port         : std_logic_vector(7 downto 0);
signal seg             : std_logic_vector(7 downto 0);
signal anode           : std_logic_vector(7 downto 0);
signal write_strobe    : std_logic;
signal read_strobe     : std_logic;
signal interrupt       : std_logic;
signal interrupt_ack   : std_logic;


--
-- Signals for connection of peripherals
--
signal uart_status_port : std_logic_vector(7 downto 0);

--
-- Signals to form an timer generating an interrupt every microsecond
--
signal timer_count   : integer range 0 to 255 :=0;
signal timer_pulse   : std_logic;

--
-- Signals for UART connections
--
signal       write_to_uart : std_logic;
signal             tx_full : std_logic;
signal        tx_half_full : std_logic;
signal      read_from_uart : std_logic;
signal             rx_data : std_logic_vector(7 downto 0);
signal     rx_data_present : std_logic;
signal             rx_full : std_logic;
signal        rx_half_full : std_logic;

--
--	Signals for Baud Rate generators
--
signal          baud_9600_count : integer range 0 to 500 :=0;
signal	       en_9600_16_x_baud 	: std_logic;

--
--	pwm signals
--
signal pwm_count :  std_logic_vector(7 downto 0);
signal pwm_duty0 :  std_logic_vector(7 downto 0);
signal pwm_duty1 :  std_logic_vector(7 downto 0);
signal pwm_duty2 :  std_logic_vector(7 downto 0);
signal pwm_duty3 :  std_logic_vector(7 downto 0);

signal pwm_period_reg : std_logic_vector(7 downto 0);


------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Start of circuit description
--
begin

	--an <= "1111";
	--segments <= "11111110";--ledreg;
   --interrupt <= '1';


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
                     reset => reset,
                       clk => clk);
 


  program_rom: app_rom
    port map(      address => address,
               instruction => instruction,
                       clk => clk);

  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Interrupt 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --
  -- Interrupt is a generated once every 100 clock cycles to provide a 1us reference. 
  -- Interrupt is automatically cleared by interrupt acknowledgment from KCPSM3.
  --
  --	

  Timer: process(clk)
  begin

    if clk'event and clk='1' then
      
      if timer_count = INTCNT then -- was 99
         timer_count <= 0;
         timer_pulse <= '1';
			--interrupt <= '1';
       else
         timer_count <= timer_count + 1;
         timer_pulse <= '0';
      end if;

      if interrupt_ack = '1' then
      --if timer_pulse = '0' then
		   --leds(0) <= '0';  -- debug
         interrupt <= '0';
      --end if;
       elsif timer_pulse = '1' then 
		--if timer_pulse = '1' then
		   --leds(0) <= '1'; --debug
         interrupt <= '1';
        else
         interrupt <= interrupt;
      end if;
     
    end if;
    
  end process Timer;

  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 input ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  
  
  --
  -- UART FIFO status signals to form a bus
  --
  uart_status_port <= "000" & rx_data_present & rx_full & rx_half_full & tx_full & tx_half_full ;
 
  --
  -- The inputs connect via a pipelined multiplexer
  --
 
  input_ports: process(clk)
  begin
    if clk'event and clk='1' then

		if port_id(0) = '1' then
		  -- read UART status at address 01 hex
      	in_port <= uart_status_port;
		end if;

		if port_id(1) = '1' then	
		  -- read UART receive data at address 02 hex
      	in_port <= rx_data;
      end if;
		
		if port_id(2) = '1' then -- address 04
		  -- read DIPS SW at address 04 hex
		  in_port <= Dip_Sw;
		end if;

      -- Form read strobe for UART receiver FIFO buffer.
      -- The fact that the read strobe will occur after the actual data is read by 
      -- the KCPSM3 is acceptable because it is really means 'I have read you'!

      read_from_uart <= read_strobe and port_id(1); -- uart read at address 02

    end if;

  end process input_ports;


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 output ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  output_ports: process(clk)
  begin

    if clk'event and clk='1' then
      if write_strobe='1' then
			-- leds at address 0x02. If statement will use less logic than case
			if port_id(1) = '1' then	
	   	  	leds <= out_port;
			end if;
			-- led segment at address 0x08. If statement will use less logic than case
			if port_id(3) = '1' then	
	   	  	seg <= out_port;
				segments <= seg(6 downto 0);
			end if;
			-- an at address 0x10. If statement will use less logic than case
			if port_id(4) = '1' then	
	   	  	anode <= out_port;
				an <= anode(3 downto 0);
			end if;
      end if;
    end if; 

  end process output_ports;

  --
  -- write to UART transmitter FIFO buffer at address 01 hex.
  -- This is a combinatorial decode because the FIFO is the 'port register'.
  --
  write_to_uart <= write_strobe and port_id(0);	-- address 01

  --

  ----------------------------------------------------------------------------------------------------------------------------------
  -- UARTS  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- Connect the 8-bit, 1 stop-bit, no parity transmit and receive macros.
  -- Each contains an embedded 16-byte FIFO buffer.
  --

  transmit: uart_tx 
  port map (            data_in => out_port, 
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
                     reset_buffer => '0',
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
  --


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- pwm ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

 pwm_ports: process(clk)
  begin

    if clk'event and clk='1' then
      if write_strobe='1' then
			-- use at address 0x02 and 0x04. If statement will use less logic than case
			if port_id(1) = '0' and port_id(2) = '0' then	
				pwm_duty0 <= out_port;---std_logic_vector(unsigned(pwm_duty_reg)
			end if;
			if port_id(1) = '1' and port_id(2) = '0' then	
				pwm_duty1 <= out_port;
			end if;

      end if;
    end if; 

  end process pwm_ports;

  --
  ----
  --
  pwm_timer: process(clk)
  begin
    if clk'event and clk='1' then
      if pwm_count = "11111111" then				 
      	pwm_count <= "00000000";
			pwm(0) <= '0';
       else
         pwm_count <= pwm_count + '1';
         pwm(0) <= '0';
      end if;
		if pwm_count < pwm_duty0 then
		  pwm(0) <= '1';
      else
		  pwm(0) <= '0';
      end if;
    end if;
  end process pwm_timer;
 --

----------------------------------------------------------------------------------------------------------------------------------

end Behavioral; -- of pico_processor

------------------------------------------------------------------------------------------------------------------------------------
--
-- END OF FILE picoblaze.vhd
--
------------------------------------------------------------------------------------------------------------------------------------


