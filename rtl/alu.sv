module alu(
    input  logic [31:0] alu_op1, alu_op2,
    input  logic [1:0]  alu_ctrl,
    input  logic [2:0]  func_3,
    input  logic [1:0]  op5_func75,
    output logic [31:0] alu_out,
    output logic        equal
);


    always_comb begin
        case(alu_ctrl)
            0: alu_out = alu_op1 + alu_op2;
            1: alu_out = alu_op1 - alu_op2;
            2: begin
                case (func_3)
                    3'b000: if(op5_func75 == 2'b11)
                                alu_out = alu_op1 - alu_op2;
                            else
                                alu_out = alu_op1 + alu_op2;
                    3'b010: alu_out = {31'b0, (alu_op1 < alu_op2) ? 1:0};
                    3'b110: alu_out = alu_op1 | alu_op2;
                    3'b111: alu_out = alu_op1 & alu_op2;
                endcase
            end
            default: alu_out = '0;
        endcase
    end


endmodule

//reference slide 18 of lecture 7 for ALU decoder