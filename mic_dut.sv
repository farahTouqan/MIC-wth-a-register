`default_nettype none timeunit 1ns; timeprecision 100ps;

import mic_pkg::*;

module mic_dut #(
    parameter int NREQS  = 4,
    parameter int PSIZE  = 64,
    parameter int MDEPTH = NREQS * PSIZE,
    parameter int AWIDTH = $clog2(MDEPTH),
    parameter int MWIDTH = 32,
    parameter int RWIDTH = AWIDTH + MWIDTH + 2,
    parameter int RDEPTH = 4,
    parameter int RBITS  = $clog2(NREQS)
) (
    input  wire logic              clock,
    input  wire logic              reset_n,
    input  wire logic [ NREQS-1:0] req_valid,
    input  wire logic [RWIDTH-1:0] req_data   [0:NREQS-1],
    output wire logic [ NREQS-1:0] fifo_full,
    output wire logic [ NREQS-1:0] read_valid,
    output wire logic [AWIDTH-1:0] mem_addr,
    output wire logic [MWIDTH-1:0] mem_rdata,
    output wire logic              rdata_valid
);
  mic u_mic (
      .clock(clock),
      .reset_n(reset_n),
      .req_valid(req_valid),
      .req_data(req_data),
      .fifo_full(fifo_full),
      .read_valid(read_valid),
      .mem_addr(mem_addr),
      .mem_rdata(mem_rdata),
      .rdata_valid(rdata_valid)
  );

  // always_ff @(posedge clock) begin
  //   if (write_enable) begin
  //     $display("[%0t] WRITE: Addr=0x%h Data=0x%h", $time, write_address, write_data);
  //   end
  //   if (read_enable) begin
  //     $display("[%0t] READ: Addr=0x%h Data=0x%h", $time, read_address, read_data);
  //   end
  // end
endmodule
