`default_nettype none timeunit 1ns; timeprecision 100ps;

module top (
    input  wire logic                       clock,
    input  wire logic                       reset_n,
    input  wire logic [ mic_pkg::NREQS-1:0] req_valid,
    input  wire logic [mic_pkg::RWIDTH-1:0] req_data [0:mic_pkg::NREQS-1],
    output wire logic [ mic_pkg::NREQS-1:0] fifo_full,
    output wire logic [mic_pkg::MWIDTH-1:0] reg_out
);
  // MIC Signals
  wire [mic_pkg::NREQS-1:0] read_valid;
  wire [mic_pkg::AWIDTH-1:0] mem_addr;
  wire [mic_pkg::MWIDTH-1:0] mem_rdata;

  wire mic_rdata_valid; 

  mic #(
      .NREQS (mic_pkg::NREQS),
      .PSIZE (mic_pkg::PSIZE),
      .MDEPTH(mic_pkg::MDEPTH),
      .AWIDTH(mic_pkg::AWIDTH),
      .MWIDTH(mic_pkg::MWIDTH),
      .RWIDTH(mic_pkg::RWIDTH),
      .RDEPTH(mic_pkg::RDEPTH),
      .RBITS (mic_pkg::RBITS)
  ) mic_inst (
      .clock(clock),
      .reset_n(reset_n),
      .req_valid(req_valid),
      .req_data(req_data),
      .fifo_full(fifo_full),
      .read_valid(read_valid),
      .mem_addr(mem_addr),
      .mem_rdata(mem_rdata),
      .rdata_valid(mic_rdata_valid)  
  );

  read_register #(
      .WIDTH(mic_pkg::MWIDTH)
  ) reg_inst (
      .clock(clock),
      .reset_n(reset_n),
      .read_data(mem_rdata),
      .read_valid(mic_rdata_valid),  
      .reg_out(reg_out)
  );
endmodule
