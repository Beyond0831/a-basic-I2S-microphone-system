library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fifo is
    generic ( 
                DATA_WIDTH : positive := 32;
                FIFO_DEPTH : positive := 5
    );
    port ( rst      : in  std_logic;
           clkr     : in  std_logic;
           clkw     : in  std_logic;
           rd       : in  std_logic;
           wr       : in  std_logic;
           empty    : out  std_logic;
           full     : out  std_logic;
           dout     : out  std_logic_vector(DATA_WIDTH-1 downto 0);
           din      : in  std_logic_vector(DATA_WIDTH-1 downto 0));
end fifo;

architecture Behavioral of fifo is
    
    signal
        sig_full,
        sig_empty
            : std_logic;
    signal 
        writePtr,
        syncReadPtrBin,
        readPtrGraySync0,
        readPtrGraySync1,
        writePtrGray,
        readPtrBin,
        readPtr,
        syncWritePtrBin,
        writePtrGraySync0,
        writePtrGraySync1,
        readPtrGray,
        writePtrBin
            : std_logic_vector(FIFO_DEPTH-1 downto 0);

    type fifo_t is array (0 to 2**FIFO_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem : fifo_t := (others => (others => '0'));

begin
    write_side : process(clkw)
    begin
        if rising_edge(clkw) then
            if rst = '1' then
                writePtr <= (others => '0');
                writePtrGray <= (others => '0');
                syncReadPtrBin <= (others => '0');
                readPtrGraySync0 <= (others => '0');
                readPtrGraySync1 <= (others => '0');
            else
                -- write pointer handling
                if wr = '1' and not sig_full = '1' then
                    writePtr <= writePtr + '1';
                end if;
                --write pointer to gray code conversion
                writePtrGray <= writePtr xor ('0' & writePtr(FIFO_DEPTH-1 downto 1));
                --gray coded read pointer synchronisation
                readPtrGraySync0 <= readPtrGray;
                readPtrGraySync1 <= readPtrGraySync0;
                --register read pointer in order to be resetable
                syncReadPtrBin <= readPtrBin;
            end if;
        end if;
    end process;
    --read pointer to binary conversion
    readPtrBin(FIFO_DEPTH-1) <= readPtrGraySync1(FIFO_DEPTH-1);
    gray2binW : for i in FIFO_DEPTH-2 downto 0 generate
        readPtrBin(i) <= readPtrBin(i+1) xor readPtrGraySync1(i);
    end generate;
    --set sig_full flag
    sig_full <= '1' when writePtr + '1' = syncReadPtrBin else '0';
    full <= sig_full;
    
    read_side : process(clkr)
    begin
        if rising_edge(clkr) then
            if rst = '1' then
                readPtr <= (others => '0');
                readPtrGray <= (others => '0');
                syncWritePtrBin <= (others => '0');
                writePtrGraySync0 <= (others => '0');
                writePtrGraySync1 <= (others => '0');
            else
                -- read pointer handling
                if rd = '1' and not sig_empty = '1' then
                    readPtr <= readPtr + '1';
                end if;
                --read pointer to gray code conversion
                readPtrGray <= readPtr xor ('0' & readPtr(FIFO_DEPTH-1 downto 1));
                --gray coded write pointer synchronisation
                writePtrGraySync0 <= writePtrGray;
                writePtrGraySync1 <= writePtrGraySync0;
                --register write pointer in order to be resetable
                syncWritePtrBin <= writePtrBin;
            end if;
        end if;
    end process;
    --write pointer to binary conversion
    writePtrBin(FIFO_DEPTH-1) <= writePtrGraySync1(FIFO_DEPTH-1);
    gray2binR : for i in FIFO_DEPTH-2 downto 0 generate
        writePtrBin(i) <= writePtrBin(i+1) xor writePtrGraySync1(i);
    end generate;
    --set sig_empty flag
    sig_empty <= '1' when readPtr = syncWritePtrBin else '0';
    empty <= sig_empty;
    
    dual_port_ram : process(clkw)
    begin
        if rising_edge(clkw) then
            if wr = '1' and not sig_full = '1' then
                mem(conv_integer(writePtr)) <= din;
            end if;
      end if;
    end process;
    dout <= mem(conv_integer(readPtr));
    
end Behavioral;