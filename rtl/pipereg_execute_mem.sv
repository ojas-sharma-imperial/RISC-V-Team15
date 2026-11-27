module pipereg_execute_mem (
    input logic         clk,
    input logic [31:0]  alu_out_E, // data INPUT signals
    input logic [31:0]  mem_wd_E,
    input logic [4:0]   rd_E,
    input logic [31:0]  pc_plus_4_E,
    input logic [2:0]   funct3_E,
    input logic         reg_wen_E, // control INPUT signals
    input logic         mem_wen_E,
    input logic [1:0]   result_src_E,
    output logic [31:0] alu_out_M, // data OUTPUT signals
    output logic [31:0] mem_wd_M,
    output logic [4:0]  rd_M,
    output logic [31:0] pc_plus_4_M,
    output logic [2:0]  funct3_M,
    output logic        reg_wen_M, // control OUTPUT signals
    output logic        mem_wen_M,
    output logic [1:0]  result_src_M
);

always_ff @(posedge clk) begin
    alu_out_M <= alu_out_E;
    mem_wd_M <= mem_wd_E;
    rd_M <= rd_E;
    pc_plus_4_M <= pc_plus_4_E;
    funct3_M <= funct3_E;
    reg_wen_M <= reg_wen_E;
    mem_wen_M <= mem_wen_E;
    result_src_M <= result_src_E;
end

endmodule
