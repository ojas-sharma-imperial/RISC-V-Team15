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
        top->clk = 0;
        top->rst = 0;
    }
    void runReset()
    {
        top->rst = 1;
        runSimulation(5); // 5 clock cycle reset
        top->rst = 0;
    }
    void runSimulation(int cycles = 1) // remove if not combinational only
    {
        for (int i = 0; i < cycles; i++) {
            for (int clk = 0; clk < 2; clk++) {
                top->eval();
                #ifndef __APPLE__
                tfp->dump(2 * ticks + clk);
                #endif
                top->clk = !top->clk;
            }
            ticks++;
            if (Verilated::gotFinish()) {
                exit(0);
            }
        }
    }
};

TEST_F(EXAMPLETestBench, EXAMPLE_TEST)
{
    top->eval(); // use this for combinational only
    runSimulation(); // use this if clocked

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
