// TESTBENCH FOR sign_extend.sv MODULE 

#include "base_testbench.h"

const Imm_I = 0;
const Imm_U = 4;
const Imm_S = 1;
const Imm_B = 2;
const Imm_J = 3;

class SignExtendTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->instr = 0;
        top->imm_src = 0;
    }

    void check(int instr, int imm_src, int ext_im)
    {
        top->instr = instr;
        top->imm_src = imm_src;
        top->eval();

        EXPECT_EQ(top->ext_im, ext_im);
    }
};

TEST_F(SignExtendTestBench, Imm_I)