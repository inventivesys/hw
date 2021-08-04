-- File:     spi_master.vhd
-- 
--

LIBRARY ieee;
LIBRARY UNISIM;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE UNISIM.Vcomponents.ALL;

ENTITY spi_master IS
   PORT ( addr	:	IN	STD_LOGIC_VECTOR (7 DOWNTO 0); 
          ale_n	:	IN	STD_LOGIC; 
          clk	:	IN	STD_LOGIC; 
          miso	:	IN	STD_LOGIC; 
          psen_n	:	IN	STD_LOGIC; 
          rd_n	:	IN	STD_LOGIC; 
          reset	:	IN	STD_LOGIC; 
          ss_in_n	:	IN	STD_LOGIC; 
          wr_n	:	IN	STD_LOGIC; 
          mosi	:	OUT	STD_LOGIC; 
          ss_n	:	OUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
          addr_data	:	INOUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
          int_n	:	INOUT	STD_LOGIC; 
          rcv_full	:	INOUT	STD_LOGIC; 
          sck	:	INOUT	STD_LOGIC; 
          xmit_empty	:	INOUT	STD_LOGIC);

end spi_master;

ARCHITECTURE SCHEMATIC OF spi_master IS
   SIGNAL clkdiv	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
   SIGNAL cpha	:	STD_LOGIC;
   SIGNAL cpol	:	STD_LOGIC;
   SIGNAL done	:	STD_LOGIC;
   SIGNAL rcv_cpol	:	STD_LOGIC;
   SIGNAL rcv_data	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL rcv_full_reset	:	STD_LOGIC;
   SIGNAL rcv_load	:	STD_LOGIC;
   SIGNAL spien	:	STD_LOGIC;
   SIGNAL spissr	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL spitr	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL ss_in_int	:	STD_LOGIC;
   SIGNAL ss_n_int	:	STD_LOGIC;
   SIGNAL start	:	STD_LOGIC;
   SIGNAL xmit_empty_reset	:	STD_LOGIC;

   ATTRIBUTE fpga_dont_touch : STRING ;

   COMPONENT spi_interface
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
             rcv_load	:	INOUT	STD_LOGIC; 
             sck	:	INOUT	STD_LOGIC; 
             ss_in_int	:	INOUT	STD_LOGIC; 
             ss_n_int	:	INOUT	STD_LOGIC; 
             xmit_empty	:	INOUT	STD_LOGIC; 
             done	:	OUT	STD_LOGIC; 
             mosi	:	OUT	STD_LOGIC; 
             rcv_data	:	OUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
             rcv_full	:	OUT	STD_LOGIC; 
             ss_n	:	OUT	STD_LOGIC_VECTOR (7 DOWNTO 0));
   END COMPONENT;

   COMPONENT uc_interface
      PORT ( addr	:	IN	STD_LOGIC_VECTOR (7 DOWNTO 0); 
             ale_n	:	IN	STD_LOGIC; 
             clk	:	IN	STD_LOGIC; 
             done	:	IN	STD_LOGIC; 
             psen_n	:	IN	STD_LOGIC; 
             rcv_full	:	IN	STD_LOGIC; 
             rcv_load	:	IN	STD_LOGIC; 
             rd_n	:	IN	STD_LOGIC; 
             receive_data	:	IN	STD_LOGIC_VECTOR (7 DOWNTO 0); 
             reset	:	IN	STD_LOGIC; 
             ss_in_int	:	IN	STD_LOGIC; 
             ss_n	:	IN	STD_LOGIC; 
             wr_n	:	IN	STD_LOGIC; 
             xmit_empty	:	IN	STD_LOGIC; 
             addr_data	:	INOUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
             clkdiv	:	INOUT	STD_LOGIC_VECTOR (1 DOWNTO 0); 
             cpha	:	INOUT	STD_LOGIC; 
             cpol	:	INOUT	STD_LOGIC; 
             int_n	:	INOUT	STD_LOGIC; 
             rcv_cpol	:	INOUT	STD_LOGIC; 
             rcv_full_reset	:	INOUT	STD_LOGIC; 
             spien	:	INOUT	STD_LOGIC; 
             spissr	:	INOUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
             spitr	:	INOUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
             start	:	INOUT	STD_LOGIC; 
             xmit_empty_reset	:	INOUT	STD_LOGIC);
   END COMPONENT;

