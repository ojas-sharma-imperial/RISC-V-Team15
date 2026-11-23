module pipereg_fetch_decode (
    input logic         clk,
    input logic [31:0]  instruction_F,
    input logic [31:0]  pc_F,
    input logic [31:0]  pc_plus_4_F,
    output logic [31:0] instruction_D,
    output logic [31:0] pc_D,
    output logic [31:0] pc_plus_4_D
);

logic [31:0] instruction_reg;
logic [31:0] pc_reg;
logic [31:0] pc_plus_4_reg;

always_comb begin
    instruction_D = instruction_reg;
    pc_D = pc_reg;
    pc_plus_4_D = pc_plus_4_reg;
end

always_ff @(negedge clk) begin
    instruction_reg <= instruction_F;
    pc_reg <= pc_F;
    pc_plus_4_reg <= pc_plus_4_F;
end

endmodule
