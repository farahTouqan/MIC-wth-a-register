`default_nettype none timeunit 1ns; timeprecision 100ps;

module multiplexor #(
    parameter int WIDTH = 1,
    parameter int NINPS = 1,
    parameter int NBITS = $clog2(NINPS)
) (
    input  wire logic [NBITS-1:0] select,
    input  wire logic [WIDTH-1:0] in [0:NINPS-1],
    output wire logic [WIDTH-1:0] out
);
  assign out = in[select];
endmodule
