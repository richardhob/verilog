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
    initial index = 1;
    initial counter = 0;

    // Counter
    always @(posedge i_clk)
        assert(counter <= THRESHOLD);

    always @(posedge i_clk)
    begin
        if (counter < THRESHOLD)
            counter <= counter + 1;
        else
        begin
            counter <= 0;
        end
    end

    // Update Index
    always @(posedge i_clk)
    begin
        if (counter == THRESHOLD)
        begin
           if (direction == 0) index <= index + 1;
           else index <= index - 1;
        end
    end

    always @(posedge i_clk)
        assert((index >= 1) && (index <= WIDTH));

    // Update Direction
    always @(posedge i_clk)
    begin
        if (counter == THRESHOLD)
        begin
            if (index == (WIDTH - 1))
                direction <= 1;
            else if (index == 2) 
                direction <= 0;
        end
    end

    always @(posedge i_clk)
    begin
        if (index == WIDTH) assert(direction == 1);
        if (index == 1) assert(direction == 0);
    end

    // Output LEDs
    assign o_led = data;

    always @(posedge i_clk)
        data <= 1 << (index - 1);

    reg f_valid_output;

    always @(*)
    begin
	    f_valid_output = 0;
	    case(o_led)
            8'h01: f_valid_output = 1'b1;
            8'h02: f_valid_output = 1'b1;
            8'h04: f_valid_output = 1'b1;
            8'h08: f_valid_output = 1'b1;
            8'h10: f_valid_output = 1'b1;
            8'h20: f_valid_output = 1'b1;
            8'h40: f_valid_output = 1'b1;
            8'h80: f_valid_output = 1'b1;
            default: f_valid_output = 1'b0;
        endcase
        assert(f_valid_output);
    end

endmodule
