--
-- Definition of a single port ROM for KCPSM3 program defined by adc_ctrl.psm
--
-- Generated by KCPSM3 Assembler 05Feb2007-10:27:29. 
--
-- Standard IEEE libraries
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
-- The Unisim Library is used to define Xilinx primitives. It is also used during
-- simulation. The source can be viewed at %XILINX%\vhdl\src\unisims\unisim_VCOMP.vhd
--  
library unisim;
use unisim.vcomponents.all;
--
--
entity adc_ctrl is
    Port (      address : in std_logic_vector(9 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                    clk : in std_logic);
    end adc_ctrl;
--
architecture low_level_definition of adc_ctrl is
--
-- Attributes to define ROM contents during implementation synthesis. 
-- The information is repeated in the generic map for functional simulation
--
attribute INIT_00 : string; 
attribute INIT_01 : string; 
attribute INIT_02 : string; 
attribute INIT_03 : string; 
attribute INIT_04 : string; 
attribute INIT_05 : string; 
attribute INIT_06 : string; 
attribute INIT_07 : string; 
attribute INIT_08 : string; 
attribute INIT_09 : string; 
attribute INIT_0A : string; 
attribute INIT_0B : string; 
attribute INIT_0C : string; 
attribute INIT_0D : string; 
attribute INIT_0E : string; 
attribute INIT_0F : string; 
attribute INIT_10 : string; 
attribute INIT_11 : string; 
attribute INIT_12 : string; 
attribute INIT_13 : string; 
attribute INIT_14 : string; 
attribute INIT_15 : string; 
attribute INIT_16 : string; 
attribute INIT_17 : string; 
attribute INIT_18 : string; 
attribute INIT_19 : string; 
attribute INIT_1A : string; 
attribute INIT_1B : string; 
attribute INIT_1C : string; 
attribute INIT_1D : string; 
attribute INIT_1E : string; 
attribute INIT_1F : string; 
attribute INIT_20 : string; 
attribute INIT_21 : string; 
attribute INIT_22 : string; 
attribute INIT_23 : string; 
attribute INIT_24 : string; 
attribute INIT_25 : string; 
attribute INIT_26 : string; 
attribute INIT_27 : string; 
attribute INIT_28 : string; 
attribute INIT_29 : string; 
attribute INIT_2A : string; 
attribute INIT_2B : string; 
attribute INIT_2C : string; 
attribute INIT_2D : string; 
attribute INIT_2E : string; 
attribute INIT_2F : string; 
attribute INIT_30 : string; 
attribute INIT_31 : string; 
attribute INIT_32 : string; 
attribute INIT_33 : string; 
attribute INIT_34 : string; 
attribute INIT_35 : string; 
attribute INIT_36 : string; 
attribute INIT_37 : string; 
attribute INIT_38 : string; 
attribute INIT_39 : string; 
attribute INIT_3A : string; 
attribute INIT_3B : string; 
attribute INIT_3C : string; 
attribute INIT_3D : string; 
attribute INIT_3E : string; 
attribute INIT_3F : string; 
attribute INITP_00 : string;
attribute INITP_01 : string;
attribute INITP_02 : string;
attribute INITP_03 : string;
attribute INITP_04 : string;
attribute INITP_05 : string;
attribute INITP_06 : string;
attribute INITP_07 : string;
--
-- Attributes to define ROM contents during implementation synthesis.
--
attribute INIT_00 of ram_1024_x_18  : label is "E0060000023E01E501E501E501E501E5017502430523016002430510022D0131";
attribute INIT_01 of ram_1024_x_18  : label is "E0068001600650164FFF549F2E0454982E014E00C0010FFF40A4E005E0040001";
attribute INIT_02 of ram_1024_x_18  : label is "00116301620001AB1B50052001C9600001C960010243052C01AB1B500520C080";
attribute INIT_03 of ram_1024_x_18  : label is "0520A7008601E7FFE6FF4040052B543B278002430520A700A600050600F60127";
attribute INIT_04 of ram_1024_x_18  : label is "00305061440201EC00775061440101D800EF640463016200019F019F007B0203";
attribute INIT_05 of ram_1024_x_18  : label is "009C5061440101FF00385061440601FE000C5061440501FC00185061440301F8";
attribute INIT_06 of ram_1024_x_18  : label is "547443E063016200019F01E002430517019FA7068672A700A600050600F601FF";
attribute INIT_07 of ram_1024_x_18  : label is "01AB1B508530650A01144014007B0203547942FF5479431F4079053E54744200";
attribute INIT_08 of ram_1024_x_18  : label is "01AB1B508530650701AB1B508530650801AB1B508530650901AB1B50052E019F";
attribute INIT_09 of ram_1024_x_18  : label is "C00040A4000754A4400880016004C000019FA00001AB1B50050D01AB1B500520";
attribute INIT_0A of ram_1024_x_18  : label is "02030547024305100134D20002060206020602066205E004000154A4C0016004";
attribute INIT_0B of ram_1024_x_18  : label is "54C7400240F102030520020305200203053154BE400160040203052D0203053D";
attribute INIT_0C of ram_1024_x_18  : label is "40F102030520020305200203053554D0400340F1020305200203052002030532";
attribute INIT_0D of ram_1024_x_18  : label is "0520020305300203053254E2400540F102030520020305300203053154D94004";
attribute INIT_0E of ram_1024_x_18  : label is "0530020305300203053140F102030520020305300203053554EB400640F10203";
attribute INIT_0F of ram_1024_x_18  : label is "0A0F198008FF50FE238008000400050006000700401454F12005400001E00203";
attribute INIT_10 of ram_1024_x_18  : label is "D4205D1320015500CA010900080003000206B790B680B53094205D070008010E";
attribute INIT_11 of ram_1024_x_18  : label is "0700060015701460A0005516C0018801F480011C08070005A000F790F680F530";
attribute INIT_12 of ram_1024_x_18  : label is "5523C1010208030E07000606B5309420412B06075928F530D420010D03A00200";
attribute INIT_13 of ram_1024_x_18  : label is "C008E001020023404301C008E001C2040108C008E0080131A000C00800AEA000";
attribute INIT_14 of ram_1024_x_18  : label is "4301C008E001C008E0010122C008E010C008E0100131A000C008E0085538C101";
attribute INIT_15 of ram_1024_x_18  : label is "A0000608070A0608070A0808090A0808090A554BC10109000800070006002380";
attribute INIT_16 of ram_1024_x_18  : label is "020305610203056F020305620203057402030572020305610203056D02030553";
attribute INIT_17 of ram_1024_x_18  : label is "056E0203056F02030543020305200203054F02030549A0000203056402030572";
attribute INIT_18 of ram_1024_x_18  : label is "0203053D0203054102030556A0000203056C0203056F02030572020305740203";
attribute INIT_19 of ram_1024_x_18  : label is "0E02A00001AB0B6101AB0B75A0000203053D020305440203052F02030541A000";
attribute INIT_1A of ram_1024_x_18  : label is "C00110B055AB20024004A00055A0CE01020315B0020305741B10410620044004";
attribute INIT_1B of ram_1024_x_18  : label is "1010120001C4000E000E000E000E110041B28101B0004B0A01AB7B100110A000";
attribute INIT_1C of ram_1024_x_18  : label is "1B50156001AB1B501520161001B8A000803A800759C7C00AA000110001C4A00F";
attribute INIT_1D of ram_1024_x_18  : label is "A00055DCC20101D60219A00055D7C10101D20128A00055D3C001000BA00001AB";
attribute INIT_1E of ram_1024_x_18  : label is "A000C440E40101D2C440E401A00055E6C40101E00432A00055E1C30101DB0314";
attribute INIT_1F of ram_1024_x_18  : label is "01D601F00406040604060407145001D201F0C408A4F01450A00001EAC440A4F8";
attribute INIT_20 of ram_1024_x_18  : label is "01EAC4400406040604070407145001D201EAC440C40CA4F01450A000C44004F0";
attribute INIT_21 of ram_1024_x_18  : label is "01D2C440E40101D2C440E401450201D2C440E401C440040EA000C44004F001D6";
attribute INIT_22 of ram_1024_x_18  : label is "01F0043001E0A00001D6C4400404D500000E000E000E000EA5F0C440E4014002";
attribute INIT_23 of ram_1024_x_18  : label is "01F4050101F4050C01F4050601F4052801D601F0042001D601F001DB01F001E0";
attribute INIT_24 of ram_1024_x_18  : label is "E901E8000145A00001F4C5C0A50FA00001F4C580A50F52492510A00001DB01DB";
attribute INIT_25 of ram_1024_x_18  : label is "00000000000000000000000000000000000000000000000080010F00E703E602";
attribute INIT_26 of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_27 of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_28 of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_29 of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_2A of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_2B of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_2C of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_2D of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_2E of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_2F of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_30 of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_31 of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_32 of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_33 of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_34 of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_35 of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_36 of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_37 of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_38 of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_39 of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_3A of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_3B of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_3C of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_3D of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_3E of ram_1024_x_18  : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_3F of ram_1024_x_18  : label is "424D000000000000000000000000000000000000000000000000000000000000";
attribute INITP_00 of ram_1024_x_18 : label is "C4FFDDCDD0FCD56C34343434343400FF1433716C030CCCC293774CE88FFFF3CF";
attribute INITP_01 of ram_1024_x_18 : label is "03400F4F333CCCDF3337CCCDF3337CCCDF3334CCCCCAA234F353EC30C4C4C4C3";
attribute INITP_02 of ram_1024_x_18 : label is "333332CCCCCCCCCCAAAAB6A922088E8D892223A2DAA5ED4000B5B095776A957A";
attribute INITP_03 of ram_1024_x_18 : label is "FAA3C0B8A38B72DCB72DCB4B0C0E5D8C0EA8D9C28D2DCC042CCB3332CCCB3333";
attribute INITP_04 of ram_1024_x_18 : label is "0000000000000000000000CAAEC2C36FCCCCF3FFCEE0AA20E38388A3EAA3E028";
attribute INITP_05 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INITP_06 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INITP_07 of ram_1024_x_18 : label is "C000000000000000000000000000000000000000000000000000000000000000";
--
begin
--
  --Instantiate the Xilinx primitive for a block RAM
  ram_1024_x_18: RAMB16_S18
  --synthesis translate_off
  --INIT values repeated to define contents for functional simulation
  generic map ( INIT_00 => X"E0060000023E01E501E501E501E501E5017502430523016002430510022D0131",
                INIT_01 => X"E0068001600650164FFF549F2E0454982E014E00C0010FFF40A4E005E0040001",
                INIT_02 => X"00116301620001AB1B50052001C9600001C960010243052C01AB1B500520C080",
                INIT_03 => X"0520A7008601E7FFE6FF4040052B543B278002430520A700A600050600F60127",
                INIT_04 => X"00305061440201EC00775061440101D800EF640463016200019F019F007B0203",
                INIT_05 => X"009C5061440101FF00385061440601FE000C5061440501FC00185061440301F8",
                INIT_06 => X"547443E063016200019F01E002430517019FA7068672A700A600050600F601FF",
                INIT_07 => X"01AB1B508530650A01144014007B0203547942FF5479431F4079053E54744200",
                INIT_08 => X"01AB1B508530650701AB1B508530650801AB1B508530650901AB1B50052E019F",
                INIT_09 => X"C00040A4000754A4400880016004C000019FA00001AB1B50050D01AB1B500520",
                INIT_0A => X"02030547024305100134D20002060206020602066205E004000154A4C0016004",
                INIT_0B => X"54C7400240F102030520020305200203053154BE400160040203052D0203053D",
                INIT_0C => X"40F102030520020305200203053554D0400340F1020305200203052002030532",
                INIT_0D => X"0520020305300203053254E2400540F102030520020305300203053154D94004",
                INIT_0E => X"0530020305300203053140F102030520020305300203053554EB400640F10203",
                INIT_0F => X"0A0F198008FF50FE238008000400050006000700401454F12005400001E00203",
                INIT_10 => X"D4205D1320015500CA010900080003000206B790B680B53094205D070008010E",
                INIT_11 => X"0700060015701460A0005516C0018801F480011C08070005A000F790F680F530",
                INIT_12 => X"5523C1010208030E07000606B5309420412B06075928F530D420010D03A00200",
                INIT_13 => X"C008E001020023404301C008E001C2040108C008E0080131A000C00800AEA000",
                INIT_14 => X"4301C008E001C008E0010122C008E010C008E0100131A000C008E0085538C101",
                INIT_15 => X"A0000608070A0608070A0808090A0808090A554BC10109000800070006002380",
                INIT_16 => X"020305610203056F020305620203057402030572020305610203056D02030553",
                INIT_17 => X"056E0203056F02030543020305200203054F02030549A0000203056402030572",
                INIT_18 => X"0203053D0203054102030556A0000203056C0203056F02030572020305740203",
                INIT_19 => X"0E02A00001AB0B6101AB0B75A0000203053D020305440203052F02030541A000",
                INIT_1A => X"C00110B055AB20024004A00055A0CE01020315B0020305741B10410620044004",
                INIT_1B => X"1010120001C4000E000E000E000E110041B28101B0004B0A01AB7B100110A000",
                INIT_1C => X"1B50156001AB1B501520161001B8A000803A800759C7C00AA000110001C4A00F",
                INIT_1D => X"A00055DCC20101D60219A00055D7C10101D20128A00055D3C001000BA00001AB",
                INIT_1E => X"A000C440E40101D2C440E401A00055E6C40101E00432A00055E1C30101DB0314",
                INIT_1F => X"01D601F00406040604060407145001D201F0C408A4F01450A00001EAC440A4F8",
                INIT_20 => X"01EAC4400406040604070407145001D201EAC440C40CA4F01450A000C44004F0",
                INIT_21 => X"01D2C440E40101D2C440E401450201D2C440E401C440040EA000C44004F001D6",
                INIT_22 => X"01F0043001E0A00001D6C4400404D500000E000E000E000EA5F0C440E4014002",
                INIT_23 => X"01F4050101F4050C01F4050601F4052801D601F0042001D601F001DB01F001E0",
                INIT_24 => X"E901E8000145A00001F4C5C0A50FA00001F4C580A50F52492510A00001DB01DB",
                INIT_25 => X"00000000000000000000000000000000000000000000000080010F00E703E602",
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
                INIT_3F => X"424D000000000000000000000000000000000000000000000000000000000000",    
               INITP_00 => X"C4FFDDCDD0FCD56C34343434343400FF1433716C030CCCC293774CE88FFFF3CF",
               INITP_01 => X"03400F4F333CCCDF3337CCCDF3337CCCDF3334CCCCCAA234F353EC30C4C4C4C3",
               INITP_02 => X"333332CCCCCCCCCCAAAAB6A922088E8D892223A2DAA5ED4000B5B095776A957A",
               INITP_03 => X"FAA3C0B8A38B72DCB72DCB4B0C0E5D8C0EA8D9C28D2DCC042CCB3332CCCB3333",
               INITP_04 => X"0000000000000000000000CAAEC2C36FCCCCF3FFCEE0AA20E38388A3EAA3E028",
               INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_07 => X"C000000000000000000000000000000000000000000000000000000000000000")
  --synthesis translate_on
  port map(    DI => "0000000000000000",
              DIP => "00",
               EN => '1',
               WE => '0',
              SSR => '0',
              CLK => clk,
             ADDR => address,
               DO => instruction(15 downto 0),
              DOP => instruction(17 downto 16)); 
--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- END OF FILE adc_ctrl.vhd
--
------------------------------------------------------------------------------------
