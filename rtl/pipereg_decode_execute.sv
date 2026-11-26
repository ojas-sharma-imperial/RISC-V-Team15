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
    input logic [2:0]    funct3_D,
    input logic [6:0]    funct7_D,
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
    output logic [2:0]   funct3_E,
    output logic [6:0]   funct7_E,
    output logic [1:0]  result_src_E,
    output logic [1:0]  alu_src_1_E,
    output logic        alu_src_2_E,
    output logic [2:0]  alu_control_E,
    output logic        mem_wen_E,
    output logic        reg_wen_E,
    output logic        branch_E
);

logic [31:0] rd1_reg;
logic [31:0] rd2_reg;
logic [31:0] pc_reg;
logic [4:0] rs1_reg;
logic [4:0] rs2_reg;
logic [4:0] rd_reg;
logic [31:0] ext_imm_reg;
logic [31:0] pc_plus_4_reg;
logic [2:0] funct3_reg;
logic [6:0] funct7_reg;
logic [1:0] result_src_reg;
logic [1:0] alu_src_1_reg;
logic alu_src_2_reg;
logic [2:0] alu_control_reg;
logic mem_wen_reg;
logic reg_wen_reg;
logic branch_reg;

always_comb begin
    rd1_E = rd1_reg;
    rd2_E = rd2_reg;
    pc_E = pc_reg;
    rs1_E = rs1_reg;
    rs2_E = rs2_reg;
    rd_E = rd_reg;
    ext_imm_E = ext_imm_reg;
    pc_plus_4_E = pc_plus_4_reg;
    funct3_E = funct3_reg;
    funct7_E = funct7_reg;
    result_src_E = result_src_reg;
    alu_src_1_E = alu_src_1_reg;
    alu_src_2_E = alu_src_2_reg;
    alu_control_E = alu_control_reg;
    mem_wen_E = mem_wen_reg;
    reg_wen_E = reg_wen_reg;
    branch_E = branch_reg;
end

always_ff @(negedge clk) begin
    rd1_reg <= rd1_D;
    rd2_reg <= rd2_D;
    pc_reg <= pc_D;
    rs1_reg <= rs1_D;
    rs2_reg <= rs2_D;
    rd_reg <= rd_D;
    ext_imm_reg <= ext_imm_D;
    pc_plus_4_reg <= pc_plus_4_D;
    funct3_reg <= funct3_D;
    funct7_reg <= funct7_D;
    result_src_reg <= result_src_D;
    alu_src_1_reg <= alu_src_1_D;
    alu_src_2_reg <= alu_src_2_D;
    alu_control_reg <= alu_control_D;
    mem_wen_reg <= mem_wen_D;
    reg_wen_reg <= reg_wen_D;
    branch_reg <= branch_D;
end

endmodule
