// write data memory module
`timescale 1ns/1ps
module data_mem (
    input logic clk,
    input logic rest,
    input logic [31:0] addr,
    input logic [31:0] data_w,
    input logic mem_write_en,
    input logic MemRead,
    output logic [31:0] data_r
);
reg [31:0] memory [0:255]; // 256 words of 32-bit memory
integer i;
// initialize memory to 0 on reset
always_ff @(posedge clk) begin
    if (rest) begin
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] <= 32'b0;
        end
    end else if (mem_write_en) begin
        memory[addr[9:2]] <= data_w; // write data to memory, using bits [9:2] to index (word-aligned)
    end
end
// read data from memory at the given address
assign data_r = memory[addr[9:2]]; 
endmodule