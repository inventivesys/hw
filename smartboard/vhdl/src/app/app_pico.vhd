--------------------------------------------------------------------------------
-- Programmer: 	John Qin
--
-- Create Date:    01/03/06
-- Design Name:    
-- Module Name:    TopLevel
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:	This file is a top level vhdl file for 
--						Picoblaze processor application on the Spartan 3 board 
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity sp3_pico is
  Port ( 
         -- processor
    	 	sysclk			: in std_logic;
    	 	sysreset			: in std_logic;
	 	 	txd				: out std_logic;
	 		rxd				: in std_logic;

			-- board i/o
			segments			: out std_logic_vector(7 downto 0);	-- led segments
			an					: out std_logic_vector(3 downto 0);	-- led driver/anode
	 		leds				: out std_logic_vector(7 downto 0);
	 		dip_sw			: in std_logic_vector(7 downto 0);

         -- spi interface
			spi_sck 		   : out std_logic;

			-- PWM
			pwm				: out std_logic_vector(3 downto 0)

         -- i2c
	      --ADDR_BUS : in     std_logic_vector(23 downto 0) ;
	      --AS       : in     std_logic ;
	      --DATA_BUS : inout  std_logic_vector(7 downto 0) ;
	      --DS       : in     std_logic ; -- Data Strobe
	      --DTACK    : out    std_logic ;
	      --IRQ      : out    std_logic ;
	      --R_W      : in     std_logic ; -- '1' indicates a read, '0' indicates a write
	      --SCL      : inout  std_logic ;
	      --SDA      : inout  std_logic ; -- Serial Data
	      --mcf      : inout  std_logic ;

			-- portest
         --address     : in std_logic_vector(9 downto 0);
         --instruction : out std_logic_vector(17 downto 0);
         --clk         : in std_logic

    );
end sp3_pico;

architecture Behavioral of sp3_pico is
  
-- ********************************************************************************
-- ********************* components used in toplevel ******************************
-- ********************************************************************************
   
--
-- processor component declaration
    component pico_processor is
    Port ( 
         		reset 		: in std_logic;
         		clk 			: in std_logic;
					txd			: out std_logic;
			 		rxd			: in std_logic;
					dip_sw		: in std_logic_vector(7 downto 0);
					leds			: out std_logic_vector(7 downto 0);
					segments		: out std_logic_vector(7 downto 0);	
					an				: out std_logic_vector(3 downto 0);
					spi_sck     : out std_logic;
					pwm		   : out std_logic_vector(3 downto 0)
			);
    end component; -- pico_processor
  

   




--
-- i2c component declaration
   --component i2c is
   --port(
      --ADDR_BUS : in     std_logic_vector(23 downto 0) ;
      --AS       : in     std_logic ;
      --DATA_BUS : inout  std_logic_vector(7 downto 0) ;
      --DS       : in     std_logic ; -- Data Strobe
      --DTACK    : out    std_logic ;
      --IRQ      : out    std_logic ;
      --R_W      : in     std_logic ; -- '1' indicates a read, '0' indicates a write
      --SCL      : inout  std_logic ;
      --SDA      : inout  std_logic ; -- Serial Data
      --mcf      : inout  std_logic ;
      --reset    : in     std_logic ;
      --sys_clk  : in     std_logic ) ;
   --end component; -- i2c

 --
-- porttest component declaration
   --component porttest is
   --port(
      --address     : in std_logic_vector(9 downto 0);
      --instruction : out std_logic_vector(17 downto 0);
      --clk         : in std_logic);
   --end component; -- porttest



begin  
  --
  -- component instantiations
  --

  -- processor component instantiations 
  pico_processor_inst: pico_processor 
    Port Map(
         		reset 		=> SysReset,
         		clk 			=> SysClk,
					txd			=> txd,
					rxd			=> rxd,
					dip_sw		=> dip_sw,
					leds			=> leds,
					segments		=> segments,	
					an				=> an,
					spi_sck     => spi_sck,
					pwm         => pwm
			);
 
			  


  -- i2c component instantiations 
  --i2c_inst: i2c 
    --Port Map(
 		--      ADDR_BUS => ADDR_BUS,
		--      AS => AS,
		--      DATA_BUS => DATA_BUS,
		--      DS => DS,
		--      DTACK => DTACK,
		--      IRQ => IRQ,
		--      R_W => R_W,
		--      SCL => SCL,
		--      SDA => SDA,
		--      mcf => mcf,
		--      reset => SysReset,
		--      sys_clk => SysClk
		--	);

  -- porttest component instantiations 
  --porttest_inst: porttest 
    --Port Map(
 		--      address => address,
		--      instruction => instruction,
		--      clk => clk
		--	);


end Behavioral; -- of sp3_pico
