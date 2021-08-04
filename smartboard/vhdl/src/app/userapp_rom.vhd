
library IEEE ;
use IEEE.STD_LOGIC_1164.all ;
use IEEE.STD_LOGIC_ARITH.all ;
use IEEE.STD_LOGIC_UNSIGNED.all ;

library unisim ;
use unisim.vcomponents.all ;

entity userapp_rom is

    port ( 
        clk : in std_logic ;
        address : in std_logic_vector( 9 downto 0 ) ;
        instruction : out std_logic_vector( 17 downto 0 )
    ) ;

end entity userapp_rom ;

architecture mix of userapp_rom is
    component jtag_shifter is
        port ( 
			clk : in std_logic ;
			user1 : out std_logic ;
            write : out std_logic ;
            addr : out std_logic_vector( 10 downto 0 ) ;
            data : out std_logic_vector( 8 downto 0 )
        ) ;
    end component ;

    signal jaddr : std_logic_vector( 10 downto 0 ) ;
    signal jdata : std_logic_vector( 8 downto 0 ) ;
    signal juser1 : std_logic ;
    signal jwrite : std_logic ;

    attribute INIT_00 : string ;
    attribute INIT_01 : string ;
    attribute INIT_02 : string ;
    attribute INIT_03 : string ;
    attribute INIT_04 : string ;
    attribute INIT_05 : string ;
    attribute INIT_06 : string ;
    attribute INIT_07 : string ;
    attribute INIT_08 : string ;
    attribute INIT_09 : string ;
    attribute INIT_0A : string ;
    attribute INIT_0B : string ;
    attribute INIT_0C : string ;
    attribute INIT_0D : string ;
    attribute INIT_0E : string ;
    attribute INIT_0F : string ;
    attribute INIT_10 : string ;
    attribute INIT_11 : string ;
    attribute INIT_12 : string ;
    attribute INIT_13 : string ;
    attribute INIT_14 : string ;
    attribute INIT_15 : string ;
    attribute INIT_16 : string ;
    attribute INIT_17 : string ;
    attribute INIT_18 : string ;
    attribute INIT_19 : string ;
    attribute INIT_1A : string ;
    attribute INIT_1B : string ;
    attribute INIT_1C : string ;

    attribute INIT_1D : string ;
    attribute INIT_1E : string ;
    attribute INIT_1F : string ;
    attribute INIT_20 : string ;
    attribute INIT_21 : string ;
    attribute INIT_22 : string ;
    attribute INIT_23 : string ;
    attribute INIT_24 : string ;
    attribute INIT_25 : string ;
    attribute INIT_26 : string ;
    attribute INIT_27 : string ;
    attribute INIT_28 : string ;
    attribute INIT_29 : string ;
    attribute INIT_2A : string ;
    attribute INIT_2B : string ;
    attribute INIT_2C : string ;
    attribute INIT_2D : string ;
    attribute INIT_2E : string ;
    attribute INIT_2F : string ;
    attribute INIT_30 : string ;
    attribute INIT_31 : string ;
    attribute INIT_32 : string ;
    attribute INIT_33 : string ;
    attribute INIT_34 : string ;
    attribute INIT_35 : string ;
    attribute INIT_36 : string ;
    attribute INIT_37 : string ;
    attribute INIT_38 : string ;
    attribute INIT_39 : string ;
    attribute INIT_3A : string ;
    attribute INIT_3B : string ;
    attribute INIT_3C : string ;
    attribute INIT_3D : string ;
    attribute INIT_3E : string ;
    attribute INIT_3F : string ;
    attribute INITP_00 : string ;
    attribute INITP_01 : string ;
    attribute INITP_02 : string ;
    attribute INITP_03 : string ;
    attribute INITP_04 : string ;
    attribute INITP_05 : string ;
    attribute INITP_06 : string ;
    attribute INITP_07 : string ;
begin
	    bram : component RAMB16_S9_S18
	        generic map (
	            INIT_00 => X"12D0C1024104002C6305E2050275004BC0020055004B004B004B004BC0020033",
	            INIT_01 => X"4001A00018104102501E20104001400DC308C1100301500DD2D0003F003F003F",
	            INIT_02 => X"001F080A001F080D40268101B000480A001F78100110A000C0011080541F2002",
	            INIT_03 => X"000CA000001F080D001F0834001F0837001F0835001F0845001F0843001F0845",
	            INIT_04 => X"A000544CC30100430310A0005444C2015445C101003F01C80250A0015440C001",
	            INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INIT_3F => X"43FC8001AC008D01000000000000000000000000000000000000000000000000",
	            INITP_00 => X"000000000000000000000000B72DDC2D2CCCCCCCCCD9C28D20D3A37F23238FF8",
	            INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
	            INITP_07 => X"F500000000000000000000000000000000000000000000000000000000000000"
	        )
	        port map (
	            DIB => "0000000000000000",
	            DIPB => "00",
	            ENB => '1',
	            WEB => '0',
	            SSRB => '0',
	            CLKB => clk,
	            ADDRB => address,
	            DOB => instruction( 15 downto 0 ),
	            DOPB => instruction( 17 downto 16 ),
	            DIA => jdata( 7 downto 0 ),
	            DIPA => jdata( 8 downto 8),
	            ENA => juser1,
	            WEA => jwrite,
	            SSRA => '0',
	            CLKA => clk,
	            ADDRA => jaddr,
	            DOA => open,
	            DOPA => open 
	        ) ;

	jdata <= ( others => '0' ) ;
	jaddr <= ( others => '0' ) ;
	juser1 <= '0' ;
	jwrite <= '0' ;
end architecture mix ;
