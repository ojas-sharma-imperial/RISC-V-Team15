module alu (
    input  logic        alu_src,
    input  logic        branch,
    input  logic [31:0] alu_op1,
    input  logic [31:0] alu_op2,
    input  logic [2:0]  alu_control,
    input  logic [6:0]  funct7,
    output logic [31:0] alu_out,
    output logic        zero
);

always_comb begin
    case (alu_control)
        0:  begin // ADD/SUB
            if (branch) begin // branch instructions must always subtract
                alu_out = alu_op1 - alu_op2
            end else if (alu_src) begin // imm-reg
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
end

endmodule

//reference slide 18 of lecture 7 for ALU decoder