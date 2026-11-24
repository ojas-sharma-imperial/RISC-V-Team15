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

logic [31:0] alu_out_reg;
logic [31:0] mem_rd_reg;
logic [4:0] rd_reg;
logic [31:0] pc_plus_4_reg;
logic reg_wen_reg;
logic [1:0] result_src_reg;

always_comb begin
end

always_ff @(negedge clk) begin
end

endmodule
