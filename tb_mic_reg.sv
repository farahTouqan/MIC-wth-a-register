`timescale 1ns / 1ps
import mic_pkg::*;  // Specify the library explicitly

module tb_mic_reg;

  localparam NREQS = mic_pkg::NREQS;
  localparam MWIDTH = mic_pkg::MWIDTH;
  localparam AWIDTH = mic_pkg::AWIDTH;
  localparam RWIDTH = mic_pkg::RWIDTH;

  // DUT Signals
  logic clock;
  logic reset_n;
  logic [NREQS-1:0] req_valid;
  logic [RWIDTH-1:0] req_data[0:NREQS-1];
  wire [NREQS-1:0] fifo_full;
  wire [MWIDTH-1:0] reg_out;

  // Testbench Control
  int error_count = 0;
  int success_count = 0;
  int test_number = 0;
  logic [MWIDTH-1:0] expected_values[AWIDTH-1:0];

  always #5 clock = ~clock;

  top dut (.*);

  // Test tasks
  task automatic write_op(input int req_id, input [AWIDTH-1:0] addr, input [MWIDTH-1:0] data);
    req_valid = (1 << req_id);
    req_data[req_id] = {data, addr, 1'b0, 1'b1};  // Write operation
    @(posedge clock);
    #1;
    req_valid = '0;

    // Wait for memory update or timeout
    fork : write_check
      begin
        wait (dut.mic_inst.u_memory.mem_array[addr] === data);
        $display("[%0t] WRITE CONFIRMED: Addr=0x%h Data=0x%h", $time, addr, data);
        disable write_check;
      end
      begin
        repeat (100) @(posedge clock);
        $error("[%0t] WRITE FAILED: Addr=0x%h Expected=0x%h Actual=0x%h", $time, addr, data,
               dut.mic_inst.u_memory.mem_array[addr]);
        disable write_check;
      end
    join
  endtask

  task automatic read_op(input int req_id, input [AWIDTH-1:0] addr,
                         input [MWIDTH-1:0] expected);
    req_valid = (1 << req_id);
    req_data[req_id] = {32'h0, addr, 1'b1, 1'b0};  // Read operation
    @(posedge clock);
    #1;
    req_valid = '0;

    // Wait for pipeline (5 cycles for read through FIFO, memory, and register)
    repeat (5) @(posedge clock);

    // Verify memory first
    if (dut.mic_inst.u_memory.mem_array[addr] !== expected) begin
      $error("[%0t] MEMORY ERROR: Addr=0x%h Expected=0x%h Actual=0x%h", $time, addr, expected,
             dut.mic_inst.u_memory.mem_array[addr]);
    end

    // Then verify register
    $display("-------------------------------------");
    $display("[%0t] READ TEST: Addr=0x%h", $time, addr);
    $display("Memory Content: 0x%h", dut.mic_inst.u_memory.mem_array[addr]);
    $display("Register Output: 0x%h", reg_out);
    $display("Expected Value: 0x%h", expected);

    if (reg_out !== expected) begin
      $display("STATUS: FAIL - Register mismatch!");
      error_count++;
    end else begin
      $display("STATUS: PASS - Data matches");
      success_count++;
    end
    $display("-------------------------------------");
  endtask

  // Main test sequence
  initial begin
    $display("\nStarting MIC Testbench");
    $display("Configuration: NREQS=%0d, MWIDTH=%0d, AWIDTH=%0d", NREQS, MWIDTH, AWIDTH);

    // Initialize
    clock = 0;
    reset_n = 0;
    req_valid = '0;
    foreach (req_data[i]) req_data[i] = '0;

    // Reset release
    #10 reset_n = 1;
    $display("[%0t] Reset released", $time);
    #50;

    // Test cases
    $display("\n=== TEST CASE 1: Single Requester Write/Read ===");
    write_op(0, 8'h10, 32'hA5A5A5A5);
    read_op(0, 8'h10, 32'hA5A5A5A5);

    $display("\n=== TEST CASE 2: Multiple Requesters ===");
    write_op(1, 8'h20, 32'h55AA55AA);
    write_op(2, 8'h30, 32'h12345678);
    read_op(1, 8'h20, 32'h55AA55AA);
    read_op(2, 8'h30, 32'h12345678);

    $display("\n=== TEST CASE 3: Boundary Address Check ===");
    write_op(0, 8'h00, 32'hDEADBEEF);
    write_op(1, (1 << AWIDTH) - 1, 32'hCAFEBABE);
    read_op(0, 8'h00, 32'hDEADBEEF);
    read_op(1, (1 << AWIDTH) - 1, 32'hCAFEBABE);

    // Final report
    $display("\n=== TEST SUMMARY ===");
    $display("Successful operations: %0d", success_count);
    $display("Failed operations: %0d", error_count);
    $finish;
  end
endmodule
