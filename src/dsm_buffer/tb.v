
`define ASSERT_EQ(signal, expected, msg) \
    if ((signal) !== (expected)) $fatal("ASSERTION FAILED: %s at time %0t. Expected: %0d, Got: %0d", msg, $time, expected, signal);

module tb;
  reg reset, clk;
  reg reset_144k, clk_144k;
  reg [3:0] dsm_in;
  wire [3:0] dsm_out;

  wire [7:0] save_index;
  wire [7:0] read_index;

  dsm_model dut(
      .internal_rst_n(reset),
      .internal_clk(clk), 
      .internal_bit(dsm_out),

      .external_clk(clk_144k), 
      .external_rst_n(reset_144k),
      .external_bit(dsm_in),

      .save_index(save_index),
      .read_index(read_index)
  );

  initial begin
    $display("Test 0: Save Index");
    $display("t, ext_clk, ext_reset, ext_dsm, save_index, dsm_out");
    $monitor("%0t, %0d, %0d, %0d, %0d, %0d", $time, clk_144k, reset_144k, dsm_in, save_index, dsm_out);

    clk = 0;
    reset = 0;

    clk_144k = 0;
    reset_144k = 0;

    #1 dsm_in = 4'hF;
    #1 clk_144k = 1;
    #1 reset_144k = 0;

    `ASSERT_EQ(save_index, 0, "Expected save_index to reset to 0");
    `ASSERT_EQ(dsm_out, 0, "expected DSM out to be 0");

    #1 reset_144k = 1;
    #1 clk_144k = 0;
    #1 dsm_in = 4'hE;
    #1 clk_144k = 1;
    #1 clk_144k = 0;

    `ASSERT_EQ(save_index, 1, "Expected save_index to to be 1");
    `ASSERT_EQ(dsm_out, 4'hE, "expected DSM out to be 0xE");

    #1 dsm_in = 4'hD;
    #1 clk_144k = 1;
    #1 clk_144k = 0;

    `ASSERT_EQ(save_index, 2, "Expected save_index to to be 2");
    `ASSERT_EQ(dsm_out, 4'hE, "expected DSM out to be 0xE");

    #1 dsm_in = 4'hC;
    #1 clk_144k = 1;
    #1 clk_144k = 0;

    `ASSERT_EQ(save_index, 3, "Expected save_index to to be 2");
    `ASSERT_EQ(dsm_out, 4'hE, "expected DSM out to be 0xE");

    $display("t, int_clk, int_reset, int_dsm, read_index");
    $monitor("%0t, %0d, %0d, %0d, %0d", $time, clk, reset, dsm_out, read_index);

    // Read Index
    #1 reset = 1;
    #1 clk = 0;

    `ASSERT_EQ(read_index, 0, "Expected read_index to be 0");
    `ASSERT_EQ(dsm_out, 4'hE, "expected DSM out to be 0xE");

    #1 clk = 1;
    #1 clk = 0;

    `ASSERT_EQ(read_index, 1, "Expected read_index to be 1");
    `ASSERT_EQ(dsm_out, 4'hD, "expected DSM out to be 0xD");

    #1 clk = 1;
    #1 clk = 0;

    `ASSERT_EQ(read_index, 2, "Expected read_index to be 2");
    `ASSERT_EQ(dsm_out, 4'hC, "expected DSM out to be 0xC");

    
    #50 $finish;
  end
endmodule
