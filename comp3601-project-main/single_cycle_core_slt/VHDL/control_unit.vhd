---------------------------------------------------------------------------
-- control_unit.vhd - Control Unit Implementation
--
-- Notes: refer to headers in single_cycle_core.vhd for the supported ISA.
--
--  control signals:
--     reg_dst    : asserted for ADD instructions, so that the register
--                  destination number for the 'write_register' comes from
--                  the rd field (bits 3-0). 
--     reg_write  : asserted for ADD and LOAD instructions, so that the
--                  register on the 'write_register' input is written with
--                  the value on the 'write_data' port.
--     alu_src    : asserted for LOAD and STORE instructions, so that the
--                  second ALU operand is the sign-extended, lower 4 bits
--                  of the instruction.
--     mem_write  : asserted for STORE instructions, so that the data 
--                  memory contents designated by the address input are
--                  replaced by the value on the 'write_data' input.
--     mem_to_reg : asserted for LOAD instructions, so that the value fed
--                  to the register 'write_data' input comes from the
--                  data memory.
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
LIBRARY IEEE;
USE IEEE.std_logic_1164;
PACKAGE alu_op_pkg IS
    TYPE alu_op_type IS (DO_ADD, DO_SLT);
END PACKAGE;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.alu_op_pkg.all;
entity control_unit is
    port ( opcode     : in  std_logic_vector(3 downto 0);
           reg_dst    : out std_logic;
           reg_write  : out std_logic;
           alu_src    : out std_logic;
           alu_op     : out alu_op_type;
           mem_write  : out std_logic;
           signed_byte: OUT STD_LOGIC;
           mem_to_reg : out std_logic );
end control_unit;

architecture behavioural of control_unit is

constant OP_LOAD    : std_logic_vector(3 downto 0) := "0001";
constant OP_LB      : std_logic_vector(3 downto 0) := "0010";
constant OP_STORE   : std_logic_vector(3 downto 0) := "0011";
constant OP_ADD     : std_logic_vector(3 downto 0) := "1000";
constant OP_SLT     : std_logic_vector(3 downto 0) := "1010";

begin

    fat_controller: PROCESS (opcode)
    BEGIN
        reg_dst     <= '0';
        reg_write   <= '0';
        alu_src     <= '0';
        mem_write   <= '0';
        signed_byte <= '0';
        mem_to_reg  <= '0';
        alu_op      <= DO_ADD;
        CASE opcode IS
        WHEN OP_LOAD =>
            reg_write   <= '1';
            alu_src     <= '1';
            alu_op      <= DO_ADD;
            mem_to_reg  <= '1';
        WHEN OP_LB =>
            reg_write   <= '1';
            alu_src     <= '1';
            alu_op      <= DO_ADD;
            mem_to_reg  <= '1';    
            signed_byte <= '1';   
        WHEN OP_STORE =>
            alu_src     <= '1';
            alu_op      <= DO_ADD;
            mem_write   <= '1';
        WHEN OP_ADD =>
            reg_dst     <= '1';
            reg_write   <= '1';
            alu_op      <= DO_ADD;
        WHEN OP_SLT =>
            reg_dst     <= '1';
            reg_write   <= '1';      
            alu_op      <= DO_SLT;
        WHEN OTHERS =>
        END CASE;
    END PROCESS; 
    
end behavioural;
