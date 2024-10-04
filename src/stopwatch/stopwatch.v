`default_nettype none

module stopwatch(i_clk, i_start, i_stop, o_data);
    input wire i_clk;
    input wire i_start;
    input wire i_stop;

    output wire [31:0] o_data;

    parameter DEBOUNCE  = 3;

    reg [31:0] counter;
    reg [31:0] debounce_counter;
    reg [1:0]  debounce_state;

    reg running;

    initial counter = 0;
    initial debounce_counter = 0;
    initial debounce_state = 0;

    initial running = 0;

    assign o_data = counter;

    always @(posedge i_clk)
    begin
        if ((i_start == 1) || (i_stop == 1))
            debounce_state <= 1;

        if (debounce_state == 1)
            debounce_counter <= debounce_counter + 1;

        if (debounce_counter >= DEBOUNCE)
            debounce_state <= 2;

        if (debounce_state == 2)
        begin
            if ((i_start == 1) && (i_stop == 0) && (running == 0)) 
                running <= 1;
            else if ((i_start == 0) && (i_stop == 1) && (running == 1))
                running <= 0;
            else if ((i_start == 0) && (i_stop == 1) && (running == 0))
                counter <= 0;

            // Reset the debounce counter
            debounce_state <= 0;
            debounce_counter <= 0;
        end

        if (running == 1) counter <= counter + 1'b1;
    end

endmodule
