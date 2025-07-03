`default_nettype none

// Dual port ram buffer
//
// The assumption is that the External Part (144k, etc) is able to fill up the
// buffer before reading occurs. All we want to do here is fill up a buffer - we
// don't care too much about LONG continuous conversion. Just create a bigger
// buffer if you need a bigger buffer :)

// Calcualte CLOG2 up to 16 bits
`define CLOG2(x) \
  (x <= 2) ? 1 : \
  (x <= 4) ? 2 : \
  (x <= 8) ? 3 : \
  (x <= 16) ? 4 : \
  (x <= 32) ? 5 : \
  (x <= 64) ? 6 : \
  (x <= 128) ? 7 : \
  (x <= 256) ? 8 : \
  (x <= 512) ? 9 : \
  (x <= 1024) ? 10 : \
  (x <= 2048) ? 11 : \
  (x <= 4096) ? 12 : \
  (x <= 8192) ? 13 : \
  (x <= 16384) ? 14 : \
  (x <= 32768) ? 15 : \
  (x <= 65536) ? 16 : \
  (x <= 131072) ? 17 : \
  (x <= 262144) ? 18 : \
  (x <= 524288) ? 19 : \
  (x <= 1048576) ? 20 : \
  (x <= 2097152) ? 21 : \
  (x <= 4194304) ? 22 : \
  (x <= 8388608) ? 23 : \
  (x <= 16777216) ? 24 : \
  (x <= 33554432) ? 25 : \
  (x <= 67108864) ? 26 : \
  (x <= 134217728) ? 27 : \
  (x <= 268435456) ? 28 : \
  (x <= 536870912) ? 29 : \
  (x <= 1073741824) ? 30 : \
  (x <= 2147483648) ? 31 : \
  (x <= 4294967296) ? 32 : \
   -1

module dsm_model(
    // From normal DSM connection
    input        internal_clk,
    input        internal_rst_n,

    `ifdef FORMAL
    output [3:0] internal_bit,
    input  [3:0] external_bit,
    `else
    output [MOD_BITS_MSB:0] internal_bit,
    input  [MOD_BITS_MSB:0] external_bit,
    `endif

    // Things I gotta add
    input        external_clk,
    input        external_rst_n

    // Test bits
    `ifdef TB
        ,
    output reg [POINTER_BITS:0] save_index,
    output reg [POINTER_BITS:0] read_index
    `endif
);

parameter MOD_BITS = 4; // Modulator Bits
parameter SAMPLES  = 256; // 

localparam BUFFER_SIZE = (SAMPLES - 1);
localparam MOD_BITS_MSB = MOD_BITS - 1;
localparam POINTER_BITS = ((`CLOG2(SAMPLES)) - 1);

// 4 bits for PACSSv1, just 1 bit for PACSSv2 or CAFE
reg [MOD_BITS_MSB:0] dsm_out;
reg [MOD_BITS_MSB:0] buffer [0:BUFFER_SIZE];

`ifndef TB

reg [POINTER_BITS:0] save_index;
reg [POINTER_BITS:0] read_index;

`endif

assign internal_bit = dsm_out;

// Save Index 
always @(posedge external_clk)
begin
    if (external_rst_n == 0) save_index = 0;

    /* verilator lint_off WIDTH */
    else if (save_index < BUFFER_SIZE) 
        save_index = save_index + 1;
    /* verilator lint_on WIDTH */
end

// Read Index
always @(posedge internal_clk)
begin
    if (internal_rst_n == 0) read_index = 0;
    else 
        if (read_index + 1 < save_index)
            read_index = read_index + 1;
        else read_index = 0;
end

// Buffer
reg read_error;

always @(*)
begin
    if (read_index < save_index)
    begin
        dsm_out = buffer[read_index];
        read_error = 0;
    end
    else
    begin
        read_error = 1;
        dsm_out = 4'h0;
    end
end

always @(*)
begin
    /* verilator lint_off WIDTH */
    if (save_index < BUFFER_SIZE)
        buffer[save_index] = external_bit;
    else 
        buffer[save_index] = 4'hF;
    /* verilator lint_on WIDTH */
end

`ifdef FORMAL

always @(posedge external_clk)
begin
    assume(internal_rst_n == 1);
    assume(external_rst_n == 1);

    if ($past(internal_clk) == 1)
        assert(save_index > 0);
end

always @(posedge internal_clk)
begin
    assume(internal_rst_n == 1);
    assume(external_rst_n == 1);
    assume(save_index > 0);

    assert(save_index > read_index);
end

always @(*)
begin
    assume(internal_rst_n == 1);
    assume(external_rst_n == 1);

    assume(save_index > read_index);

    assert(read_error == 0);
end

`endif

endmodule
