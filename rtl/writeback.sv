module writeback (
    input logic [31:0] alu_out_W,
    input logic [31:0] mem_rd_W,
    input logic [31:0] pc_plus_4_W,
    input logic [1:0]  result_src_W,
    output logic [31:0] result_W
);

always_comb begin
    case (result_src_W)
        2'b00: result_W = alu_out_W;
        2'b01: result_W = mem_rd_W;
        2'b10: result_W = pc_plus_4_W;
        default: result_W = 32'b0;
    endcase
end

endmodule
