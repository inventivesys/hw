  --------------------------------------------------------------------------------
  -- Entity declaration of 'upcnt4'.
  -- Last modified : Wed Feb 19 12:02:24 2003.
  --------------------------------------------------------------------------------


  library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.std_logic_arith.all ;

  entity upcnt4 is
    port(
      clk    : in     STD_LOGIC ;
      clr    : in     STD_LOGIC ;
      cnt_en : in     STD_LOGIC ;
      data   : in     STD_LOGIC_VECTOR(3 downto 0) ;
      load   : in     STD_LOGIC ;
      qout   : out    STD_LOGIC_VECTOR(3 downto 0) ) ;
  end entity upcnt4 ;

  --------------------------------------------------------------------------------
  -- Architecture 'a0' of 'upcnt4'
  -- Last modified : Wed Feb 19 12:02:24 2003.
  --------------------------------------------------------------------------------


  architecture a0 of upcnt4 is

  constant RESET_ACTIVE : std_logic := '0';

  signal q_int : UNSIGNED (3 downto 0);

  begin

      process(clk, clr)
      begin
          -- Clear output register
          if (clr = RESET_ACTIVE) then
              q_int <= (others => '0');

            -- On falling edge of clock count
          elsif (clk'event) and clk = '1' then

             -- Load in start value
              if (load = '1') then
                  q_int <= UNSIGNED(data);
                 -- If count enable is high
              elsif cnt_en = '1' then
                  q_int <= q_int + 1;
             end if;
        end if;

      end process;

      qout <= STD_LOGIC_VECTOR(q_int);

  end architecture a0 ; -- of upcnt4


  architecture behavioural of upcnt4 is

  constant RESET_ACTIVE : std_logic := '0';

  signal q_int : UNSIGNED (3 downto 0);

  begin

      process(clk, clr)
      begin
          -- Clear output register
          if (clr = RESET_ACTIVE) then
              q_int <= (others => '0');

            -- On falling edge of clock count
          elsif (clk'event) and clk = '1' then

             -- Load in start value
              if (load = '1') then
                  q_int <= UNSIGNED(data);
                 -- If count enable is high
              elsif cnt_en = '1' then
                  q_int <= q_int + 1;
             end if;
        end if;

      end process;

      qout <= STD_LOGIC_VECTOR(q_int);

  end architecture behavioural ; -- of upcnt4


