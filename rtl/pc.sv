module pc(
    input logic [31:0] pc_current,
    input logic clk, rst, pc_src,
    input logic [31:0] imm_op,
    output logic [31:0] pc_output);
    logic [31:0] pc_inc;
    logic [31:0] pc_branch;
    logic [31:0] pc_next;

    assign pc_current = pc_output;

    always_comb begin : PC_operations
        pc_inc = pc_current + 4;
        pc_branch = pc_current + imm_op;       
    end

    mux pc_select  (.in1(pc_branch),
                    .in0(pc_inc),
                    .sel(pc_src),
                    .out(pc_next)
                    );

    always_ff @(posedge clk) begin
        if (rst == 1) pc_output <= {32{1'b0}};
        else pc_output <= pc_next;
    end
endmodule