module pipereg_execute_mem (
    input logic         clk,
    input logic [31:0]  alu_out_E, // data INPUT signals
    input logic [31:0]  mem_wd_E,
    input logic [4:0]   rd_E,
    input logic [31:0]  pc_plus_4_E,
    input logic         reg_wen_E, // control INPUT signals
    input logic         mem_wen_E,
    input logic [1:0]   result_src_E,
    output logic [31:0] alu_out_M, // data OUTPUT signals
    output logic [31:0] mem_wd_M,
    output logic [4:0]  rd_M,
    output logic [31:0] pc_plus_4_M,
    output logic        reg_wen_M, // control OUTPUT signals
    output logic        mem_wen_M,
    output logic [1:0]  result_src_M
);

logic [31:0] alu_out_reg;
logic [31:0] mem_wd_reg;
logic [4:0] rd_reg;
logic [31:0] pc_plus_4_reg;
logic reg_wen_reg;
logic mem_wen_reg;
logic [1:0] result_src_reg;

always_comb begin
    alu_out_M = alu_out_reg;
    mem_wd_M = mem_wd_reg;
    rd_M = rd_reg;
    pc_plus_4_M = pc_plus_4_reg;
    reg_wen_M = reg_wen_reg;
    mem_wen_M = mem_wen_reg;
    result_src_M = result_src_reg;
end

always_ff @(negedge clk) begin
    alu_out_reg <= alu_out_E;
    mem_wd_reg <= mem_wd_E;
    rd_reg <= rd_E;
    pc_plus_4_reg <= pc_plus_4_E;
    reg_wen_reg <= reg_wen_E;
    mem_wen_reg <= mem_wen_E;
    result_src_reg <= result_src_E;
end

endmodule
