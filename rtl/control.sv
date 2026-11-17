module control (
    input logic [6:0]   instruction,
    input logic [2:0]   funct3,
    input logic [6:0]   funct7,
    input logic         zero,
    output logic        pc_src,
    output logic        result_src,
    output logic        alu_src,
    output logic [1:0]  imm_src,
    output logic [2:0]  alu_control,
    output logic        mem_wen,
    output logic        reg_wen

);

localparam logic [6:0] BRANCH = 7'h63;
localparam logic [6:0] LOAD = 7'h03;
localparam logic [6:0] ALU_IMM = 7'h13;
localparam logic [6:0] JUMP_JALR = 7'h67;
localparam logic [6:0] FENCE = 7'h0F;
localparam logic [6:0] ENVIRONMENT = 7'h73;
localparam logic [6:0] JUMP_JAL = 7'h6F;
localparam logic [6:0] ALU_REG = 7'h33;
localparam logic [6:0] STORE = 7'h23;
localparam logic [6:0] AUIPC = 7'h17;
localparam logic [6:0] LUI = 7'h37;

logic [2:0] instruction_type;

always_comb begin
    case (instruction)
        
        default:
    endcase
end

endmodule
