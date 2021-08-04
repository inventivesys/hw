------------------------------------------------------------------------------
--
--  Xilinx, Inc. 2004                 www.xilinx.com
--
------------------------------------------------------------------------------
--
--  File name :       clock.vhd
--
--  Description :     Clock for S3 demo board
--			Seg(0) = DP
--			Seg(1) = middle
--			Seg(2) = top left
--			Seg(3) = bottom left
--			Seg(4) = bottom
--			Seg(5) = bottom right
--			Seg(6) = top right
--			Seg(7) = top
--
--  Date - revision : 4th February 2004 - v 1.0
--
--  Author :          NJS
--
--  Contact : e-mail  hotline@xilinx.com
--            phone   + 1 800 255 7778
--
--  Disclaimer: LIMITED WARRANTY AND DISCLAMER. These designs are
--              provided to you "as is". Xilinx and its licensors make, and you
--              receive no warranties or conditions, express, implied,
--              statutory or otherwise, and Xilinx specifically disclaims any
--              implied warranties of merchantability, non-infringement, or
--              fitness for a particular purpose. Xilinx does not warrant that
--              the functions contained in these designs will meet your
--              requirements, or that the operation of these designs will be
--              uninterrupted or error free, or that defects in the Designs
--              will be corrected. Furthermore, Xilinx does not warrant or
--              make any representations regarding use or the results of the
--              use of the designs in terms of correctness, accuracy,
--              reliability, or otherwise.
--
--              LIMITATION OF LIABILITY. In no event will Xilinx or its
--              licensors be liable for any loss of data, lost profits, cost
--              or procurement of substitute goods or services, or for any
--              special, incidental, consequential, or indirect damages
--              arising from the use or operation of the designs or
--              accompanying documentation, however caused and on any theory
--              of liability. This limitation will apply even if Xilinx
--              has been advised of the possibility of such damage. This
--              limitation shall apply not-withstanding the failure of the
--              essential purpose of any limited remedies herein.
--
--  Copyright © 2002 Xilinx, Inc.
--  All rights reserved
--
------------------------------------------------------------------------------
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all ;

--pragma translate_off
library unisim ;
use unisim.vcomponents.all ;
--pragma translate_on

entity clock is port (
	clk50in				: in std_logic ; 			-- 50 Mhz XTAL
	pb_in				: in std_logic_vector(3 downto 0);	-- 4 pushbutton inputs
	sw_in				: in std_logic_vector(7 downto 0);	-- 8 switch inputs
	digit_out			: out std_logic_vector(3 downto 0);	-- digit drivers
	led_out				: out std_logic_vector(7 downto 0);	-- 8 LEDs
	seg_out				: out std_logic_vector(7 downto 0));	-- segment drivers

end clock ;

architecture arch_clock of clock is

-- CMOS33 input buffer primitive
component ibuf_lvcmos33 port (i : in std_logic; o : out std_logic); end component;
-- CMOS33 clock input buffer primitive
component ibufg_lvcmos33 port(i : in std_logic; o : out std_logic); end component;
-- CMOS33 output buffer primitive
component obuf_lvcmos33 port(i : in std_logic; o : out std_logic); end component;
-- global buffer primitive
component bufg port(i : in std_logic; o : out std_logic); end component;

signal low 		: std_logic ;				-- logic '0'
signal high 		: std_logic ;				-- logic '1'
signal rst 		: std_logic ;				-- logic '1'
signal clk50int		: std_logic ;				-- 
signal clk50		: std_logic ;				-- 
signal pb 		: std_logic_vector(3 downto 0) ;	-- 
signal sw 		: std_logic_vector(7 downto 0) ;	-- 
signal led 		: std_logic_vector(7 downto 0) ;	-- 
signal digit 		: std_logic_vector(3 downto 0) ;	-- 
signal seg 		: std_logic_vector(7 downto 0) ;	-- 
signal mhertz_count	: std_logic_vector(5 downto 0) ;	-- 
signal khertz_count	: std_logic_vector(9 downto 0) ;	-- 
signal hertz_count	: std_logic_vector(9 downto 0) ;	-- 
signal mhertz_en	: std_logic ;				-- 
signal khertz_en	: std_logic ;				-- 
signal hertz_en		: std_logic ;				-- 
signal bcdint		: std_logic_vector(15 downto 0) ;	-- 
signal curr		: std_logic_vector(3 downto 0) ;	-- 
signal cd		: std_logic_vector(2 downto 0) ;	-- 
signal point		: std_logic ;				-- 
signal dp		: std_logic ;				-- 


begin

low 	<= '0' ;
high 	<= '1' ;
rst 	<= pb(0) ; 			

clk50in_ibuf 	: ibufg_lvcmos33	port map(i => clk50in, 	o => clk50int );
rxclka_bufg 	: bufg 			port map(i => clk50int, o => clk50 ) ;

loop0 : for i in 0 to 3 generate
digit_obuf 	: obuf_lvcmos33  	port map(i => digit(i),	o => digit_out(i));
pb_ibuf 	: ibuf_lvcmos33  	port map(i => pb_in(i),	o => pb(i));
end generate ;

