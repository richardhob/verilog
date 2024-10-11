`default_nettype none

module double_pipe(i_clk, i_ce, i_data, o_data);
    input wire i_clk;
    input wire i_ce;
    input wire i_data;
    output reg o_data;

	wire a_data, b_data;

    linear_feedback_shift one(i_clk, 1'b0, i_ce, i_data, a_data);
    linear_feedback_shift two(i_clk, 1'b0, i_ce, i_data, b_data);

    initial o_data = 1'b0;
    always @(posedge i_clk)
        o_data <= a_data ^ b_data;

    `ifdef FORMAL

    reg f_valid_output;
    initial f_valid_output = 0;

    always @(posedge i_clk)
        f_valid_output <= 1;

    always @(posedge i_clk)
        if ((f_valid_output) && (i_ce))
            assert(o_data == 0);

    `endif

endmodule
