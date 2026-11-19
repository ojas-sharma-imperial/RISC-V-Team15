module pc(
    input logic [31:0] next_pc;
    input logic clk, rst;
    output logic [31:0] pc_output;
)(
    always_ff @(posedge clk) begin
        if (rst == 0) pc_output <= {32{1'b0}};
        else pc_output <= next_pc;
    end
)
endmodule