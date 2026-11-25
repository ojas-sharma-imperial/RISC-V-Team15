// TESTBENCH FOR pc.sv MODULE

#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;
unsigned const int BOOT_VECTOR = 0xBFC00000;

class PCTestBench : public BaseTestbench
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
        top->pc_src = 0;
        top->pc_target = 0;
    }
    void runReset()
    {
        top->rst = 1;
        for (int i = 0; i < 5; i++) { // 5 cycle reset
            runSimulation();
        }
        top->rst = 0;
    }
    void runSimulation(int cycles = 1)
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

TEST_F(PCTestBench, RESET_TEST)
{
    EXPECT_EQ(top->pc_output, BOOT_VECTOR);
}

TEST_F(PCTestBench, NORMAL_ADVANCE_TEST)
{
    runSimulation();
    EXPECT_EQ(top->pc_output, BOOT_VECTOR+4);
}

TEST_F(PCTestBench, OFFSET_TEST)
{
    top->pc_src = 1; // pc offset taken
    top->pc_target = 0x50;
    runSimulation();
    EXPECT_EQ(top->pc_output, BOOT_VECTOR+0x50);
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
