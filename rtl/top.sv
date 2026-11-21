module top (
    input   logic clk,
    input   logic rst,
    input   logic trigger,
    output logic [31:0] a0
);

// --- INSTRUCTION BREAKOUT ---

logic [31:0] instruction_word;
logic [6:0] opcode;
logic [4:0] rd;
logic [4:0] rs1;
logic [4:0] rs2;
logic [6:0] funct7;
logic [2:0] funct3;

assign opcode = instruction_word[6:0];
assign rd = instruction_word[11:7];
assign rs1 = instruction_word[19:15];
assign rs2 = instruction_word[24:20];
assign funct7 = instruction_word[31:25];
assign funct3 = instruction_word[14:12];

// --- CONNECTION WIRES ---

// regfile

logic [31:0] regfile_read_1;
logic [31:0] regfile_read_2;
logic [31:0] regfile_wd;

// alu

logic [31:0] alu_op1;
logic [31:0] alu_op2;
logic [31:0] alu_result;
logic alu_zero;

mux2 alu_op1_mux (
    .in0 (regfile_read_1),
    .in1 (pc_output),
    .in2 (32'b0),
    .in3 (32'bZ),
    .sel (alu_src_1),
    .out (alu_op1)
);

mux alu_op2_mux (
    .in0 (regfile_read_2),
    .in1 (extended_imm),
    .sel (alu_src_2),
    .out (alu_op2)
);

// pc

logic [31:0] pc_output;
logic [31:0] pc_plus_4;

assign pc_plus_4 = pc_output + 32'd4;

// sign_extend

logic [31:0] extended_imm;

// ram

logic [31:0] memory_dout;
logic [31:0] load_result;

always_comb begin
    case (funct3)
        3'b000: load_result = {{24{memory_dout[7]}}, memory_dout[7:0]};
        3'b010: load_result = memory_dout;
        3'b100: load_result = {24'b0, memory_dout[7:0]};
        default: load_result = memory_dout;
    endcase
end

// --- GENERAL DECLARATIONS ---

mux2 result_mux (
    .in0 (alu_result),
    .in1 (load_result),
    .in2 (pc_plus_4),
    .in3 (32'b0),
    .sel (result_src),
    .out (regfile_wd)
);

alu alu_inst (
    .alu_src_2 (alu_src_2),
    .branch (branch),
    .alu_op1 (alu_op1),
    .alu_op2 (alu_op2),
    .alu_control (alu_control),
    .funct7 (funct7),
    .alu_out (alu_result),
    .zero (alu_zero)
);

regfile regfile_inst (
    .clk (clk),
    .a3_wen (reg_wen),
    .a1 (rs1),
    .a2 (rs2),
    .a3 (rd),
    .wd3 (regfile_wd),
    .rd1 (regfile_read_1),
    .rd2 (regfile_read_2),
    .a0 (a0)
);

rom #(.ADDRESS_WIDTH(12)) rom_inst (
    .clk (clk),
    .address (pc_output[11:0]),
    .data (instruction_word)
);

ram #(.ADDRESS_WIDTH(17)) ram_inst (
    .clk (clk),
    .wen (mem_wen),
    // Updated to add SB support: pass store size to RAM.
    .store_funct3 (funct3),
    .address (alu_result[16:0]),
    .write_data (regfile_read_2),
    .read_data (memory_dout)
);

sign_extend sign_extend_inst (
    .instr(instruction_word),
    .imm_src (imm_src),
    .ext_im (extended_imm)
);

// Updated to implement JAL/JALR: connect the ALU-generated JALR target to the PC.
pc pc_inst (
    .clk (clk),
    .rst (rst),
    .pc_src (pc_src),
    .imm_op (extended_imm),
    .jalr_target ({alu_result[31:1], 1'b0}),
    .pc_output (pc_output)
);

control control_inst (
    .instruction (opcode),
    .funct3 (funct3),
    .funct7 (funct7),
    .zero (alu_zero),
    .pc_src (pc_src),
    .result_src (result_src),
    .alu_src_1 (alu_src_1),
    .alu_src_2 (alu_src_2),
    .imm_src (imm_src),
    .alu_control (alu_control),
    .mem_wen (mem_wen),
    .reg_wen (reg_wen),
    .branch (branch)
);

// control signals

// Two-bit PC selection supports sequential execution, branches/JAL, and JALR.
logic [1:0] pc_src;
logic [1:0] result_src;
logic [1:0] alu_src_1;
logic alu_src_2;
logic [2:0] imm_src;
logic [2:0] alu_control;
logic mem_wen;
logic reg_wen;
logic branch;


endmodule
