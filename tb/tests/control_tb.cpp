// TESTBENCH FOR control.sv MODULE

#include "base_testbench.h"

unsigned int ticks = 0;

struct Instr {
    int opcode;
    int funct3;
};

// U-type
const Instr LUI   = {0x37, 0};
const Instr AUIPC = {0x17, 0};

// Jumps
const Instr JAL   = {0x6F, 0};
const Instr JALR  = {0x67, 0b000};

// Branches
const Instr BEQ   = {0x63, 0b000};
const Instr BNE   = {0x63, 0b001};
const Instr BLT   = {0x63, 0b100};
const Instr BGE   = {0x63, 0b101};
const Instr BLTU  = {0x63, 0b110};
const Instr BGEU  = {0x63, 0b111};

// Load and store (control ignores funct3, so one of each)
const Instr LW    = {0x03, 0b010};
const Instr SW    = {0x23, 0b010};

// ALU immediate (two values to check funct3 passes through)
const Instr ADDI  = {0x13, 0b000};
const Instr XORI  = {0x13, 0b100};

// ALU register
const Instr ADD   = {0x33, 0b000};
const Instr AND   = {0x33, 0b111};

// Invalid opcode, for the "nothing gets written" test
const Instr INVALID = {0x00, 0};
// Every output of control, in one place

struct ControlOut {
    int pc_src, result_src, alu_src_1, alu_src_2,
        imm_src, alu_control, mem_wen, reg_wen, branch;
};

class ControlTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->instruction = 0;
        top->funct3 = 0;
        top->funct7 = 0;
        top->zero = 0;
        top->rst = 0;
    }

    // Apply inputs, evaluate (combinational, no clock), check every output
    void check(Instr op, int zero, ControlOut exp)
    {
        top->instruction = in.opcode;
        top->funct3 = in.funct3;
        top->zero = zero;
        top->eval();

        EXPECT_EQ(top->pc_src,      exp.pc_src);
        EXPECT_EQ(top->result_src,  exp.result_src);
        EXPECT_EQ(top->alu_src_1,   exp.alu_src_1);
        EXPECT_EQ(top->alu_src_2,   exp.alu_src_2);
        EXPECT_EQ(top->imm_src,     exp.imm_src);
        EXPECT_EQ(top->alu_control, exp.alu_control);
        EXPECT_EQ(top->mem_wen,     exp.mem_wen);
        EXPECT_EQ(top->reg_wen,     exp.reg_wen);
        EXPECT_EQ(top->branch,      exp.branch);
    }
};

//                 pc  res  a1  a2  imm  aluc  mw  rw  br
TEST_F(ControlTestbench, LUI)
{
    check(LUI, 0, {0,   0,  2,  1,  4,   0,    0,  1,  0});
}

TEST_F(ControlTestbench, BEQ_NotTaken)
{
    check(BRANCH, 0, {0, 0, 0, 0, 2, 0, 0, 0, 1});
}

TEST_F(ControlTestbench, BEQ_Taken)
{
    check(BRANCH, 1, {1, 0, 0, 0, 2, 0, 0, 0, 1});
}

TEST_F(ControlTestBench, ALU_REG)
{
    check(ADD, 0, {0, 0, 0, 0, 0, 0, 0, 1, 0})
}

// Your fix: reset must block all writes, even for an instruction that writes
TEST_F(ControlTestbench, ResetBlocksWrites)
{
    top->rst = 1;
    top->instruction = OP_ALUREG;
    top->eval();
    EXPECT_EQ(top->reg_wen, 0);
    EXPECT_EQ(top->mem_wen, 0);
}

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}