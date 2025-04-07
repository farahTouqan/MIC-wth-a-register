`default_nettype none timeunit 1ns; timeprecision 100ps;

module memory #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 256,
    parameter int ABITS = $clog2(DEPTH)
) (
    input  wire logic             clock,
    input  wire logic             write,
    input  wire logic             read,
    input  wire logic [ABITS-1:0] address,
    input  wire logic [WIDTH-1:0] write_data,
    output logic      [WIDTH-1:0] read_data
);
  // Memory storage
  logic [WIDTH-1:0] mem_array[0:DEPTH-1];

  // all memory locations = 0
  initial begin
    for (int i = 0; i < DEPTH; i++) begin
      mem_array[i] = '0;
    end
    $display("[MEM] Initialized with DEPTH=%0d, WIDTH=%0d", DEPTH, WIDTH);
  end

  always_ff @(posedge clock) begin
    if (read) begin
      if (address < DEPTH) begin
        read_data <= mem_array[address];
      end else begin
        read_data <= '0;
        $error("[MEM %0t] ERROR: Invalid read address 0x%h", $time, address);
      end
    end
  end

  always_ff @(posedge clock) begin
    if (write) begin
      if (address < DEPTH) begin
        mem_array[address] <= write_data;
        $display("[MEM %0t] WRITE: Addr=0x%h Data=0x%h", $time, address, write_data);
      end else begin
        $error("[MEM %0t] ERROR: Invalid write address 0x%h", $time, address);
      end
    end
  end
endmodule
