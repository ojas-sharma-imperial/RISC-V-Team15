module sign_extend #(
    localparam [2:0] imm_I = 0, imm_U = 4, imm_S = 1, imm_B = 2, imm_J = 3;
)(
    input logic [31:0]      instr,
    input logic [2:0]       imm_src,
    output logic[31:0]      ext_im
);

always_comb begin
    case (imm_src)
        imm_I: ext_im = {{20{instr[31]}}, instr[31:20]};
        imm_B: ext_im = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        imm_S: ext_im = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        imm_U: ext_im = {instr[31:12], 12'b0};
        imm_J: ext_im = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
        default: ext_im = 32'b0;
    endcase
end
    

endmodule

//reference slide 6 of lecture 6