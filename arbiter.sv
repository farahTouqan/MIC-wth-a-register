`default_nettype none timeunit 1ns; timeprecision 100ps;

module arbiter #(
    parameter int NREQS = 1,
    parameter int NBITS = $clog2(NREQS)
) (
    input  wire logic             clock,
    input  wire logic             reset_n,
    input  wire logic             acknowledge,
    input  wire logic [NREQS-1:0] requests,
    input  wire logic [NREQS-1:0] fifo_empty,
    output logic                  grant,
    output logic      [NREQS-1:0] grants,
    output logic      [NBITS-1:0] grant_index
);
  // State variables
  logic [NBITS-1:0] current_requester;
  logic             grant_active;
  logic [NREQS-1:0] last_grants;

  // Arbitration logic
  // Modify the arbitration logic to properly handle FIFO empty conditions
  always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
      current_requester <= '0;
      grant_active <= 0;
      last_grants <= '0;
    end else begin
      if (acknowledge) begin
        grant_active <= 0;
        // Round-robin with valid requests only
        for (int i = 1; i <= NREQS; i++) begin
          automatic int idx = (current_requester + i) % NREQS;
          if (requests[idx] && !fifo_empty[idx]) begin
            current_requester <= idx[NBITS-1:0];
            break;
          end
        end
      end else if (!grant_active) begin
        // Only grant if requester has data
        for (int i = 0; i < NREQS; i++) begin
          automatic int idx = (current_requester + i) % NREQS;
          if (requests[idx] && !fifo_empty[idx]) begin
            current_requester <= idx[NBITS-1:0];
            grant_active <= 1;
            break;
          end
        end
      end
      last_grants <= grants;
    end
  end

  // Only assert grant when FIFO has data
  // Modify grant assignment
assign grant = grant_active && !fifo_empty[current_requester];
assign grants = grant ? (1 << current_requester) : '0;
assign grant_index = current_requester;

  // Debug
  //   always_ff @(posedge clock) begin
  //     if (grant) begin
  //       $display("[%0t] ARBITER: Grant to requester %0d", $time, grant_index);
  //     end
  //   end
  always @(posedge clock) begin
    if (grant && grants != last_grants) begin
      $display("[ARB %0t] Grant to req %0d (FIFO empty: %b)", $time, current_requester,
               fifo_empty[current_requester]);
    end
  end
endmodule
