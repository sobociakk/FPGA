#include <iostream>
#include <memory>
#include "Vcounter.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char** argv) {
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    contextp->commandArgs(argc, argv);
    contextp->traceEverOn(true);
    const std::unique_ptr<Vcounter> top{new Vcounter{contextp.get(), "TOP"}};
    
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");
    
    top->clk = 0;
    top->rst_n = 0;
    
    while (!contextp->gotFinish() && contextp->time() < 40) {
        contextp->timeInc(1);
        top->clk = !top->clk;
        if (contextp->time() > 4) {
            top->rst_n = 1;
        }
        top->eval();
        tfp->dump(contextp->time());
    }
    
    top->final();
    tfp->close(); 
    delete tfp;
    
    std::cout << "Symulacja zakonczona! Przebiegi zapisano w pliku 'waveform.vcd'." << std::endl;
    return 0;
}
