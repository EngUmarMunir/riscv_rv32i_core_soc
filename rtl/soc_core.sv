`timescale 1ns/1ps

module soc_core (
    input logic clk,
    input logic rest
);

logic [31:0] pc_out;
logic [31:0] instruction;

logic [31:0] data_addr;
logic [31:0] data_w;
logic [31:0] mem_data;
logic        MemWrite;

// =====================
// CPU CORE
// =====================
core cpu (
    .clk(clk),
    .rest(rest),

    .instruction(instruction),
    .mem_data(mem_data),

    .pc_out(pc_out),
    .data_addr(data_addr),
    .data_w(data_w),
    .MemWrite(MemWrite)
);

// =====================
// INSTRUCTION MEMORY
// =====================
instr_mem imem (
    .A(pc_out),
    .RD(instruction)
);

// =====================
// DATA MEMORY
// =====================
data_mem dmem (
    .clk(clk),
    .we(MemWrite),
    .A(data_addr),
    .WD(data_w),
    .RD(mem_data)
);

endmodule