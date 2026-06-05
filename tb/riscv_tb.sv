`timescale 1ns/1ps

module riscv_tb;

    logic clk;
    logic rest;

    int cycle_count;
    int error_count;

    core dut (
        .clk  (clk),
        .rest (rest)
    );

    // Clock generation
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Reset
    initial begin
        rest = 1'b1;
        cycle_count = 0;
        error_count = 0;

        #20;
        rest = 1'b0;

        $display("[%0t] Reset released", $time);
    end

    // Basic runtime checks
    always_ff @(posedge clk) begin
        if (!rest) begin
            cycle_count++;

            $display("Cycle=%0d | PC=0x%08h | Instr=0x%08h",
                     cycle_count,
                     dut.pc_out,
                     dut.instruction);

            if ($isunknown(dut.pc_out)) begin
                $display("ERROR: Unknown PC at cycle %0d", cycle_count);
                error_count++;
            end

            if ($isunknown(dut.instruction)) begin
                $display("ERROR: Unknown instruction at cycle %0d", cycle_count);
                error_count++;
            end

            if (dut.pc_out[1:0] != 2'b00) begin
                $display("ERROR: Misaligned PC at cycle %0d | PC=0x%08h",
                         cycle_count, dut.pc_out);
                error_count++;
            end
        end
    end

    // Finish simulation
    initial begin
        #3000;

        $display("\n==============================");
        $display("Simulation Summary");
        $display("Total Cycles : %0d", cycle_count);
        $display("Total Errors : %0d", error_count);
        $display("%s", error_count == 0 ? "TEST PASSED" : "TEST FAILED");
        $display("==============================\n");

        $finish;
    end

endmodule