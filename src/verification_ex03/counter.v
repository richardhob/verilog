`default_nettype none

module counter(i_clk, i_reset, i_start_signal, o_busy);
    input wire i_clk;
    input wire i_reset;
    input wire i_start_signal;
    output reg o_busy;

    parameter [15:0] MAX_AMOUNT = 22;
    reg [15:0] counter;

    initial counter = 0;

    always @(posedge i_clk)
        if(i_reset)
            counter <= 0;
        else if ((i_start_signal) && (counter == 0))
            counter <= MAX_AMOUNT - 1'b1;
        else if (counter != 0)
            counter <= counter - 1'b1;

    always @(posedge i_clk)
        if (!i_reset)
            if ((i_start_signal) || (0 < counter))
                o_busy <= 1'b1;
            else 
                o_busy <= 1'b0;
        else
            o_busy <= 1'b0;

    `ifdef FORMAL

    reg f_past_valid;
    initial f_past_valid = 1'b0;

    always @(posedge i_clk)
        f_past_valid <= 1'b1;

    // 1. i_start_signal may be raised at any time
    // 
    // This specifically assumes that i_start_signal is 0 when f_past_valid
    //
    // <No property needed>

    // 2. Once i_start_signal is raised, assume it will remain high until it is
    //    high and the counter is no longer busy
    always @(posedge i_clk)
        if ((f_past_valid) && (i_start_signal) && (!i_reset))
            assert(counter < MAX_AMOUNT);


    // 3. o_busy will always be true while the counter is non-zero. Make
    //    sure you check o_busy when counter == 0 and counter != 0
    always @(posedge i_clk)
        if ((f_past_valid) && (i_start_signal) && (!i_reset))
            if ((0 < counter) && (counter < MAX_AMOUNT))
                assert(o_busy == 1);
            else if (0 == counter)
                assert(o_busy == 0);

    // 4. If the counter is non-zero, it should always be counting down
    //    (beware of the reset!)
    always @(posedge i_clk)
        if ((f_past_valid) && (!i_reset) && (!$past(i_reset)) && ($past(counter) > 0))
            assert(counter == ($past(counter) - 1'b1));

    `endif
endmodule
