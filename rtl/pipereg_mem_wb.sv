module pipereg_mem_wb (
    input logic         clk,
    input logic [31:0]  alu_out_M,
    input logic [31:0]  mem_rd_M,
    input logic [4:0]   rd_M,
    input logic [31:0]  pc_plus_4_M,
    input logic         reg_wen_M,
    input logic [1:0]   result_src_M,
    output logic [31:0] alu_out_W,
    output logic [31:0] mem_rd_W,
    output logic [4:0]  rd_W,
    output logic [31:0] pc_plus_4_W,
    output logic        reg_wen_W,
    output logic [1:0]  result_src_W
);

always_ff @(posedge clk) begin
    alu_out_W <= alu_out_M;
    mem_rd_W <= mem_rd_M;
    rd_W <= rd_M;
    pc_plus_4_W <= pc_plus_4_M;
    reg_wen_W <= reg_wen_M;
    result_src_W <= result_src_M;
end

endmodule
//checked correct i/o against spec :)
