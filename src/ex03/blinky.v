`default_nettype none

module blinky(i_clk, o_led);
    input wire i_clk;
    output wire o_led;

    parameter THRESHOLD = 100_000_000;

    reg out;
    reg [31:0] counter;

    initial counter = 0;
    initial out = 0;

    assign o_led = out;

    always @(posedge i_clk)
        if (counter > THRESHOLD)
        begin
            counter <= 0;
            out <= !out;
        end else counter <= counter + 1'b1;

endmodule
