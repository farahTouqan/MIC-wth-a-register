`default_nettype none timeunit 1ns; timeprecision 100ps;

module controller #(
    parameter int NREQS = 1,
    parameter int NBITS = $clog2(NREQS)
) (
    input  wire logic             clock,
    input  wire logic             reset_n,
    input  wire logic             req_read,
    input  wire logic             req_write,
    input  wire logic             arb_grant,
    input  wire logic [NBITS-1:0] arb_grant_index,
    input  wire logic             fifo_empty,
    output logic                  cntrl_memory_read,
    output logic                  cntrl_memory_write,
    output logic      [NREQS-1:0] cntrl_memory_read_valid
);
  // Pipeline stages
  logic mem_read_pending, mem_write_pending;
  logic [NREQS-1:0] read_valid_pending;

  always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
      mem_read_pending   <= 0;
      mem_write_pending  <= 0;
      read_valid_pending <= '0;
    end else begin
      mem_read_pending   <= req_read && arb_grant && !fifo_empty;
      mem_write_pending  <= req_write && arb_grant && !fifo_empty;

      read_valid_pending <= '0;
      if (req_read && arb_grant && !req_write && !fifo_empty) begin
        if (arb_grant_index < NREQS)  // Ensure arb_grant_index is within bounds
          read_valid_pending <= (1 << arb_grant_index);
      end
    end
  end

  // Output registers
  always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
      cntrl_memory_read <= 0;
      cntrl_memory_write <= 0;
      cntrl_memory_read_valid <= '0;
    end else begin
      cntrl_memory_read <= mem_read_pending;
      cntrl_memory_write <= mem_write_pending;
      cntrl_memory_read_valid <= read_valid_pending;
    end
  end

endmodule
