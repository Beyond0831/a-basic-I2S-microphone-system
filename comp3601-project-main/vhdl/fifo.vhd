library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
    generic (
        DATA_WIDTH : positive := 32;
        FIFO_DEPTH : positive := 5
    );
    port (
        clkw    : in  std_logic;
        clkr    : in  std_logic;
        rst     : in  std_logic;
        wr      : in  std_logic;
        rd      : in  std_logic;
        din     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        empty   : out std_logic;
        full    : out std_logic;
        dout    : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end fifo;

architecture arch of fifo is
    -- For testing: FIFO_DEPTH = 5 
    -- Array has 32 elements (31 downto 0)
    type fifo_t is array (0 to 2**FIFO_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem : fifo_t := (others => (others => '0'));

    -- "Read pointer", "Write pointer"
    -- Holds a number from 0-63
    signal rdp, wrp : unsigned(FIFO_DEPTH downto 0) := (others => '0');

    signal sig_read_ptr : unsigned(FIFO_DEPTH-1 downto 0);
    signal sig_write_ptr : unsigned(FIFO_DEPTH-1 downto 0);

    signal sig_full : std_logic;
    signal sig_empty : std_logic;
begin
    full <= sig_full;
    empty <= sig_empty;

    -- when 'read pointer' has caught up to 'write pointer', all data has been read
    sig_empty <= '1' when rdp = wrp else '0';
    
    -- When 'write pointer' has wrote 32 times and caught up to 'read pointer'
    -- the top bit of 'write pointer' has changed
    sig_full <= (rdp(FIFO_DEPTH) xor wrp(FIFO_DEPTH)) when (rdp(FIFO_DEPTH-1 downto 0) = wrp(FIFO_DEPTH-1 downto 0)) else '0';

    -- unused
    sig_read_ptr <= rdp(FIFO_DEPTH-1 downto 0) + 1;
    
    -- write pointer (4 downto 0) holds a number from 0-31
    sig_write_ptr <= wrp(FIFO_DEPTH-1 downto 0);

    write_process: process(clkw, rst) 
    begin
        -- reset high
        if rst = '1' then
            wrp <= (others => '0');
        elsif rising_edge(clkw) then
            -- write on rising edge (bit clock ~3MHz) only when there is room
            if (wr = '1' and sig_full = '0') then
                mem(to_integer(sig_write_ptr)) <= din;
                wrp <= wrp + 1;
            end if;
        end if;
    end process;

    read_process: process(clkr, rst)
    begin
        -- reset high
        if rst = '1' then
            rdp <= (others => '0');
            dout <= (others => '0');
        elsif rising_edge(clkr) then
            -- read on rising edge (main clock 100MHz) only when there is data
            if (rd = '1' and sig_empty = '0') then
                dout <= mem(to_integer(rdp(FIFO_DEPTH-1 downto 0)));
                rdp <= rdp + 1;
            end if;
        end if;
    end process;

end arch;
