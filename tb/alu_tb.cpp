#include "Valu.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv, char **env){
    Verilated::commandArgs(argc, argv);
    Valu *top = new Valu;

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("alu.vcd");

    top->alu_op1 = 0;
    top->alu_op2 = 0;
    top->func7 = 0;

    for (int i = 0; i < 30; i++){
        if(i = )
    }
}

