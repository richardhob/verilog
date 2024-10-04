# Registers and Logic

There are two types of logic that can happen (which we've covered previously)
which are used with Registers

1. Combinational Logic (`always @(*)`) 
2. Synchronous Logic (`always @(posedge i_clk)`) 

Combinational logic acts like "wires", and can be easier to read when logic
becomes complex.

Synchronous logic only changes values on a clock.

Registers can only be assigned in always blcoks, and always blcoks may consist
of one or many statments. To make many statements requires a `begin` and `end`
statement:

``` verilog
    // Combinational
    always @(*)
    begin
        o_led = A ^ i_sw;
        o_led = o_led + 7
        if (i_reset) 
            o_led = 0;
    end
```

This block acts as if all statements were done at the same time.

## Latches are Bad

The following code creates a Latch. A Latch is bad because the timing cannot be
synchonized (which is kinda required for a clocked system):

``` verilog
    input wire i_S;
    input wire [7:0] i_V;
    output reg [7:0] o_R;

    always @(*)
    if (i_S)
        o_R = i_V;
```

This should be written instead as:

``` verilog
    input wire i_S;
    input wire [7:0] i_V;
    output reg [7:0] o_R;

    always @(*)
    begin
        o_R = 0;
        if (i_S)
            o_R = i_V;
    end
```

This is better because:

- our register has a default value
- no memory is required
- A latch is not inferred

It's nice that the final assignment is the last statement as well...

## Non-Blocking vs. Blocking

Any registers set within an `always @(posedge xclk)` block will transition to
their new value on the next clock edge only. Only a REAL clock edge should be
used. 

DO NOT TRANSITION ON ANYTHING YOU CREATE IN LOGIC

``` verilog
    input wire i_clk;
    reg [9:0] A;

    always @(posedge i_clk)
        A <= A + 1'b1;
```

The `<=` assignment is a "non-blocking" assignment. Most clocked registers
should be done in this way.

One more thing to note is that the Last non-blocking assignment is the only one
that will "work". Take for example:

``` verilog
    always @(posedge i_clk)
    begin 
        A <= 5;
        A <= A + 1'b1;
    end
```

The `A` register will take the value `A + 1'b1`. The `A <= 5` statement is
ignored.

A Blocking assignment's value may be referenced again before the clock edge,
which creates the appearance of time passing within the block. BUT this can
cause a simulation and hardware mismatch. 

Let's use a blocking assignment instead of a non-blocking one:

``` verilog
    always @(posedge i_clk)
    begin 
        A = 5;
        A = A + 1'b1;
    end
```

In this example, the `A` register is set to 6.

Here's where it gets weird: let's use the `A` register in another always block:

``` verilog
    always @(posedge i_clk)
    begin 
        A = 5;
        A = A + 1'b1;
    end

    always @(posedge i_clk)
        B <= A
```

What is the value for the `B` register? In some simulations `B` can be 0, or it
may be set to 6.

What would `B` be if we used a non-blocking assignment? Let's assume that `A` is 
0 before the first clock:

``` verilog
    always @(posedge i_clk)
    begin 
        A = 5; // Ignored!
        A = A + 1'b1;
    end

    always @(posedge i_clk)
        B <= A
```

Output:

```
clk, A, B
0,   0, 0
1,   1, 0
2,   2, 1
3,   3, 2
```

In short, always use `<=` within an `always @(posedge i_clk)`.

Other notes:

A design may contain many `always` blocks. Hardware will execute all `always`
blocks at one, whereas the simulator will execute one at a time.

When using the simulator:

- Make sure your design can be synthesized
- Make sure it fits within your device
- Make sure it maintains an appropriate clock rate

## Feedback Paths

Wires in a loop create a circular logic. Clock registers in a loop creates
feedback:

``` verilog
    assign err = i_actual - o_command;

    always @(posedge i_clk)
    begin
        o_command <= o_command + (err >> 5);
    end
```

Feedback is commonly used in control systems.

## FINALLY BLINKY

Let's do Blinky!

``` verilog
module blinky(i_clk, o_led);
    input wire i_clk;
    output wire o_led;

    reg [26:0] counter;
    initial counter = 0;
    always @(posedge i_clk)
        counter <= counter + 1'b1;

    assign o_led = counter[26];
endmodule
```

In short, the LED is toggled when the 26th Bit of the counter toggled. Neat.
How do we simulate this? We need a `tick` function:

``` cpp
void tick(VBlinky *tb) 
{
    tb->eval();
    tb->i_clk = 1;
    tb->eval();
    tb->i_clk = 0;
    tb->eval();
}
```

But this will still take FOREVER on the computer. So let's add a `WIDTH`
parameter to reduce the counter size for simulation:

``` verilog
module blinky(i_clk, o_led);
    ...

    parameter WIDTH=27
    reg [WIDTH-1:0] counter;

    ...

    assign o_led = counter[WIDTH-1];
endmodule
```

We can specify the `WIDTH` at compile time in verilator:

``` bash
> verilator -Wall -GWIDTH=12 -cc blinky.v ...
```

## Add a Trace File

Requires the `--trace` flag:

``` bash
> verilator --trace blinky.v ...
```

And requires adding a few Main lines:

``` cpp
#include "verilated_vcd_c.h"

...

int main(int argc, char ** argv)
{
    ...
    Verilated::traceEverOn(true);
    VerilatedVcdC* trace = new VerilatedVcdC;
    tb->trace(trace, 99);
    trace->open("waveform.vcd");

    ...
```

We also get to update the `tick` function. 

``` cpp
void tick(Vblinky* tb, VerilatedVcdC* trace) 
{
    static uint32_t tick = 1;
    tb->eval();

    // 2ns Before the tick
    if (trace) trace->dump(tick * 10 - 2)

    tb->i_clk = 1;
    tb->eval();

    // 10ns Tick 
    if (trace) trace->dump(tick * 10)
    
    tb->i_clk = 0;
    tb->eval();

    // Trailing Edge
    if (trace) 
    {
        trace->dump(tick * 10 + 5)
        trace->flush();
    }

    tick = tick + 1;
}
```

## Blick Every Second

We can update the system to blink every second using an `integer clock divider`
structure:

``` verilog
    parameter CLOCK_RATE_HZ = 100_000_000;
    always @(posedge i_clk)
    begin
        if (counter >= CLOCK_RATE_HZ/2 - 1)
        begin
            counter <= 0;
            o_led <= !o_led;
        end 
        else counter <= counter + 1;
    end
```

We could also use a `fractional clock divider`:

``` verilog
    ...

    parameter CLOCK_RATE_HZ = 100_000_000;
    parameter [31:0] INCREMENT = (1 << 30) / (CLOCK_RATE_HZ/4);

    reg [31:0] counter;

    initial counter = 0;
    always @(posedge i_clk)
        counter <= counter + INCREMENT;

    assign o_led = counter[31];
```


