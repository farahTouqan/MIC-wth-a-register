`default_nettype none timeunit 1ns; timeprecision 100ps;

module mic #(
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
  // Internal signals with proper declarations
  wire  [RWIDTH-1:0] fifo_rdata         [0:NREQS-1];
  wire  [ NREQS-1:0] fifo_empty;
  wire               arb_grant;
  wire  [ NREQS-1:0] arb_grants;
  wire  [ RBITS-1:0] arb_grant_idx;
  wire  [RWIDTH-1:0] muxed_req;
  wire               mem_read;
  wire               mem_write;
  wire  [MWIDTH-1:0] mem_wdata;

  wire               req_read;
  wire               req_write;


  logic              packet_valid;
  logic [RWIDTH-1:0] validated_req;
  logic              operation_complete;

  // Registered memory interface signals
  logic [AWIDTH-1:0] mem_addr_reg;
  logic [MWIDTH-1:0] mem_wdata_reg;
  logic              mem_write_reg;
  logic              mem_read_reg;
  logic [ RBITS-1:0] mem_requester_reg;

  // Request FIFOs
  generate
    for (genvar i = 0; i < NREQS; i++) begin : req_fifos
      fifo #(
          .WIDTH(RWIDTH),
          .DEPTH(RDEPTH)
      ) u_fifo (
          .clock,
          .reset_n,
          .write(req_valid[i]),
          .write_data(req_data[i]),
          .read(arb_grants[i]),
          .read_data(fifo_rdata[i]),
          .full(fifo_full[i]),
          .empty(fifo_empty[i]),
          .read_data_valid()
      );
    end
  endgenerate

  // Arbiter
  arbiter #(
      .NREQS(NREQS)
  ) u_arbiter (
      .clock,
      .reset_n,
      .acknowledge(operation_complete),
      .requests(req_valid & ~fifo_empty),
      .fifo_empty(fifo_empty),
      .grant(arb_grant),
      .grants(arb_grants),
      .grant_index(arb_grant_idx)
  );

  // Request multiplexer
  multiplexor #(
      .WIDTH(RWIDTH),
      .NINPS(NREQS)
  ) u_mux (
      .select(arb_grant_idx),
      .in(fifo_rdata),
      .out(muxed_req)
  );

  assign packet_valid = 1'b1;
  assign validated_req = muxed_req;

  assign req_read = validated_req[1];  // Read bit is at position 1
  assign req_write = validated_req[0];  // Write bit is at position 0

  // Extract address and data from request
  assign mem_addr = validated_req[AWIDTH+1:2];  // Address field
  assign mem_wdata = validated_req[RWIDTH-1:AWIDTH+2];  // Data field

  logic mem_operation_done;

  always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
      mem_operation_done <= 0;
    end else begin
      mem_operation_done <= mem_write_reg || mem_read_reg;
    end
  end

  assign operation_complete = mem_operation_done;

  always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
      mem_addr_reg  <= '0;
      mem_wdata_reg <= '0;
      mem_write_reg <= 0;
      mem_read_reg  <= 0;
    end else begin
      if (arb_grant && !fifo_empty[arb_grant_idx]) begin
        mem_addr_reg  <= mem_addr;
        mem_wdata_reg <= mem_wdata;
        mem_write_reg <= req_write;
        mem_read_reg  <= req_read;
      end else begin
        if (operation_complete) begin
          mem_write_reg <= 0;
          mem_read_reg  <= 0;
        end
      end
    end
  end

  // Controller
  controller #(
      .NREQS(NREQS)
  ) u_controller (
      .clock,
      .reset_n,
      .req_read,
      .req_write,
      .arb_grant,
      .arb_grant_index(arb_grant_idx),
      .fifo_empty(fifo_empty[arb_grant_idx]),
      .cntrl_memory_read(mem_read),
      .cntrl_memory_write(mem_write),
      .cntrl_memory_read_valid(read_valid)
  );


  memory #(
      .WIDTH(MWIDTH),
      .DEPTH(128)
  ) u_memory (
      .clock,
      .write(mem_write_reg),
      .read(mem_read_reg),
      .address(mem_addr_reg),
      .write_data(mem_wdata_reg),
      .read_data(mem_rdata)
  );


  logic rdata_valid_reg;


  always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
      rdata_valid_reg <= 0;
    end else begin
      rdata_valid_reg <= mem_read_reg;
    end
  end

  assign rdata_valid = rdata_valid_reg;

  // Debug
  always @(posedge clock) begin
    if (mem_write_reg) begin
      $display("[MIC %0t] Memory Write: Addr=0x%h Data=0x%h", $time, mem_addr_reg, mem_wdata_reg);
    end
    if (mem_read_reg) begin
      $display("[MIC %0t] Memory Read: Addr=0x%h", $time, mem_addr_reg);
    end
    if (rdata_valid) begin
      $display("[MIC %0t] Read Data Valid: Data=0x%h", $time, mem_rdata);
    end
  end
endmodule
