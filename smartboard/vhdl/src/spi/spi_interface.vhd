-- File:     spi_interface.vhd
-- 
--

LIBRARY ieee;
LIBRARY UNISIM;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE UNISIM.Vcomponents.ALL;

ENTITY spi_interface IS
   PORT ( clk	:	IN	STD_LOGIC; 
          clkdiv	:	IN	STD_LOGIC_VECTOR (1 DOWNTO 0); 
          cpha	:	IN	STD_LOGIC; 
          cpol	:	IN	STD_LOGIC; 
          miso	:	IN	STD_LOGIC; 
          rcv_cpol	:	IN	STD_LOGIC; 
          rcv_full_reset	:	IN	STD_LOGIC; 
          reset	:	IN	STD_LOGIC; 
          ss_in_n	:	IN	STD_LOGIC; 
          ss_mask_reg	:	IN	STD_LOGIC_VECTOR (7 DOWNTO 0); 
          start	:	IN	STD_LOGIC; 
          xmit_data	:	IN	STD_LOGIC_VECTOR (7 DOWNTO 0); 
          xmit_empty_reset	:	IN	STD_LOGIC; 
          done	:	OUT	STD_LOGIC; 
          mosi	:	OUT	STD_LOGIC; 
          rcv_data	:	OUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
          rcv_full	:	OUT	STD_LOGIC; 
          ss_n	:	OUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
          rcv_load	:	INOUT	STD_LOGIC; 
          sck	:	INOUT	STD_LOGIC; 
          ss_in_int	:	INOUT	STD_LOGIC; 
          ss_n_int	:	INOUT	STD_LOGIC; 
          xmit_empty	:	INOUT	STD_LOGIC);

end spi_interface;

ARCHITECTURE SCHEMATIC OF spi_interface IS
   SIGNAL clk0_mask	:	STD_LOGIC;
   SIGNAL clk1_mask	:	STD_LOGIC;
   SIGNAL sck_1	:	STD_LOGIC;
   SIGNAL sck_fe	:	STD_LOGIC;
   SIGNAL sck_int_fe	:	STD_LOGIC;
   SIGNAL sck_int_re	:	STD_LOGIC;
   SIGNAL sck_re	:	STD_LOGIC;
   SIGNAL vcc	:	STD_LOGIC;
   SIGNAL xmit_load	:	STD_LOGIC;
   SIGNAL xmit_shift	:	STD_LOGIC;

   ATTRIBUTE fpga_dont_touch : STRING ;
   ATTRIBUTE fpga_dont_touch OF XLXI_9 : LABEL IS "true";

   COMPONENT sck_logic
      PORT ( clk	:	IN	STD_LOGIC; 
             clk0_mask	:	IN	STD_LOGIC; 
             clk1_mask	:	IN	STD_LOGIC; 
             clkdiv	:	IN	STD_LOGIC_VECTOR (1 DOWNTO 0); 
             cpha	:	IN	STD_LOGIC; 
             cpol	:	IN	STD_LOGIC; 
             reset	:	IN	STD_LOGIC; 
             ss_in_int	:	IN	STD_LOGIC; 
             sck	:	INOUT	STD_LOGIC; 
             sck_1	:	INOUT	STD_LOGIC; 
             sck_fe	:	OUT	STD_LOGIC; 
             sck_int_fe	:	OUT	STD_LOGIC; 
             sck_int_re	:	OUT	STD_LOGIC; 
             sck_re	:	OUT	STD_LOGIC);
   END COMPONENT;

   COMPONENT spi_control_sm
      PORT ( clk	:	IN	STD_LOGIC; 
             cpha	:	IN	STD_LOGIC; 
             cpol	:	IN	STD_LOGIC; 
             rcv_full_reset	:	IN	STD_LOGIC; 
             rcv_load	:	IN	STD_LOGIC; 
             reset	:	IN	STD_LOGIC; 
             sck_fe	:	IN	STD_LOGIC; 
             sck_int	:	IN	STD_LOGIC; 
             sck_int_fe	:	IN	STD_LOGIC; 
             sck_int_re	:	IN	STD_LOGIC; 
             sck_re	:	IN	STD_LOGIC; 
             ss_in_n	:	IN	STD_LOGIC; 
             ss_mask_reg	:	IN	STD_LOGIC_VECTOR (7 DOWNTO 0); 
             start	:	IN	STD_LOGIC; 
             xmit_empty_reset	:	IN	STD_LOGIC; 
             ss_in_int	:	INOUT	STD_LOGIC; 
             ss_n_int	:	INOUT	STD_LOGIC; 
             xmit_empty	:	INOUT	STD_LOGIC; 
             xmit_load	:	INOUT	STD_LOGIC; 
             clk0_mask	:	OUT	STD_LOGIC; 
             clk1_mask	:	OUT	STD_LOGIC; 
             done	:	OUT	STD_LOGIC; 
             rcv_full	:	OUT	STD_LOGIC; 
             ss_n	:	OUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
             xmit_shift	:	OUT	STD_LOGIC);
   END COMPONENT;

   COMPONENT spi_rcv_shift_reg
      PORT ( cpol	:	IN	STD_LOGIC; 
             miso	:	IN	STD_LOGIC; 
             rcv_cpol	:	IN	STD_LOGIC; 
             reset	:	IN	STD_LOGIC; 
             sck_fe	:	IN	STD_LOGIC; 
             sck_re	:	IN	STD_LOGIC; 
             sclk	:	IN	STD_LOGIC; 
             shift_en	:	IN	STD_LOGIC; 
             ss_in_int	:	IN	STD_LOGIC; 
             data_out	:	OUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
             rcv_load	:	OUT	STD_LOGIC);
   END COMPONENT;

   COMPONENT spi_xmit_shift_reg
      PORT ( data_in	:	IN	STD_LOGIC_VECTOR (7 DOWNTO 0); 
             data_ld	:	IN	STD_LOGIC; 
             reset	:	IN	STD_LOGIC; 
             sclk	:	IN	STD_LOGIC; 
             shift_en	:	IN	STD_LOGIC; 
             shift_in	:	IN	STD_LOGIC; 
             ss_in_int	:	IN	STD_LOGIC; 
             sys_clk	:	IN	STD_LOGIC; 
             mosi	:	OUT	STD_LOGIC);
   END COMPONENT;

