module pc(
    input logic clk,
    input logic rst,
    input logic pc_src,
    input logic [31:0] imm_op,
    output logic [31:0] pc_output);
    
    logic [31:0] pc_inc;
    logic [31:0] pc_branch;
    logic [31:0] pc_next;

    localparam [31:0] BOOT_VECTOR = 32'hBFC00000;

    always_comb begin : PC_operations
        pc_inc = pc_output + 4;
        pc_branch = pc_output + imm_op;       
    end

    mux pc_select  (.in1(pc_branch),
                    .in0(pc_inc),
                    .sel(pc_src),
                    .out(pc_next)
                    );

    always_ff @(posedge clk) begin
        if (rst == 1) pc_output <= BOOT_VECTOR;
        else pc_output <= pc_next;
    end
endmodule