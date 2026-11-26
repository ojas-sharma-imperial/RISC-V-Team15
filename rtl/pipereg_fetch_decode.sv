module pipereg_fetch_decode (
    input logic         clk,
    input logic [31:0]  instruction_F,
    input logic [31:0]  pc_F,
    input logic [31:0]  pc_plus_4_F,
    input logic         stall,
    output logic [31:0] instruction_D,
    output logic [31:0] pc_D,
    output logic [31:0] pc_plus_4_D
);

always_ff @(posedge clk) begin
    if (flush) begin
        instruction_reg <= '0;
        pc_reg <= '0;
        pc_plus_4_reg <= '0;
    end
    else if (!stall) begin
        instruction_reg <= instruction_F;
        pc_reg <= pc_F;
        pc_plus_4_reg <= pc_plus_4_F;
    end
    //else do nothing (keep current values = stall)
end

endmodule
