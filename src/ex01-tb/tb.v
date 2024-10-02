
`define ASSERT_EQ(signal, expected, msg) \
    if ((signal) !== (expected)) $fatal("ASSERTION FAILED: %s at time %0t. Expected: %0d, Got: %0d", msg, $time, expected, signal);

module tb;
  reg a, b;

  thruwire dut(.i_sw(a), .o_led(b));
  initial begin
    a = 0;
    $display("TB");
    $display("t, a, b");
    $monitor("%0t, %0d, %0d", $time, a, b);

    #10 a = 1;
    #20 a = 0;
    #30 a = 1;
    #40 a = 0;
    `ASSERT_EQ(1, 0, "FAIL");
    #50 $finish;
  end
endmodule
