

-- Analog-to-Digital Converter Model

-- +-----------------------------+
-- | Copyright 1995-1996 DOULOS  |
-- |      Library: analogue      |
-- |    designer : Tim Pagden    |
-- |     opened:  2 Feb 1996     |
-- +-----------------------------+

-- Architectures:
--   02.02.96 original

library ieee;
library vfp;

architecture original of ADC_8_bit is
  use ieee.std_logic_1164.all;
  use vfp.analog_class.all;
  use vfp.bus_class.all;
  use vfp.generic_conversions.all;
  use vfp.std_operators.all;
  use vfp.mixed_operators.all;
  use vfp.generic_functions.all;
  use vfp.twos_complement_types.all;

  constant conversion_time: time := 25 ns;

  signal instantly_digitized_signal : std_ulogic_vector(7 downto 0);
  signal delayed_digitized_signal : std_ulogic_vector(7 downto 0);

  function ADC_8b_10v_bipolar (
    analog_in: analog
  ) return byte is
    constant max_abs_digital_value : integer := 128;
    constant max_in_signal : real := 10.0;
    variable digitized_2s_comp_signal : twos_complement(7 downto 0);
    variable analog_signal: real;
    variable analog_abs: real;
    variable analog_limited: real;
    variable digitized_signal: integer;
    variable digital_out: byte;
  begin
    analog_signal := real(analog_in);
    if (analog_signal < 0.0) then    -- i/p = -ve
      digitized_signal := integer(analog_signal * 12.8);
      if (digitized_signal < -(max_abs_digital_value)) then
        digitized_signal := -(max_abs_digital_value);
      end if;
    else    -- i/p = +ve
      digitized_signal := integer(analog_signal * 12.8);
      if (digitized_signal > (max_abs_digital_value - 1)) then
        digitized_signal := max_abs_digital_value - 1;
      end if;
    end if;
    digitized_2s_comp_signal := digitized_2s_comp_signal = digitized_signal;
    digital_out := byte(digitized_2s_comp_signal);
    return digital_out;
  end ADC_8b_10v_bipolar;

begin

  s0: instantly_digitized_signal <=
        std_ulogic_vector (ADC_8b_10v_bipolar (analog_in));

  s1: delayed_digitized_signal <=
        instantly_digitized_signal after conversion_time;

  s2: digital_out <= delayed_digitized_signal;

end original;

