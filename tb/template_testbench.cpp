// TESTBENCH FOR example.sv MODULE

#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class EXAMPLETestBench : public BaseTestbench
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
        top->sel = 0;
        top->in0 = 0;
        top->in1 = 0;
        // output: out
    }
    void runReset()
    {
        // all combinational logic so no reset
    }
};

TEST_F(EXAMPLETestBench, EXAMPLE_TEST)
{
    top->sel = 0;
    top->in0 = 1;
    top->in1 = 0;

    top->eval();
    runSimulation();

    EXPECT_EQ(top->out, 1);
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