BEGIN

   XLXI_9 : NAND2B1
      PORT MAP (I0=>xmit_shift, I1=>xmit_shift, O=>vcc);

   SCK_GEN : sck_logic
      PORT MAP (clk=>clk, clk0_mask=>clk0_mask, clk1_mask=>clk1_mask,
      clkdiv(1)=>clkdiv(1), clkdiv(0)=>clkdiv(0), cpha=>cpha, cpol=>cpol,
      reset=>reset, ss_in_int=>ss_in_int, sck=>sck, sck_1=>sck_1,
      sck_fe=>sck_fe, sck_int_fe=>sck_int_fe, sck_int_re=>sck_int_re,
      sck_re=>sck_re);

   spi_ctrl_sm : spi_control_sm
      PORT MAP (clk=>clk, cpha=>cpha, cpol=>cpol,
      rcv_full_reset=>rcv_full_reset, rcv_load=>rcv_load, reset=>reset,
      sck_fe=>sck_fe, sck_int=>sck_1, sck_int_fe=>sck_int_fe,
      sck_int_re=>sck_int_re, sck_re=>sck_re, ss_in_n=>ss_in_n,
      ss_mask_reg(7)=>ss_mask_reg(7), ss_mask_reg(6)=>ss_mask_reg(6),
      ss_mask_reg(5)=>ss_mask_reg(5), ss_mask_reg(4)=>ss_mask_reg(4),
      ss_mask_reg(3)=>ss_mask_reg(3), ss_mask_reg(2)=>ss_mask_reg(2),
      ss_mask_reg(1)=>ss_mask_reg(1), ss_mask_reg(0)=>ss_mask_reg(0),
      start=>start, xmit_empty_reset=>xmit_empty_reset, ss_in_int=>ss_in_int,
      ss_n_int=>ss_n_int, xmit_empty=>xmit_empty, xmit_load=>xmit_load,
      clk0_mask=>clk0_mask, clk1_mask=>clk1_mask, done=>done,
      rcv_full=>rcv_full, ss_n(7)=>ss_n(7), ss_n(6)=>ss_n(6), ss_n(5)=>ss_n(5),
      ss_n(4)=>ss_n(4), ss_n(3)=>ss_n(3), ss_n(2)=>ss_n(2), ss_n(1)=>ss_n(1),
      ss_n(0)=>ss_n(0), xmit_shift=>xmit_shift);

   rcv_shift_reg : spi_rcv_shift_reg
      PORT MAP (cpol=>cpol, miso=>miso, rcv_cpol=>rcv_cpol, reset=>reset,
      sck_fe=>sck_fe, sck_re=>sck_re, sclk=>sck, shift_en=>ss_n_int,
      ss_in_int=>ss_in_int, data_out(7)=>rcv_data(7), data_out(6)=>rcv_data(6),
      data_out(5)=>rcv_data(5), data_out(4)=>rcv_data(4),
      data_out(3)=>rcv_data(3), data_out(2)=>rcv_data(2),
      data_out(1)=>rcv_data(1), data_out(0)=>rcv_data(0), rcv_load=>rcv_load);

   xmit_shift_reg : spi_xmit_shift_reg
      PORT MAP (data_in(7)=>xmit_data(7), data_in(6)=>xmit_data(6),
      data_in(5)=>xmit_data(5), data_in(4)=>xmit_data(4),
      data_in(3)=>xmit_data(3), data_in(2)=>xmit_data(2),
      data_in(1)=>xmit_data(1), data_in(0)=>xmit_data(0), data_ld=>xmit_load,
      reset=>reset, sclk=>sck_1, shift_en=>xmit_shift, shift_in=>vcc,
      ss_in_int=>ss_in_int, sys_clk=>clk, mosi=>mosi);

END SCHEMATIC;



