---------------------------------------------------------------------------
-- adder_16b.vhd - 16-bit Adder Implementation
--
--
-- Copyright (C) 2006 by Lih Wen Koh (lwkoh@cse.unsw.edu.au)
-- All Rights Reserved. 
--
-- The single-cycle processor core is provided AS IS, with no warranty of 
-- any kind, express or implied. The user of the program accepts full 
-- responsibility for the application of the program and the use of any 
-- results. This work may be downloaded, compiled, executed, copied, and 
-- modified solely for nonprofit, educational, noncommercial research, and 
-- noncommercial scholarship purposes provided that this notice in its 
-- entirety accompanies all copies. Copies of the modified software can be 
-- delivered to persons who use it solely for nonprofit, educational, 
-- noncommercial research, and noncommercial scholarship purposes provided 
-- that this notice in its entirety accompanies all copies.
--
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adder_16b is
    port ( src_a     : in  std_logic_vector(15 downto 0);
           src_b     : in  std_logic_vector(15 downto 0);
           sum       : out std_logic_vector(15 downto 0);
           carry_out : out std_logic );
end adder_16b;

architecture behavioural of adder_16b is

signal sig_result : std_logic_vector(16 downto 0);

begin

    sig_result <= ('0' & src_a) + ('0' & src_b);
    sum        <= sig_result(15 downto 0);
    carry_out  <= sig_result(16);
    
end behavioural;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.alu_op_pkg.all;
ENTITY arithmetic_logic IS
    PORT (src_a     : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          src_b     : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          mode      : IN alu_op_type;
          res       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          cout      : OUT STD_LOGIC);
END arithmetic_logic;

ARCHITECTURE Behavior OF arithmetic_logic IS
signal sig_result : std_logic_vector(16 downto 0);
BEGIN
    res <= sig_result(15 DOWNTO 0);
    cout <= sig_result(16);
    calculate: PROCESS (src_a, src_b, mode)
    BEGIN
        sig_result <= '0' & x"0000";
        CASE mode IS
        WHEN DO_ADD =>
            sig_result <= std_logic_vector(unsigned('0' & src_a) + unsigned('0' & src_b));
        WHEN DO_SLT =>
            IF (signed(src_a) < signed(src_b)) THEN
                sig_result(0) <= '1';
            END IF;
        WHEN OTHERS =>
        END CASE;
    END PROCESS;
END Behavior;