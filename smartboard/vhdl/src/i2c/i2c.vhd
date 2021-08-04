--------------------------------------------------------------------------------
-- Entity declaration of 'I2C'.
-- Last modified : Tue Jan 21 10:42:48 2003.
--------------------------------------------------------------------------------

library ieee ;
use ieee.std_logic_1164.all ;

entity I2C is
   generic(
     I2C_ADDRESS :  std_logic_vector(15 downto 0) := (OTHERS => '0') ) ;
   port(
      ADDR_BUS : in     std_logic_vector(23 downto 0) ; -- mcu Address Bus.
      AS       : in     std_logic ;	-- Address Strobe
      DATA_BUS : inout  std_logic_vector(7 downto 0) ; -- Data Bus
      DS       : in     std_logic ; -- Data Strobe
      DTACK    : out    std_logic ;	-- Data Transfer Acknowledge.
      IRQ      : out    std_logic ;	-- interrupt
      R_W      : in     std_logic ; -- '1' indicates a read, '0' indicates a write
      SCL      : inout  std_logic ; -- I2C Serial Clock.
      SDA      : inout  std_logic ; -- Serial Data
      mcf      : inout  std_logic ;	-- Data Transferring Bit. While one byte of data is
												-- being transferred, this bit is cleared. It is set by the
												-- falling edge of the ninth clock of a byte transfer.
      reset    : in     std_logic ;
      sys_clk  : in     std_logic ) ;
  end entity I2C ;

  --------------------------------------------------------------------------------
  -- Architecture 'structural' of 'I2C'
  -- Last modified : Tue Jan 21 10:42:48 2003.
  --------------------------------------------------------------------------------

  architecture structural of I2C is

    component i2c_Control
      port(
        maas          : inout  std_logic ;
        madr          : in     std_logic_vector(7 downto 0) ;
        mal           : inout  std_logic ;
        mal_bit_reset : in     std_logic ;
        mbb           : out    std_logic ;
        mbcr_wr       : in     std_logic ;
        mbdr_i2c      : inout  std_logic_vector(7 downto 0) ;
        mbdr_micro    : in     std_logic_vector(7 downto 0) ;
        mcf           : inout  std_logic ;
        mif           : out    std_logic ;
        mif_bit_reset : in     std_logic ;
        msta          : in     std_logic ;
        msta_rst      : out    std_logic ;
        mtx           : in     std_logic ;
        reset         : in     std_logic ;
        rsta          : in     std_logic ;
        rsta_rst      : out    std_logic ;
        rxak          : out    std_logic ;
        scl           : inout  std_logic ;
        sda           : inout  std_logic ;
        srw           : inout  std_logic ;
        sys_clk       : in     std_logic ;
        txak          : in     std_logic ) ;
    end component i2c_Control ;
    component BusInterface
      generic(
        UC_ADDRESS :  std_logic_vector(15 downto 0) := (OTHERS => '0') ) ;
      port(
        ADDR_BUS      : in     std_logic_vector(23 downto 0) ;
        AS            : in     std_logic ;
        DATA_BUS      : inout  std_logic_vector(7 downto 0) ;
        DS            : in     std_logic ;
        DTACK         : out    std_logic ;
        IRQ           : out    std_logic ;
        R_W           : in     std_logic ;
        clk           : in     std_logic ; -- Clock
        maas          : in     std_logic ;
        madr          : inout  std_logic_vector(7 downto 0) ;
        mal           : in     std_logic ;
        mal_bit_reset : out    std_logic ;
        mbb           : in     std_logic ;
        mbcr_wr       : out    std_logic ;
        mbdr_i2c      : in     std_logic_vector(7 downto 0) ;
        mbdr_micro    : inout  std_logic_vector(7 downto 0) ;
        mbdr_read     : out    std_logic ;
        mcf           : in     std_logic ;
        men           : inout  std_logic ;
        mif           : in     std_logic ;
        mif_bit_reset : out    std_logic ;
        msta          : inout  std_logic ;
        msta_rst      : in     std_logic ;
        mtx           : inout  std_logic ;
        reset         : in     std_logic ; -- Reset
        rsta          : inout  std_logic ;
        rsta_rst      : in     std_logic ;
        rxak          : in     std_logic ;
        srw           : in     std_logic ;
        txak          : inout  std_logic ) ;
    end component BusInterface ;
    signal txak          :  std_logic ;
    signal msta          :  std_logic ;
    signal msta_rst      :  std_logic ;
    signal rsta          :  std_logic ;
    signal rsta_rst      :  std_logic ;
    signal mtx           :  std_logic ;
    signal mbdr_micro    :  std_logic_vector(7 downto 0) ;
    signal madr          :  std_logic_vector(7 downto 0) ;
    signal mbb           :  std_logic ;
    signal mbcr_wr       :  std_logic ;
    signal mif_bit_reset :  std_logic ;
    signal mal_bit_reset :  std_logic ;
    signal mbdr_i2c      :  std_logic_vector(7 downto 0) ;
    signal maas          :  std_logic ;
    signal mal           :  std_logic ;
    signal srw           :  std_logic ;
    signal mif           :  std_logic ;
    signal rxak          :  std_logic ;
    signal mem           :  std_logic ;
  begin
    --Control
    --Register
    --Status
    --Register


    u0: i2c_Control
      port map(
        maas => maas,
        madr => madr,
        mal => mal,
        mal_bit_reset => mal_bit_reset,
        mbb => mbb,
        mbcr_wr => mbcr_wr,
        mbdr_i2c => mbdr_i2c,
        mbdr_micro => mbdr_micro,
        mcf => mcf,
        mif => mif,
        mif_bit_reset => mif_bit_reset,
        msta => msta,
        msta_rst => msta_rst,
        mtx => mtx,
        reset => mem,
        rsta => rsta,
        rsta_rst => rsta_rst,
        rxak => rxak,
        scl => SCL,
        sda => SDA,
        srw => srw,
        sys_clk => sys_clk,
        txak => txak ) ;

    u1: BusInterface
      generic map(
        UC_ADDRESS => I2C_ADDRESS )

      port map(
        ADDR_BUS => ADDR_BUS,
        AS => AS,
        DATA_BUS => DATA_BUS,
        DS => DS,
        DTACK => DTACK,
        IRQ => IRQ,
        R_W => R_W,
        clk => sys_clk,
        maas => maas,
        madr => madr,
        mal => mal,
        mal_bit_reset => mal_bit_reset,
        mbb => mbb,
        mbcr_wr => mbcr_wr,
        mbdr_i2c => mbdr_i2c,
        mbdr_micro => mbdr_micro,
        mbdr_read => open,
        mcf => mcf,
        men => mem,
        mif => mif,
        mif_bit_reset => mif_bit_reset,
        msta => msta,
        msta_rst => msta_rst,
        mtx => mtx,
        reset => reset,
        rsta => rsta,
        rsta_rst => rsta_rst,
        rxak => rxak,
        srw => srw,
        txak => txak ) ;
  end architecture structural ; -- of I2C
