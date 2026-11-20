#include "Vpc.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char** argv, char **env) {
    int i;
    int clk;

    Verilated::commandArgs(argc, argv);
    Vpc* top = new Vpc;
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace (tfp, 99);
    tfp->open ("counter.vcd");

    top->clk = 1;
    top->rst = 1;
    top->imm_op = 25;
    top-> pc_src = 0;
    top->pc_output = 0;

    for (i=0; i<300; i++) {

        for (clk=0;  clk<2; clk++){
            tfp->dump (2*i+clk);
            top->clk = !top->clk;
            top->eval ();
        }
        top->rst = (i <2) | (i==15);
        top->pc_src = (i == 6) | (i == 12);
        if (Verilated::gotFinish()) exit(0);
    }
    tfp->close();
    exit(0);
}