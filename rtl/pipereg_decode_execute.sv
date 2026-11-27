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
    input logic         alu_src_2_D, //not sure why we have multiple ALU sources, gonna check the other modules
    input logic [2:0]   alu_control_D,
    input logic         mem_wen_D,
    input logic         reg_wen_D,
    input logic         branch_D,
    input logic         jump_D,
    input logic         stall, flush,
    output logic [31:0] rd1_E, // data OUTPUT signals
    output logic [31:0] rd2_E,
    output logic [31:0] pc_E,
    output logic [4:0]  rs1_E,
    output logic [4:0]  rs2_E,
    output logic [4:0]  rd_E,
    output logic [31:0] ext_imm_E,
    output logic [31:0] pc_plus_4_E,
    output logic [2:0]  funct3_E,
    output logic [6:0]  funct7_E,
    output logic [1:0]  result_src_E,
    output logic [1:0]  alu_src_1_E,
    output logic        alu_src_2_E,
    output logic [2:0]  alu_control_E,
    output logic        mem_wen_E,
    output logic        reg_wen_E,
    output logic        branch_E,
    output logic        jump_E
);

always_ff @(posedge clk) begin
    if (stall | flush) begin
        rd1_W <= '0;
        rd2_W <= '0;
        pc_W <= '0;
        rs1_W <= '0;
        rs2_W <= '0;
        rd_W <= '0;
        ext_imm_W <= '0;
        pc_plus_4_W <= '0;
        funct3_W <= '0;
        funct7_W <= '0;
        pc_src_W <= '0;
        result_src_W <= '0;
        alu_src_1_W <= '0;
        alu_src_2_W <= '0;
        alu_control_W <= '0;
        mem_wen_W <= '0;
        reg_wen_W <= '0;
        branch_W <= '0;        
    end
    else begin
        rd1_W <= rd1_D;
        rd2_W <= rd2_D;
        pc_W <= pc_D;
        rs1_W <= rs1_D;
        rs2_W <= rs2_D;
        rd_W <= rd_D;
        ext_imm_W <= ext_imm_D;
        pc_plus_4_W <= pc_plus_4_D;
        funct3_W <= funct3_D;
        funct7_W <= funct7_D;
        pc_src_W <= pc_src_D;
        result_src_W <= result_src_D;
        alu_src_1_W <= alu_src_1_D;
        alu_src_2_W <= alu_src_2_D;
        alu_control_W <= alu_control_D;
        mem_wen_W <= mem_wen_D;
        reg_wen_W <= reg_wen_D;
        branch_W <= branch_D;        
    end
end

endmodule

//inputs and outputs look good, just gotta check why we have two ALU sources :) update: i read the control spec 
//func3 and func7 as i/o deviate from the spec but are fully correct and necessary to step beyond the spec