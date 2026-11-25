module top (
    input   logic clk,
    input   logic rst,
    output logic [31:0] a0
);

// ---- HAZARD UNIT ----

hazard_unit hazard_unit_inst (
    .rs1_E (),
    .rs2_E (),
    .rd_M (),
    .rd_W (),
    .reg_write_M (),
    .reg_write_W (),
    .forward1_E (),
    .forward2_E (),
    .rs1_D(),
    .rs2_D(),
    .rd_E(),
    .result_src_E()
);

// ---- FETCH STAGE ----

// main instantiations

pc pc_inst (
    .clk(clk),
    .rst(rst),
    .pc_src(1'b0),
    .pc_target(32'b0),
    .pc_plus_4 (pc_plus_4_F),
    .pc_output(pc_F)
);

rom #(.ADDRESS_WIDTH(12)) rom_inst (
    .address(pc_F[11:0]),
    .data(instruction_F)
);

pipereg_fetch_decode pipereg_fetch_decode_inst (
    .clk (clk),
    .instruction_F (instruction_F), // FETCH SIDE
    .pc_F (pc_F),
    .pc_plus_4_F (pc_plus_4_F),
    .instruction_D (instruction_D), // DECODE SIDE
    .pc_D (pc_D),
    .pc_plus_4_D (pc_plus_4_D)
);

// define additional wires to next pipeline stage

logic [31:0] instruction_F;
logic [31:0] pc_F;
logic [31:0] pc_plus_4_F;

// ---- DECODE STAGE ----

// define wires from previous pipeline stage

logic [31:0] instruction_D;
logic [31:0] pc_D;
logic [31:0] pc_plus_4_D;

// main instantiations

logic [6:0] opcode_D;
logic [6:0] funct7_D;
logic [2:0] funct3_D;
logic [2:0] imm_src_D;

assign opcode_D = instruction_D[6:0];
assign rd_D = instruction_D[11:7];
assign rs1_D = instruction_D[19:15];
assign rs2_D = instruction_D[24:20];
assign funct7_D = instruction_D[31:25];
assign funct3_D = instruction_D[14:12];

control control_inst (
    .instruction (opcode_D),
    .funct3 (funct3_D),
    .funct7 (funct7_D),
    .zero (), // AAAAAAAAAAAA HEELPPP ME PLS :)
    .pc_src (pc_src_D),
    .result_src (result_src_D),
    .alu_src_1 (alu_src_1_D),
    .alu_src_2 (alu_src_2_D),
    .imm_src (imm_src_D),
    .alu_control (alu_control_D),
    .mem_wen (mem_wen_D),
    .reg_wen (reg_wen_D),
    .branch (branch_D),
    .rst (rst)
);

regfile regfile_inst (
    .clk (clk),
    .a3_wen (reg_wen_W),
    .a1 (rs1_D),
    .a2 (rs2_D),
    .a3 (rd_W),
    .wd3 (result_W),
    .rd1 (rd1_D),
    .rd2 (rd2_D),
    .a0 (a0)
);

sign_extend sign_extend_inst (
    .instr(instruction_D),
    .imm_src (imm_src_D),
    .ext_im (ext_imm_D)
);

// define additional wires to next pipeline stage

logic [31:0] rd1_D;
logic [31:0] rd2_D;
logic [4:0] rs1_D;
logic [4:0] rs2_D;
logic [4:0] rd_D;
logic [31:0] ext_imm_D;
logic [1:0] pc_src_D;
logic [1:0] result_src_D;
logic [1:0] alu_src_1_D;
logic alu_src_2_D;
logic [2:0] alu_control_D;
logic mem_wen_D;
logic reg_wen_D;
logic branch_D;

pipereg_decode_execute pipereg_decode_execute_inst (
    .clk (clk),
    .rd1_D (rd1_D), // DECODE SIDE
    .rd2_D (rd2_D),
    .pc_D (pc_D),
    .rs1_D (rs1_D),
    .rs2_D (rs2_D),
    .rd_D (rd_D),
    .ext_imm_D (ext_imm_D),
    .pc_plus_4_D (pc_plus_4_D),
    .pc_src_D (pc_src_D),
    .result_src_D (result_src_D),
    .alu_src_1_D (alu_src_1_D),
    .alu_src_2_D (alu_src_2_D),
    .alu_control_D (alu_control_D),
    .mem_wen_D (mem_wen_D),
    .reg_wen_D (reg_wen_D),
    .branch_D (branch_D),
    .rd1_E (rd1_E), // EXECUTE SIDE
    .rd2_E (rd2_E),
    .pc_E (pc_E),
    .rs1_E (rs1_E),
    .rs2_E (rs2_E),
    .rd_E (rd_E),
    .ext_imm_E (ext_imm_E),
    .pc_plus_4_E (pc_plus_4_E),
    .pc_src_E (pc_src_E),
    .result_src_E (result_src_E),
    .alu_src_1_E (alu_src_1_E),
    .alu_src_2_E (alu_src_2_E),
    .alu_control_E (alu_control_E),
    .mem_wen_E (mem_wen_E),
    .reg_wen_E (reg_wen_E),
    .branch_E (branch_E)
);

// ---- EXECUTE STAGE ----

// define wires from previous pipeline stage

logic [31:0] rd1_E;
logic [31:0] rd2_E;
logic [31:0] pc_E;
logic [4:0] rs1_E;
logic [4:0] rs2_E;
logic [4:0] rd_E;
logic [31:0] ext_imm_E;
logic [31:0] pc_plus_4_E;
logic [1:0] pc_src_E;
logic [1:0] result_src_E;
logic [1:0] alu_src_1_E;
logic alu_src_2_E;
logic [2:0] alu_control_E;
logic mem_wen_E;
logic reg_wen_E;
logic branch_E;

// main instantiations

alu alu_inst (
    .alu_src_2 (alu_src_2_E),
    .branch (branch_E),
    .alu_op1 (),
    .alu_op2 (),
    .alu_control (alu_control_E),
    .funct7 (),
    .alu_out (alu_out_E),
    .zero ()
);

// define additional wires to next pipeline stage

logic [31:0] alu_out_E;
logic [31:0] mem_wd_E;

pipereg_execute_mem pipereg_execute_mem_inst (
    .clk (clk),
    .alu_out_E (alu_out_E), // EXECUTE SIDE
    .mem_wd_E (mem_wd_E),
    .rd_E (rd_E),
    .pc_plus_4_E (pc_plus_4_E),
    .reg_wen_E (reg_wen_E),
    .mem_wen_E (mem_wen_E),
    .result_src_E (result_src_E),
    .alu_out_M (alu_out_M), // MEMORY SIDE
    .mem_wd_M (mem_wd_M),
    .rd_M (rd_M),
    .pc_plus_4_M (pc_plus_4_M),
    .reg_wen_M (reg_wen_M),
    .mem_wen_M (mem_wen_M),
    .result_src_M (result_src_M)
);

// ---- MEMORY STAGE ----

// define wires from previous pipeline stage

logic [31:0] alu_out_M;
logic [31:0] mem_wd_M;
logic [4:0] rd_M;
logic [31:0] pc_plus_4_M;
logic reg_wen_M;
logic mem_wen_M;
logic [1:0] result_src_M;

// main instantiations

// define additional wires to next pipeline stage

logic [31:0] mem_rd_M;

pipereg_mem_wb pipereg_mem_wb_inst (
    .clk (clk),
    .alu_out_M (alu_out_M), // MEMORY SIDE
    .mem_rd_M (mem_rd_M),
    .rd_M (rd_M),
    .pc_plus_4_M (pc_plus_4_M),
    .reg_wen_M (reg_wen_M),
    .result_src_M (result_src_M),
    .alu_out_W (alu_out_W), // WRITEBACK SIDE
    .mem_rd_W (mem_rd_W),
    .rd_W (rd_W),
    .pc_plus_4_W (pc_plus_4_W),
    .reg_wen_W (reg_wen_W),
    .result_src_W (result_src_W)
);

// ---- WRITEBACK STAGE ----

// define wires from previous pipeline stage

logic [31:0] alu_out_W;
logic [31:0] mem_rd_W;
logic [4:0] rd_W;
logic [31:0] pc_plus_4_W;
logic reg_wen_W;
logic [1:0] result_src_W;

// main instantiations

// define additional wires to next pipeline stage

logic [31:0] result_W;

endmodule
