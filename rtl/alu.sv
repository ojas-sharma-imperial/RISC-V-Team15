module alu (
    input  logic        alu_src_2,
    input  logic        branch_E,
    input  logic        jump_E,
    input  logic [31:0] alu_op1,
    input  logic [31:0] alu_op2,
    input  logic [2:0]  alu_control,
    input  logic [1:0]  forward1_E, forward2_E,
    input  logic [31:0] forward_m_op, forward_w_op,
    input  logic [6:0]  funct7,
    input  logic [31:0] ext_imm_E,
    output logic [31:0] alu_out,
    output logic        pc_src_E,
    output logic [31:0] mem_wd_E
);

logic zero;

always_comb begin
    case(forward1_E)
        2'b00: alu_op1 = alu_op1;
        2'b01: alu_op1 = forward_w_op;
        2'b10: alu_op1 = forward_m_op;
    endcase
    case(forward2_E)
        2'b00: alu_op2 = alu_op2;
        2'b01: alu_op2 = forward_w_op;
        2'b10: alu_op2 = forward_m_op;
    endcase

    mem_wd_E = alu_op2;

    if(alu_src_2)
        alu_op2 = ext_imm_E;

    case (alu_control)
        0:  begin // ADD/SUB
            if (branch_E) begin // branch_E instructions must always subtract
                alu_out = alu_op1 - alu_op2;
            end else if (alu_src_2) begin // imm-reg
                alu_out = alu_op1 + alu_op2; // ADDI
            end else begin // reg-reg
                case (funct7)
                   7'h0:    alu_out = alu_op1 + alu_op2; // ADD
                   7'h20:   alu_out = alu_op1 - alu_op2; // SUB
                   default: alu_out = 32'b0;
                endcase
            end
        end
        1:  alu_out = alu_op1 << alu_op2[4:0]; // SLL
        2:  alu_out = ($signed(alu_op1) < $signed(alu_op2)) ? 32'b1 : 32'b0; // SLT
        3:  alu_out = (alu_op1 < alu_op2) ? 32'b1 : 32'b0; // SLTU
        4:  alu_out = alu_op1 ^ alu_op2; // XOR
        5:  begin
            case (funct7)
                7'h0:    alu_out = alu_op1 >> alu_op2[4:0]; // SRL
                7'h20:   alu_out = $signed(alu_op1) >>> alu_op2[4:0]; // SRA
                default: alu_out = 32'b0;
            endcase
        end
        6:  alu_out = alu_op1 | alu_op2; // OR
        7:  alu_out = alu_op1 & alu_op2; // AND
        default: alu_out = 32'b0;
    endcase
    zero = (alu_out == 32'b0);
    if ((zero && branch_E) | jump_E)
        pc_src_E = 1;
    else pc_src_E = 0;

end

endmodule

//reference slide 18 of lecture 7 for ALU decoder