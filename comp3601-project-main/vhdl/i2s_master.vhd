library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity i2s_master is
    port (
        clk             : in  std_logic;
        clk_1           : in  std_logic;
        rst             : in  std_logic;

        i2s_bclk        : out std_logic;
        i2s_lrcl        : out std_logic; 
        i2s_dout        : in  std_logic;

        fifo_din        : out std_logic_vector(31 downto 0);
        fifo_w_stb      : out std_logic;
        fifo_full       : in  std_logic
    );
end i2s_master;

architecture behavioural of i2s_master is
    constant clk_1_divide_ratio : integer := 16;
    constant ws_divide_ratio    : integer := 64;
    signal sig_shift_out        : std_logic_vector(17 downto 0) := (others => '0');
    signal sig_i2s_bclk         : std_logic;
    signal sig_lr_flag          : std_logic; -- '1' for right hand side microphone
    signal sig_i2s_ws           : std_logic := '0';
    signal sig_rotate           : std_logic_vector(12 downto 0) := "0000000111111";
begin
    fifo_din <= sig_lr_flag & sig_rotate & sig_shift_out ;

    -- BCLK block divider
    i2s_bclk <= sig_i2s_bclk;
    bclk_divider: process (clk_1)
        variable count: integer := 0;
    begin
        if falling_edge(clk_1) then
            if count < (clk_1_divide_ratio / 2) then
                sig_i2s_bclk <= '0';
            else
                sig_i2s_bclk <= '1';
            end if;
            
            count := count + 1;
            if count = clk_1_divide_ratio then
                count := 0;
            end if;
        end if;
    end process;
    
    -- debugging only
--    i2s_lrcl <= sig_i2s_ws;
--    ws_divider: process (sig_i2s_bclk)
--        variable count: integer := 0;
--    begin
--        if falling_edge(sig_i2s_bclk) then
--            if count < (ws_divide_ratio / 2) then
--                sig_i2s_ws <= '0';
--            else
--                sig_i2s_ws <= '1';
--            end if;
            
--            count := count + 1;
--            if count = ws_divide_ratio then
--                count := 0;
--            end if;
--        end if;
--    end process;
    
    i2s_lrcl <= sig_i2s_ws;
    ws_divider: process (sig_i2s_bclk, rst)
        variable ws_count: integer := 0;
        variable count: integer := 0; 
    begin
        if rst = '0' then
            ws_count := 0;
            count := 0;
        elsif falling_edge(sig_i2s_bclk) then
            -- ws divide
            if ws_count < (ws_divide_ratio / 2) then
                sig_i2s_ws <= '0';
            else
                sig_i2s_ws <= '1';
            end if;

            ws_count := ws_count + 1;
            if ws_count = ws_divide_ratio then
                ws_count := 0;
            end if;
            
            -- shift register
            if count > 0 and count <= 18 then
                sig_lr_flag <= sig_i2s_ws;
                for i in 17 downto 1 loop
                    sig_shift_out(i) <= sig_shift_out(i - 1);
                end loop;
                sig_shift_out(0) <= i2s_dout;
            end if;
            
            fifo_w_stb <= '0'; -- default assingment
            count := count + 1;
            if count = ws_divide_ratio / 2 then
                count := 0;
                fifo_w_stb <= not fifo_full;
                for i in 12 downto 1 loop
                    sig_rotate(i) <= sig_rotate(i - 1);
                end loop;
                sig_rotate(0) <= sig_rotate(12);
            end if;
        end if;
    end process;
    
--    shift_reg: process(sig_i2s_bclk)
--    begin
--        if falling_edge(sig_i2s_bclk) then
--            -- data shift register
--            if sig_count > 0 and sig_count <= 18 then
--                sig_shift_out(0) <= i2s_dout;
--                for i in 17 downto 1 loop
--                    sig_shift_out(i) <= sig_shift_out(i - 1);
--                end loop;
--            end if;
            
--            fifo_w_stb <= '0'; -- default value for fifo write
--            if sig_count = 31 then
--                fifo_w_stb <= not fifo_full; -- write if fifo is not full
--                for i in 13 downto 1 loop -- visual only - shift once
--                    sig_rotate(i) <= sig_rotate(i - 1);
--                end loop;
--                sig_rotate(0) <= sig_rotate(13);
--            end if;
--        end if;
--    end process;

end behavioural;
