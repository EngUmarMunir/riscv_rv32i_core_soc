`timescale 1ns/1ps

module soc_core (
    input logic clk,
    input logic rest
);

// =====================
// CPU <-> Instruction Memory
// =====================
logic [31:0] pc_out;
logic [31:0] instruction;

// =====================
// CPU <-> Data Memory
// =====================
logic [31:0] data_addr;
logic [31:0] data_w;
logic [31:0] mem_data;
logic        MemWrite;

// =====================
// Instruction Memory
// =====================
inst_mem imem (
    .read_addr (pc_out),
    .inst_out  (instruction)
);

// =====================
// Data Memory
// =====================
data_mem dmem (
    .clk          (clk),
    .rest         (rest),
    .addr         (data_addr),
    .data_w       (data_w),
    .mem_write_en (MemWrite),
    .MemRead      (1'b1),
    .data_r       (mem_data)
);

// =====================
// RV32I Core
// =====================
core cpu (
    .clk         (clk),
    .rest        (rest),

    .instruction (instruction),
    .pc_out      (pc_out),

    .mem_data    (mem_data),
    .data_addr   (data_addr),
    .data_w      (data_w),
    .MemWrite    (MemWrite)
);

endmodule