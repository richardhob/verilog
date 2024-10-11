`default_nettype none

module counter(i_clk, i_start_signal, o_busy);
    input wire i_clk;
    input wire i_start_signal;
    output wire o_busy;

    parameter [15:0] MAX_AMOUNT = 22;
    reg [15:0] counter;

    initial counter = 0;

    always @(posedge i_clk)
    if ((i_start_signal)&&(counter == 0))
        counter <= MAX_AMOUNT - 1'b1;
    else if (counter != 0)
        counter <= counter - 1'b1;

    always @(*)
        o_busy = (counter != 0);

    `ifdef FORMAL
    always @(*)
        assert(counter < MAX_AMOUNT);
    `endif
endmodule
