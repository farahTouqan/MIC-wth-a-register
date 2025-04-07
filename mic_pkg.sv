`default_nettype none timeunit 1ns; timeprecision 100ps;

package mic_pkg;
  localparam int DEBUG = 2;
  localparam int NTRANS = 100;
  localparam int INTVL = 4;
  localparam int NREQS = 4;
  localparam int RBITS = $clog2(NREQS);
  localparam int PSIZE = 20;
  localparam int MDEPTH = NREQS * PSIZE;
  localparam int AWIDTH = $clog2(MDEPTH);
  localparam int MWIDTH = 32;
  localparam int RWIDTH = AWIDTH + MWIDTH + 2;
  localparam int RDEPTH = 6;
endpackage
