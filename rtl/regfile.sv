module regfile (
    input logic         clk,
    input logic         a3_wen,
    input logic [4:0]   a1,
    input logic [4:0]   a2,
    input logic [4:0]   a3,
    input logic [31:0]  wd3,
    output logic [31:0] rd1,
    output logic [31:0] rd2,
    output logic [31:0] a0
);

logic [31:0] regs [0:31];

assign a0 = regs[5'b01010];

always_comb begin
    if (a1 == 0) begin
        rd1 = 32'b0;
    end else begin
        rd1 = regs[a1];
    end

    if (a2 == 0) begin
        rd2 = 32'b0;
    end else begin
        rd2 = regs[a2];
    end
end

always_ff @(posedge clk) begin
    if ((a3 != 0) && (a3_wen)) begin
        regs[a3] <= wd3;
    end
end

endmodule
