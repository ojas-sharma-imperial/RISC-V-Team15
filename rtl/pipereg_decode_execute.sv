module pipereg_decode_execute (
    input logic         clk,
    input logic [31:0]  rd1_D, // data INPUT signals
    input logic [31:0]  rd2_D,
    input logic [31:0]  pc_D,
    input logic [4:0]   rs1_D,
    input logic [4:0]   rs2_D,
    input logic [4:0]   rd_D,
    input logic [31:0]  ext_imm_D,
    input logic [31:0]  pc_plus_4_D,
    input logic [1:0]   pc_src_D, // control INPUT signals
    input logic [1:0]   result_src_D,
    input logic [1:0]   alu_src_1_D,
    input logic         alu_src_2_D,
    input logic [2:0]   alu_control_D,
    input logic         mem_wen_D,
    input logic         reg_wen_D,
    input logic         branch_D,
    output logic [31:0] rd1_E, // data OUTPUT signals
    output logic [31:0] rd2_E,
    output logic [31:0] pc_E,
    output logic [4:0]  rs1_E,
    output logic [4:0]  rs2_E,
    output logic [4:0]  rd_E,
    output logic [31:0] ext_imm_E,
    output logic [31:0] pc_plus_4_E,
    output logic [1:0]  pc_src_E, // control OUTPUT signals
    output logic [1:0]  result_src_E,
    output logic [1:0]  alu_src_1_E,
    output logic        alu_src_2_E,
    output logic [2:0]  alu_control_E,
    output logic        mem_wen_E,
    output logic        reg_wen_E,
    output logic        branch_E
);

logic [31:0] rd1;
logic [31:0] rd2;
logic [31:0] pc;
logic [4:0] rs1;
logic [4:0] rs2;
logic [4:0] rd;
logic [31:0] ext_imm;
logic [31:0] pc_plus_4;
logic [1:0] pc_src;
logic [1:0] result_src;
logic [1:0] alu_src_1;
logic alu_src_2;
logic [2:0] alu_control;
logic mem_wen;
logic reg_wen;
logic branch;

always_comb begin
    rd1_E = rd1;
    rd2_E = rd2;
    pc_E = pc;
    rs1_E = rs1;
    rs2_E = rs2;
    rd_E = rd;
    ext_imm_E = ext_imm;
    pc_plus_4_E = pc_plus_4;
    pc_src_E = pc_src;
    result_src_E = result_src;
    alu_src_1_E = alu_src_1;
    alu_src_2_E = alu_src_2;
    alu_control_E = alu_control;
    mem_wen_E = mem_wen;
    reg_wen_E = reg_wen;
    branch_E = branch;
end

always_ff @(negedge clk) begin
    rd1 <= rd1_D;
    rd2 <= rd2_D;
    pc <= pc_D;
    rs1 <= rs1_D;
    rs2 <= rs2_D;
    rd <= rd_D;
    ext_imm <= ext_imm_D;
    pc_plus_4 <= pc_plus_4_D;
    pc_src <= pc_src_D;
    result_src <= result_src_D;
    alu_src_1 <= alu_src_1_D;
    alu_src_2 <= alu_src_2_D;
    alu_control <= alu_control_D;
    mem_wen <= mem_wen_D;
    reg_wen <= reg_wen_D;
    branch <= branch_D;
end

endmodule
