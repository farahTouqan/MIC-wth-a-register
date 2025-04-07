module fifo #(
    parameter int WIDTH  = 1,
    parameter int DEPTH  = 1,
    parameter int AWIDTH = $clog2(DEPTH)
) (
    input  wire logic             clock,
    input  wire logic             reset_n,
    input  wire logic             write,
    input  wire logic [WIDTH-1:0] write_data,
    input  wire logic             read,
    output wire logic [WIDTH-1:0] read_data,
    output wire logic             full,
    output wire logic             empty,
    output wire logic             read_data_valid
);
  // Storage array
  logic [WIDTH-1:0] buffer[0:DEPTH-1];

  // Pointers
  logic [AWIDTH:0] write_ptr, read_ptr;
  logic [AWIDTH:0] write_ptr_next, read_ptr_next;

  // Pointer updates
  assign write_ptr_next = write_ptr + (write && !full);
  assign read_ptr_next  = read_ptr + (read && !empty);

  always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
      write_ptr <= '0;
      read_ptr  <= '0;
    end else begin
      write_ptr <= write_ptr_next;
      read_ptr  <= read_ptr_next;
    end
  end

  // Memory operation
  always_ff @(posedge clock) begin
    if (write && !full) buffer[write_ptr[AWIDTH-1:0]] <= write_data;
  end

  // Status flags
  assign full = (write_ptr[AWIDTH-1:0] == read_ptr[AWIDTH-1:0]) && 
                (write_ptr[AWIDTH] != read_ptr[AWIDTH]);
  assign empty = (write_ptr == read_ptr);
  assign read_data = buffer[read_ptr[AWIDTH-1:0]];
  assign read_data_valid = read && !empty;
endmodule
