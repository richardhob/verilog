
#include <stdio.h>
#include <stdlib.h>

#include "Vmaskbus.h"
#include "verilated.h"

int main(int argc, char ** argv) 
{
    Verilated::commandArgs(argc, argv);
    Vmaskbus *tb = new Vmaskbus;

    printf("k, sw, led\n");
    for(int k=0; k<20; k++)
    {
        tb->i_sw = k & 0x1FF;
        tb->eval();

        printf("%d, 0x%02x, 0x%02x\n", k, tb->i_sw, tb->o_led);
    }
}