BEGIN

   spi_intrface : spi_interface
      PORT MAP (clk=>clk, clkdiv(1)=>clkdiv(1), clkdiv(0)=>clkdiv(0),
      cpha=>cpha, cpol=>cpol, miso=>miso, rcv_cpol=>rcv_cpol,
      rcv_full_reset=>rcv_full_reset, reset=>spien, ss_in_n=>ss_in_n,
      ss_mask_reg(7)=>spissr(7), ss_mask_reg(6)=>spissr(6),
      ss_mask_reg(5)=>spissr(5), ss_mask_reg(4)=>spissr(4),
      ss_mask_reg(3)=>spissr(3), ss_mask_reg(2)=>spissr(2),
      ss_mask_reg(1)=>spissr(1), ss_mask_reg(0)=>spissr(0), start=>start,
      xmit_data(7)=>spitr(7), xmit_data(6)=>spitr(6), xmit_data(5)=>spitr(5),
      xmit_data(4)=>spitr(4), xmit_data(3)=>spitr(3), xmit_data(2)=>spitr(2),
      xmit_data(1)=>spitr(1), xmit_data(0)=>spitr(0),
      xmit_empty_reset=>xmit_empty_reset, rcv_load=>rcv_load, sck=>sck,
      ss_in_int=>ss_in_int, ss_n_int=>ss_n_int, xmit_empty=>xmit_empty,
      done=>done, mosi=>mosi, rcv_data(7)=>rcv_data(7),
      rcv_data(6)=>rcv_data(6), rcv_data(5)=>rcv_data(5),
      rcv_data(4)=>rcv_data(4), rcv_data(3)=>rcv_data(3),
      rcv_data(2)=>rcv_data(2), rcv_data(1)=>rcv_data(1),
      rcv_data(0)=>rcv_data(0), rcv_full=>rcv_full, ss_n(7)=>ss_n(7),
      ss_n(6)=>ss_n(6), ss_n(5)=>ss_n(5), ss_n(4)=>ss_n(4), ss_n(3)=>ss_n(3),
      ss_n(2)=>ss_n(2), ss_n(1)=>ss_n(1), ss_n(0)=>ss_n(0));

   uc_intrface : uc_interface
      PORT MAP (addr(7)=>addr(7), addr(6)=>addr(6), addr(5)=>addr(5),
      addr(4)=>addr(4), addr(3)=>addr(3), addr(2)=>addr(2), addr(1)=>addr(1),
      addr(0)=>addr(0), ale_n=>ale_n, clk=>clk, done=>done, psen_n=>psen_n,
      rcv_full=>rcv_full, rcv_load=>rcv_load, rd_n=>rd_n,
      receive_data(7)=>rcv_data(7), receive_data(6)=>rcv_data(6),
      receive_data(5)=>rcv_data(5), receive_data(4)=>rcv_data(4),
      receive_data(3)=>rcv_data(3), receive_data(2)=>rcv_data(2),
      receive_data(1)=>rcv_data(1), receive_data(0)=>rcv_data(0), reset=>reset,
      ss_in_int=>ss_in_int, ss_n=>ss_n_int, wr_n=>wr_n, xmit_empty=>xmit_empty,
      addr_data(7)=>addr_data(7), addr_data(6)=>addr_data(6),
      addr_data(5)=>addr_data(5), addr_data(4)=>addr_data(4),
      addr_data(3)=>addr_data(3), addr_data(2)=>addr_data(2),
      addr_data(1)=>addr_data(1), addr_data(0)=>addr_data(0),
      clkdiv(1)=>clkdiv(1), clkdiv(0)=>clkdiv(0), cpha=>cpha, cpol=>cpol,
      int_n=>int_n, rcv_cpol=>rcv_cpol, rcv_full_reset=>rcv_full_reset,
      spien=>spien, spissr(7)=>spissr(7), spissr(6)=>spissr(6),
      spissr(5)=>spissr(5), spissr(4)=>spissr(4), spissr(3)=>spissr(3),
      spissr(2)=>spissr(2), spissr(1)=>spissr(1), spissr(0)=>spissr(0),
      spitr(7)=>spitr(7), spitr(6)=>spitr(6), spitr(5)=>spitr(5),
      spitr(4)=>spitr(4), spitr(3)=>spitr(3), spitr(2)=>spitr(2),
      spitr(1)=>spitr(1), spitr(0)=>spitr(0), start=>start,
      xmit_empty_reset=>xmit_empty_reset);

END SCHEMATIC;



