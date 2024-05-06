
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee,math_real.all;

entity i2s_master_TB_VHDL is

end i2s_master_TB_VHDL;

architecture behave of i2s_master_TB_VHDL is

 
  --  Clock frequencies from 2.048Mhz to
  --  4.096MHz are supported so sampling rates from 32KHz
  --  to 64KHz can be had by changing the clock frequency. 

  -- period = 1/f = 1/4.096MHz = 244ns?

  constant c_CLOCK_PERIOD   : time := 20 ns; 
  signal signal_reset       : std_logic;  
  signal signal_CLOCK       : std_logic := '0';

  -- WS representing LRCLK
  signal signal_WS           : std_logic;

  signal signal_i2s_dout    : std_logic;
  signal signal_i2s_bclk    : std_logic;
  
  signal signal_fifo_w_stb   : std_logic;
  signal sig_test_word       : std_logic_vector(17 downto 0) :=  "00" & x"dead";
  signal signal_fifo_din     : std_logic_vector (31 downto 0);
  signal signal_fifo_full    : std_logic;
  signal sig_tb_count       : integer;

    component i2s_master is
      port (
        clk             : in  std_logic;
        clk_1           : in  std_logic;
        rst             : in  std_logic;
        --  bclk: bit clock or data clock
        i2s_bclk        : out std_logic;
    
        --  lrclk: the left/right clock, also known as WS
        --  this tells the mic
        --  when to start transmitting. When the LRCLK is low, the left channel will transmit.
        --  When LRCLK is high, the right channel will transmit.
        i2s_lrcl        : out std_logic; 
    
        --  dout: the data output from the mic
        i2s_dout        : in  std_logic;
    
        fifo_din        : out std_logic_vector(31 downto 0);
        fifo_w_stb      : out std_logic;
        fifo_full       : in  std_logic
      );
    end component;
begin
      -- Instantiate the Unit Under Test (UUT)
      signal_fifo_full <= '0';
      UUT : i2s_master
          port map (
          clk       => signal_CLOCK,
          clk_1     => signal_CLOCK,
          rst       => signal_reset,
          i2s_dout    => signal_i2s_dout,
          fifo_full   => signal_fifo_full,
          fifo_din    => signal_fifo_din,
          i2s_lrcl    => signal_WS,
          i2s_bclk    => signal_i2s_bclk,
          fifo_w_stb  => signal_fifo_w_stb
      );

      p_CLK_GEN : process is
      begin
        wait for  c_CLOCK_PERIOD/2;
        signal_CLOCK <= not signal_CLOCK;
      end process p_CLK_GEN;

      process is
      begin
        signal_reset <= '0';
        wait for 16*c_CLOCK_PERIOD;
        signal_reset <= '1';
        wait for 24*c_CLOCK_PERIOD;
        signal_reset <= '0';
        wait for 2 sec;
      end process;

      process (signal_i2s_bclk, signal_reset)
        variable counter : integer := 0;                               -- main testing
      -- variable random : real;
      begin
        sig_tb_count <= counter;
        if signal_reset = '1' then
            counter := 0;
        elsif rising_edge(signal_i2s_bclk) then
            if counter >= 1 and counter <= 18 then
    --                uniform (100, 200, random);
    --                if random > 0.5 then
                signal_i2s_dout <= sig_test_word(18-counter);
            else 
                signal_i2s_dout <= '0';
            end if;
            
            counter := counter + 1;
            if counter = 32 then
                counter := 0;
            end if;
        end if;
    end process;

         
  end behave;

