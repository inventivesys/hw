
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:59:31 10/30/2005
-- Design Name:   ece574_pico
-- Module Name:   ece574_pico_tb.vhd
-- Project Name:  Picoblaze_1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ece574_pico
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY ece574_pico_tb_vhd IS
END ece574_pico_tb_vhd;

ARCHITECTURE behavior OF ece574_pico_tb_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT ece574_pico
	PORT(
		sysclk : IN std_logic;
		sysreset : IN std_logic;
		rxd : IN std_logic;
		dip_sw : IN std_logic_vector(7 downto 0);          
		txd : OUT std_logic;
		leds : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	--Inputs
	SIGNAL sysclk :  std_logic := '0';
	SIGNAL sysreset :  std_logic := '0';
	SIGNAL rxd :  std_logic := '0';
	SIGNAL dip_sw :  std_logic_vector(7 downto 0) := (others=>'0');

	--Outputs
	SIGNAL txd :  std_logic;
	SIGNAL leds :  std_logic_vector(7 downto 0);

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: ece574_pico PORT MAP(
		sysclk => sysclk,
		sysreset => sysreset,
		txd => txd,
		rxd => rxd,
		leds => leds,
		dip_sw => dip_sw
	);

	sysclk <= not sysclk after 10 ns; -- 50MHz clock
	
	tb : PROCESS
	BEGIN

		-- Wait 100 ns for global reset to finish
		wait for 100 ns;

		dip_sw <= X"55";

		wait for 100 us;

		dip_sw <= X"11";

		wait for 100 us;

		dip_sw <= X"22";

		wait for 100 us;

		dip_sw <= X"33";

		wait for 100 us;

		dip_sw <= X"44";

		-- Place stimulus here

		wait; -- will wait forever
	END PROCESS;

END;
