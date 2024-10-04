
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include "Vshift.h"

#include "verilated.h"
#include "verilated_vcd_c.h"

void tick(Vshift* tb, VerilatedVcdC* trace) 
{
    static uint32_t tick = 1;
    tb->eval();

    // 2ns Before the tick
    if (trace) trace->dump(tick * 10 - 2);

    tb->i_clk = 1;
    tb->eval();

    // 10ns Tick 
    if (trace) trace->dump(tick * 10);
    
    tb->i_clk = 0;
    tb->eval();

    // Trailing Edge
    if (trace) 
    {
        trace->dump(tick * 10 + 5);
        trace->flush();
    }

    tick = tick + 1;
}

int main(int argc, char ** argv) 
{
    Verilated::commandArgs(argc, argv);

    Vshift *tb = new Vshift;

    Verilated::traceEverOn(true);
    VerilatedVcdC* trace = new VerilatedVcdC;

    tb->trace(trace, 99);
    trace->open("waveform.vcd");

    for(int i=0; i<100; i++)
    {
        tick(tb, trace);
    }

    printf("OK\n");
}

// EOF
