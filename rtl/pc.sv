module pc(
    input logic clk,
    input logic rst,
    input logic [1:0] pc_src,
    input logic [31:0] jalr_target,
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

    // Updated to implement JAL/JALR: select PC+4, PC-relative, or register-relative target.
    always_comb begin
        case (pc_src)
            2'b00: pc_next = pc_inc;
            2'b01: pc_next = pc_branch;
            2'b10: pc_next = jalr_target;
            default: pc_next = pc_inc;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst == 1) pc_output <= BOOT_VECTOR;
        else pc_output <= pc_next;
    end
endmodule