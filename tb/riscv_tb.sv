`timescale 1ns/1ps

module soc_core_tb;


// Clock & Reset
logic clk;
logic rest;

// Counters
int cycle_count;
int error_count;

// DUT
soc_core dut (
    .clk  (clk),
    .rest (rest)
);

// Clock Generation (100MHz)
initial clk = 0;
always #5 clk = ~clk;

// Reset Sequence
initial begin
    rest = 1;
    #20;
    rest = 0;
    $display("[%0t] Reset released", $time);
end

// Main Monitor Block (SINGLE DRIVER BLOCK)
always_ff @(posedge clk) begin
    if (rest) begin
        cycle_count <= 0;
        error_count <= 0;
    end
    else begin
        cycle_count <= cycle_count + 1;

        $display("Cycle=%0d | PC=0x%08h | Instr=0x%08h",
                 cycle_count,
                 dut.pc_out,
                 dut.instruction);

        // Check 1: Unknown PC
        if ($isunknown(dut.pc_out)) begin
            $display("ERROR: Unknown PC at cycle %0d", cycle_count);
            error_count <= error_count + 1;
        end

        // Check 2: Unknown Instruction
        if ($isunknown(dut.instruction)) begin
            $display("ERROR: Unknown instruction at cycle %0d", cycle_count);
            error_count <= error_count + 1;
        end

        // Check 3: Misaligned PC
        if (dut.pc_out[1:0] != 2'b00) begin
            $display("ERROR: Misaligned PC at cycle %0d | PC=0x%08h",
                     cycle_count, dut.pc_out);
            error_count <= error_count + 1;
        end
    end
end

// End Simulation
initial begin
    #3000;

    $display("\n=================================");
    $display("         SIMULATION SUMMARY      ");
    $display("=================================");
    $display("Total Cycles : %0d", cycle_count);
    $display("Total Errors : %0d", error_count);

    if (error_count == 0)
        $display("TEST PASSED");
    else
        $display("TEST FAILED");

    $display("=================================\n");

    $finish;
end
endmodule