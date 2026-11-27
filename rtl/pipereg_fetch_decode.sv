module pipereg_fetch_decode (
    input logic         clk,
    input logic [31:0]  instruction_F,
    input logic [31:0]  pc_F,
    input logic [31:0]  pc_plus_4_F,
    input logic         stall, flush,
    output logic [31:0] instruction_D,
    output logic [31:0] pc_D,
    output logic [31:0] pc_plus_4_D
);

always_ff @(posedge clk) begin
    if (flush) begin
        instruction_D <= '0;
        pc_D <= '0;
        pc_plus_4_D <= '0;
    end
    else if (!stall) begin
        instruction_D <= instruction_F;
        pc_D <= pc_F;
        pc_plus_4_D <= pc_plus_4_F;
    end
    //else do nothing (keep current values = stall)
end

endmodule

//checked correct against spec :)