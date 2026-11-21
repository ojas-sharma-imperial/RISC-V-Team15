// TESTBENCH FOR alu.sv MODULE

#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;
unsigned const int N = 5; // test cases for ALU numbers

class ALUTestBench : public BaseTestbench
{
protected:
    void SetUp() override
    {
        BaseTestbench::SetUp();
        runReset();
        initializeInputs();
    }
    void initializeInputs() override
    {
        top->alu_src_2 = 0;
        top->branch = 0;
        top->alu_op1 = 0;
        top->alu_op2 = 0;
        top->alu_control = 0;
        top->funct7 = 0;
    }
    void runReset()
    {
        // all combinational logic so no reset
    }
public:
    void alu_reg_reg(int opcode, int funct7, int op1, int op2, int exp_res, int exp_zero) {
        top->alu_src_2 = 0; // reg-reg
        top->branch = 0;
        top->alu_op1 = op1;
        top->alu_op2 = op2;
        top->alu_control = opcode;
        top->funct7 = funct7;

        top->eval();
        EXPECT_EQ(top->alu_out, exp_res);
        EXPECT_EQ(top->zero, exp_zero);
    }
};

TEST_F(ALUTestBench, ADDITION_TEST)
{
    const int OPCODE = 0x0;
    const int FUNCT7 = 0x0;
    int exp_result;
    for (int i=-N; i<N; i++) {
        for (int j=-N; j<N; j++) {
            exp_result = i+j;
            alu_reg_reg(OPCODE, FUNCT7, i, j, exp_result, (exp_result == 0));
        }
    }
}

TEST_F(ALUTestBench, SUBTRACTION_TEST)
{
    const int OPCODE = 0x0;
    const int FUNCT7 = 0x20;
    int exp_result;
    for (int i=-N; i<N; i++) {
        for (int j=-N; j<N; j++) {
            exp_result = i-j;
            alu_reg_reg(OPCODE, FUNCT7, i, j, exp_result, (exp_result == 0));
        }
    }
}

TEST_F(ALUTestBench, SLL_TEST)
{
    const int OPCODE = 0x1;
    const int FUNCT7 = 0x0;
    int exp_result;
    for (int i=-N; i<N; i++) {
        for (int j=-N; j<N; j++) {
            exp_result = i<<j;
            alu_reg_reg(OPCODE, FUNCT7, i, j, exp_result, (exp_result == 0));
        }
    }
}

TEST_F(ALUTestBench, SLTU_TEST)
{
    const int OPCODE = 0x3;
    const int FUNCT7 = 0x0;
    unsigned int exp_result;
    for (unsigned int i=-N; i<N; i++) {
        for (unsigned int j=-N; j<N; j++) {
            exp_result = (i < j) ? 0x1 : 0x0;
            alu_reg_reg(OPCODE, FUNCT7, i, j, exp_result, (exp_result == 0));
        }
    }
}

TEST_F(ALUTestBench, XOR_TEST)
{
    const int OPCODE = 0x4;
    const int FUNCT7 = 0x0;
    int exp_result;
    for (int i=-N; i<N; i++) {
        for (int j=-N; j<N; j++) {
            exp_result = i ^ j;
            alu_reg_reg(OPCODE, FUNCT7, i, j, exp_result, (exp_result == 0));
        }
    }
}

TEST_F(ALUTestBench, SRL_TEST)
{
    const int OPCODE = 0x5;
    const int FUNCT7 = 0x0;
    unsigned int exp_result;
    for (unsigned int i=-N; i<N; i++) {
        for (unsigned int j=-N; j<N; j++) {
            exp_result = i >> j;
            alu_reg_reg(OPCODE, FUNCT7, i, j, exp_result, (exp_result == 0));
        }
    }
}

TEST_F(ALUTestBench, SRA_TEST)
{
    const int OPCODE = 0x5;
    const int FUNCT7 = 0x20;
    int exp_result;
    for (int i=-N; i<N; i++) {
        for (int j=-N; j<N; j++) {
            exp_result = i >> j;
            alu_reg_reg(OPCODE, FUNCT7, i, j, exp_result, (exp_result == 0));
        }
    }
}

TEST_F(ALUTestBench, OR_TEST)
{
    const int OPCODE = 0x6;
    const int FUNCT7 = 0x0;
    int exp_result;
    for (int i=-N; i<N; i++) {
        for (int j=-N; j<N; j++) {
            exp_result = i | j;
            alu_reg_reg(OPCODE, FUNCT7, i, j, exp_result, (exp_result == 0));
        }
    }
}

TEST_F(ALUTestBench, AND_TEST)
{
    const int OPCODE = 0x7;
    const int FUNCT7 = 0x0;
    int exp_result;
    for (int i=-N; i<N; i++) {
        for (int j=-N; j<N; j++) {
            exp_result = i & j;
            alu_reg_reg(OPCODE, FUNCT7, i, j, exp_result, (exp_result == 0));
        }
    }
}

int main(int argc, char **argv)
{
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    top->final();
    tfp->close();

    delete top;
    delete tfp;

    return res;
}


