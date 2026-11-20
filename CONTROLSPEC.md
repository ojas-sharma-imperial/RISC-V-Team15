# Control Logic Specifications

This document outlines the control logic specifications, so that other hardware can be designed to work around this. The outputs of the control unit will be specified such that the interfaces between control logic and all data path elements is clearly defined prior to the design of such data path elements. Importantly these will be defined prior to any integration/system testing phases.

## MUX Source Signals

### `alu_src_1`

`alu_src_1[1:0]`: set to 0 when the ALU is using a register value from port 1 and set to 1 when the program counter value is used. It is set to 2 when the constant `32'b0` is loaded. It is undefined when set to 3.

### `alu_src_2`

`alu_src_2[0]`: set to 0 when the ALU is using a register value from port 2 as `alu_op2` and set to 1 when an immediate value is used.

### `pc_src`

`pc_src[0]`: set to 0 during regular operation of the program counter, such that it is incremented by 4 words each cycle. It is set to 1 when a jump/branch offset is required.

### `result_src`

`result_src[1:0]`: set to 0 in common-case, allowing ALU-processed data to be written back into the regfile. It is set to 1 during memory load operations, allowing data read from memory to be put into the regfile. It is set to 2 when the program counter is to be stored into the regfile. It is undefined when set to 3.

## Sign-Extensions

The control unit outputs a signal `imm_src[2:0]` to control the `sign_extend` module. The RISCV ISA outlines 6 types of instruction, and using these any immediate values can be sign-extended as necessary. The values of `imm_src[2:0]` are outlined in the table below:
isbjur

| Instruction Type | `imm_src[2:0]` | Sign Extension Type |
| :---: | :---: | :---:|
| I | 0 | Sign extension from 12-bit |
| S | 1 | Sign extension from 12-bit |
| B | 2 | Sign extension from 12-bit, discarding LSB |
| J | 3 | Sign extension from 20-bit, discarding LSB |
| U | 4 | Shift 20-bit left and fill least-significant 12-bits with 0 |
| R | 5 | No sign extension as from register, index 5 used elsewhere |
| SYS | 6 | I-style instruction encoding with no sign extension |
| - | 7 | UNUSED |

## Write-Enable Signals

The two write-enable signals `mem_wen` and `reg_wen` are active HIGH signals that control when the memory and regfile should synchronously store data, respectively.

## `branch` Signal

This is a signal to allow the simplification of the ALU logic, allowing hardware to be reused. When a branch is being executed this signal is set to 1. If the ALU subsequently recieves a `funct3` corresponding to a ADD/SUB R-type instruction the ALU traets this as always being a subtraction. This is required due to the R-type subtraction instruction having the same `funct3` value as the R-type addition instruction. This simplification is possible only because the branch instructions will never require an addition operation, since only the magnitude comparison operators (for BLT[U]/BGE[U]) and subtraction (for BEQ/BNE). This signal may be used in future to allow the system to stall at pipeline hazards, or as a MUX control signal.