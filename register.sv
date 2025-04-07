`default_nettype none timeunit 1ns; timeprecision 100ps;

module read_register #(
    parameter int WIDTH = 32
) (
    input  wire logic             clock,
    input  wire logic             reset_n,
    input  wire logic [WIDTH-1:0] read_data,
    input  wire logic             read_valid,
    output logic      [WIDTH-1:0] reg_out
);
  // Main register with proper reset and capture
  always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
      reg_out <= '0;
    end else if (read_valid) begin
      reg_out <= read_data;
      $display("[REG %0t] CAPTURED: Data=0x%h", $time, read_data);
    end
  end

  // Debug invalid data
  always @(posedge clock) begin
    if (read_valid && $isunknown(read_data)) begin
      $error("[REG %0t] ERROR: Invalid data 0x%h", $time, read_data);
    end
  end
endmodule
