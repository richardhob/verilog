
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include "Vstopwatch.h"

#include "verilated.h"
#include "verilated_vcd_c.h"

void tick(Vstopwatch * tb, VerilatedVcdC* trace) 
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

    Vstopwatch *tb = new Vstopwatch;

    Verilated::traceEverOn(true);
    VerilatedVcdC* trace = new VerilatedVcdC;
    tb->trace(trace, 99);
    trace->open("waveform.vcd");

    // Features we want to test:
    // 1. Start counter when i_start is set to 1 after 3 debounce cycles
    // 2. Stop counter when i_stop is set to 1 after 3 debounce cycles
    // 3. Reset the counter when i_stop is set to 1 after 3 debounce cycles
    // 4. Nothing happens if i_start and i_stop are set

    // 1. Make sure that the counter starts when i_start is started
    tb->i_start = 1;
    tb->i_stop  = 0;

    for (int i = 0; i < 6; i ++)
    {
        tick(tb, trace);
    }

    tb->i_start = 0;
    tb->i_stop  = 0;

    // Counting Up
    for (int i = 0; i < 50; i++)
    {
        assert(tb->o_data == i);
        tick(tb, trace);
    }

    // Stop
    tb->i_start = 0;
    tb->i_stop  = 1;

    for (int i = 0; i < 6; i ++)
    {
        tick(tb, trace);
    }

    // Stopped
    uint32_t value = tb->o_data;

    tb->i_start = 0;
    tb->i_stop  = 0;

    for (int i = 0; i < 10; i ++)
    {
        tick(tb, trace);
        assert(tb->o_data == value);
    }

    // Reset
    tb->i_start = 0;
    tb->i_stop  = 1;

    for (int i = 0; i < 6; i ++)
    {
        tick(tb, trace);
    }

    assert(tb->o_data == 0);

    printf("OK\n");

    return 0;
}

// EOF
