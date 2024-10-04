`default_nettype none

module shift(i_clk, o_led);
    parameter WIDTH = 8;
    parameter THRESHOLD = 2;

    input i_clk;
    output [(WIDTH - 1):0] o_led;

    reg direction;
    reg [(WIDTH - 1):0] index;
    reg [31:0] counter;
    reg [(WIDTH - 1):0] data;

    initial data = 1;
    initial direction = 0;
    initial index = 0;
    initial counter = 0;

    // Counter
    always @(posedge i_clk)
    begin
        if (counter <= THRESHOLD)
            counter <= counter + 1;
        else
        begin
            counter <= 0;
        end
    end

    // Update Index
    always @(posedge i_clk)
    begin
        if ((counter == THRESHOLD) && (direction == 0))
            index <= index + 1;
        else if ((counter == THRESHOLD) && (direction == 1))
            index <= index - 1;
    end

    // Update Direction
    always @(posedge i_clk)
    begin
        if ((index == (WIDTH - 1)) && (counter == THRESHOLD))
            direction <= 1;
        else if ((index == 1) && (counter == THRESHOLD))
            direction <= 0;
    end

    // Output LEDs
    assign o_led = data;

    always @(posedge i_clk)
    begin
        data <= 1 << (index - 1);
    end

endmodule
