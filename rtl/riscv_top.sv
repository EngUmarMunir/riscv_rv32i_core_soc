module riscv_top (
    input  logic        clk,
    input  logic        rest,

    input  logic [31:0] instruction,
    input  logic [31:0] mem_data,

    output logic [31:0] pc_out,
    output logic [31:0] data_addr,
    output logic [31:0] data_w,
    output logic        MemWrite
);

// =====================
// SIGNALS
// =====================
logic [31:0] pc_out, next_pc;
logic [31:0] instruction;

logic [4:0] rs1, rs2, rd;
logic [31:0] read_data1, read_data2;

logic RegWrite, ALUSrc, MemWrite, Branch, Jump;
logic [1:0] ImmSrc, ResultSrc, ALU_op;

logic [3:0] alu_control;
logic [31:0] ImmExt;

logic [31:0] alu_result;
logic zero;

logic [31:0] mem_data;
logic [31:0] write_back_data;

logic branch_taken;

logic [31:0] alu_src_a, alu_src_b;

// LSU
logic [31:0] lsu_load_data;
logic [31:0] lsu_store_data;
logic [3:0]  lsu_funct;

// =====================
// FIELD EXTRACTION
// =====================
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign rd  = instruction[11:7];

assign lsu_funct = {MemWrite, instruction[14:12]};

// =====================
// ALU INPUTS (FIXED)
// =====================
assign alu_src_a = (instruction[6:0] == 7'b0010111) ? pc_out : read_data1;
assign alu_src_b = ALUSrc ? ImmExt : read_data2;

// =====================
// PC LOGIC
// =====================
assign next_pc =
    Jump ? (pc_out + ImmExt) :
    branch_taken ? (pc_out + ImmExt) :
    pc_out + 4;

// =====================
// MODULES
// =====================

// PC
program_counter pc (
    .clk(clk),
    .rest(rest),
    .pc_in(next_pc),
    .pc_out(pc_out)
);

// Register File
reg_file rf (
    .clk(clk),
    .rest(rest),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .data_w(write_back_data),
    .RegWrite(RegWrite),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

// Control
main_ctrl ctrl (
    .opcode(instruction[6:0]),
    .RegWrite(RegWrite),
    .ImmSrc(ImmSrc),
    .ALUSrc(ALUSrc),
    .MemWrite(MemWrite),
    .ResultSrc(ResultSrc),
    .Branch(Branch),
    .Jump(Jump),
    .ALU_op(ALU_op)
);

// ALU Control
alu_ctrl alu_ctrl_inst (
    .ALUop(ALU_op),
    .funct3(instruction[14:12]),
    .funct7(instruction[31:25]),
    .operation(alu_control)
);

// Immediate Generator
imm_gen imm_gen_inst (
    .instruction(instruction),
    .ImmExt(ImmExt)
);

// ALU
alu alu_inst (
    .a(alu_src_a),
    .b(alu_src_b),
    .control_in(alu_control),
    .result(alu_result),
    .zero(zero)
);


// LSU (FIXED)
load_store_unit lsu (
    .funct(lsu_funct),
    .mem_in(mem_data),
    .reg_in(read_data2),
    .load_data(lsu_load_data),
    .store_data(lsu_store_data)
);

// Branch logic
branch branch_inst (
    .funct3(instruction[14:12]),
    .rs1(read_data1),
    .rs2(read_data2),
    .Branch(Branch),
    .branch_taken(branch_taken)
);

// =====================
// WRITEBACK MUX
// =====================
always_comb begin
    case (ResultSrc)
        2'b00: write_back_data = alu_result;
        2'b01: write_back_data = lsu_load_data;
        2'b10: write_back_data = pc_out + 4;
        default: write_back_data = 32'b0;
    endcase
end

endmodule