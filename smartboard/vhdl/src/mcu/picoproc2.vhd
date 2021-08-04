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
entity pico_2nd_processor is
    Port (
         reset 		: in std_logic;
         clk 			: in std_logic
			);
    end pico_2nd_processor;
--
------------------------------------------------------------------------------------
--
-- Start of architecture
--
architecture Behavioral of pico_2nd_processor is
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


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 input ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  


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
	   	  	pwm_period_reg <= out_port;
			end if;
			-- led segment at address 0x08. If statement will use less logic than case
			if port_id(3) = '1' then	
	   	  	pwm_period_reg <= out_port;
			end if;

      end if;
    end if; 

  end process output_ports;
  --
  -- write to UART transmitter FIFO buffer at address 01 hex.
  -- This is a combinatorial decode because the FIFO is the 'port register'.
  --
 
  --

  ----------------------------------------------------------------------------------------------------------------------------------
  -- UARTS  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- Connect the 8-bit, 1 stop-bit, no parity transmit and receive macros.
  -- Each contains an embedded 16-byte FIFO buffer.
  --

  
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


  --
  --


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- pwm ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --


 --

----------------------------------------------------------------------------------------------------------------------------------

end Behavioral; -- of pico_processor2

------------------------------------------------------------------------------------------------------------------------------------
--
-- END OF FILE picoblaze.vhd
--
------------------------------------------------------------------------------------------------------------------------------------


