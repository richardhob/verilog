#include <stdio.h>
#include <stdlib.h>
#include "Vthruwire.h"
#include "verilated.h"

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  Vthruwire *tb = new Vthruwire;
  
  printf("k, i_sw, o_led\n");
  for (int i = 0; i < 20; i++) {
    tb->i_sw = i & 0x00001;
    tb->eval();

    printf("%d, %d, %d\n", i, tb->i_sw, tb->o_led);
  }
}