loop1 : for i in 0 to 7 generate
led_obuf 	: obuf_lvcmos33  	port map(i => led(i),	o => led_out(i));
digit_obuf 	: obuf_lvcmos33  	port map(i => seg(i),	o => seg_out(i));
sw_ibuf 	: ibuf_lvcmos33  	port map(i => sw_in(i),	o => sw(i));
end generate ;


-- moved the led counter every second.
process (clk50, rst)
begin
if rst = '1' then
	led <= "00000001" ;
	point <= '0' ;
	dp <= '0' ;
elsif clk50'event and clk50 = '1' then
	if hertz_en = '1' then
		point <= not point ;
		led <= led(6 downto 0) & led(7) ;
	end if ;
	if cd(1 downto 0) = "10" then
		dp <= point ;
	else
		dp <= '1' ;
	end if ;
end if ;
end process ;

-- generates a 1 Mhz signal from a 50 Mhz signal
process (clk50, rst)
begin
if rst = '1' then
	mhertz_count <= (others => '0') ;
	mhertz_en <= '0' ;
elsif clk50'event and clk50 = '1' then
	mhertz_count <= mhertz_count + 1 ;
	if mhertz_count = "110010" then
		mhertz_en <= '1' ;
		mhertz_count <= (others => '0') ;
	else 
		mhertz_en <= '0' ;
	end if ;
end if ;
end process ;												

-- generates a 1 kHz signal from a 1Mhz signal
process (clk50, rst)
begin
if rst = '1' then
	khertz_count <= (others => '0') ;
	khertz_en <= '0' ;
elsif clk50'event and clk50 = '1' then
	if mhertz_en = '1' then
		khertz_count <= khertz_count + 1 ;
		if khertz_count = "1111101000" then
			khertz_en <= '1' ;
			khertz_count <= (others => '0') ;
		else
			khertz_en <= '0' ;
		end if ;
	else
		khertz_en <= '0' ;
	end if ;
end if ;
end process ;

--generates a 1 Hz signal from a 1 kHz signal
process (clk50, rst)
begin
if rst = '1' then
	hertz_count <= (others => '0') ;
	hertz_en <= '0' ;
elsif clk50'event and clk50 = '1' then
	if khertz_en = '1' then
		hertz_count <= hertz_count + 1 ;
		if hertz_count = "1111101000" then
			hertz_en <= '1' ;
			hertz_count <= (others => '0') ;
		else
			hertz_en <= '0' ;
		end if ;
	else
		hertz_en <= '0' ;
	end if ;
end if ;
end process ;

--increments time counter for 7-segment display based on 1 hertz signal
process (clk50, rst)
begin
if rst = '1' then
	bcdint <= (others => '0') ;
elsif clk50'event and clk50 = '1' then	
	if hertz_en = '1' then	
		if bcdint(3 downto 0) = "1001" then 					
			if bcdint(7 downto 4) = "0101" then 					
				if bcdint(11 downto 8) = "1001" then 					
					if bcdint(15 downto 12) = "0101" then 					
						bcdint <= "0000000000000000" ;
					else
						bcdint <= (bcdint(15 downto 12) + 1) & "000000000000" ;
					end if ;
				else
					bcdint <= bcdint(15 downto 12) & (bcdint(11 downto 8) + 1) & "00000000" ;
				end if ;
			else
				bcdint <= bcdint(15 downto 8) & (bcdint(7 downto 4) + 1) & "0000" ;
			end if ;
		else
			bcdint <= bcdint(15 downto 4) & (bcdint(3 downto 0) + 1) ;
		end if ;
	end if ;
end if ;
end process ;


-- shows how to multiplex outputs time counter to 7-segment display
process (clk50, rst)
begin
if rst = '1' then
	seg <= (others => '1') ;
	digit <= (others => '1') ;
	cd <= (others => '0') ;
	curr <= (others => '0') ;
elsif clk50'event and clk50 = '1' then
	cd(2) <= '1' ;
	if khertz_en = '1' then
		cd(1 downto 0) <= cd(1 downto 0) + 1 ;
	end if ;
	case cd(1 downto 0) is 
		when "00" =>   curr <= bcdint(3 downto 0) ;   digit <= "1110" ;
		when "01" =>   curr <= bcdint(7 downto 4) ;   digit <= "1101" ;
		when "10" =>   curr <= bcdint(11 downto 8) ;  digit <= "1011" ;
		when others => curr <= bcdint(15 downto 12) ; digit <= "0111" ;
	end case ;
	if cd(2) = '1' then 
		case curr is 
			when "0000" => seg <= "0000001" & dp ; 
			when "0001" => seg <= "1001111" & dp ;
			when "0010" => seg <= "0010010" & dp ;
			when "0011" => seg <= "0000110" & dp ;
			when "0100" => seg <= "1001100" & dp ;
			when "0101" => seg <= "0100100" & dp ;
			when "0110" => seg <= "0100000" & dp ;
			when "0111" => seg <= "0001111" & dp ;
			when "1000" => seg <= "0000000" & dp ;
			when others => seg <= "0000100" & dp ;
		end case ;
	else
		seg <= (others => '1') ;
	end if ;
end if ;
end process ;

end arch_clock;


