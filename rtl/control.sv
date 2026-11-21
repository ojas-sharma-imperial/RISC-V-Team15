module control (
    input logic [6:0]   instruction,
    input logic [2:0]   funct3,
    input logic [6:0]   funct7,
    input logic         zero,
    output logic        pc_src,
    output logic [1:0]  result_src,
    output logic [1:0]  alu_src_1,
    output logic        alu_src_2,
    output logic [2:0]  imm_src,
    output logic [2:0]  alu_control,
    output logic        mem_wen,
    output logic        reg_wen,
    output logic        branch
);

// instruction types

localparam [2:0] I = 0;
localparam [2:0] S = 1;
localparam [2:0] B = 2;
localparam [2:0] J = 3;
localparam [2:0] U = 4;
localparam [2:0] R = 5;
localparam [2:0] SYS = 6;
localparam [2:0] INVALID = 7;

// instruction opcodes

localparam logic [6:0] LUI = 7'h37;
localparam logic [6:0] AUIPC = 7'h17;
localparam logic [6:0] JAL = 7'h6F;
localparam logic [6:0] JALR = 7'h67;
localparam logic [6:0] BRANCH = 7'h63;
localparam logic [6:0] LOAD_MEM = 7'h03;
localparam logic [6:0] STORE_MEM = 7'h23;
localparam logic [6:0] ALU_IMM = 7'h13;
localparam logic [6:0] ALU_REG = 7'h33;
localparam logic [6:0] FENCE = 7'h0F;
localparam logic [6:0] ENVIRONMENT_CSR = 7'h73;

// alu_control codes

localparam [2:0] ADD_SUB = 0;
localparam [2:0] SLL = 1;
localparam [2:0] SLT = 2;
localparam [2:0] SLTU = 3;
localparam [2:0] XOR = 4;
localparam [2:0] SRL_SRA = 5;
localparam [2:0] SYS_INSTR = 6;
localparam [2:0] INVALID_INSTR = 7;

always_comb begin

    // initial definitions to avoid latches being inferred

    pc_src = 1'b0;
    result_src = 2'b00;
    alu_src_1 = 2'b0;
    alu_src_2 = 1'b0;
    imm_src = INVALID;
    alu_control = 3'b0;
    mem_wen = 1'b0;
    reg_wen = 1'b0;
    branch = 1'b0;

    case (instruction)
        LUI: begin
            imm_src = U;
            reg_wen = 1'b1;
            alu_src_1 = 2'b10;
            alu_src_2 = 1'b1;
            alu_control = ADD_SUB;
        end
        AUIPC: begin
            imm_src = U;
            reg_wen = 1'b1;
            alu_src_1 = 2'b01;
            alu_src_2 = 1'b1;
            alu_control = ADD_SUB;
        end
        JAL: begin
            imm_src = J;
            result_src = 2'b10;
            reg_wen = 1'b1;
        end
        JALR: begin
            imm_src = I;
            result_src = 2'b10;
            reg_wen = 1'b1;
        end
        BRANCH: begin
            imm_src = B;
            branch = 1'b1;
            case (funct3)
                3'b000:     begin // BEQ
                    alu_control = ADD_SUB;
                    pc_src = zero;
                end
                3'b001:     begin // BNE
                    alu_control = ADD_SUB;
                    pc_src = !zero;
                end
                3'b100:     begin // BLT
                    alu_control = SLT;
                    pc_src = !zero;
                end
                3'b101:     begin // BGE
                    alu_control = SLT;
                    pc_src = zero;
                end
                3'b110:     begin // BLTU
                    alu_control = SLTU;
                    pc_src = !zero;
                end
                3'b111:     begin // BGEU
                    alu_control = SLTU;
                    pc_src = zero;
                end
                default:    begin // defualt subtraction (shouldn't reach this)
                    alu_control = INVALID_INSTR;
                end
            endcase
        end
        LOAD_MEM: begin
            imm_src = I;
            reg_wen = 1'b1;
            result_src = 2'b01;
            alu_src_2 = 1'b1;
        end
        STORE_MEM: begin
            imm_src = S;
            mem_wen = 1'b1;
            alu_src_2 = 1'b1;
        end
        ALU_IMM: begin
            imm_src = I;
            reg_wen = 1'b1;
            alu_src_2 = 1'b1;
            alu_control = funct3;
        end
        ALU_REG: begin
            imm_src = R;
            reg_wen = 1'b1;
            alu_control = funct3;
        end
        FENCE: begin
            imm_src = I;
        end
        ENVIRONMENT_CSR: begin
            imm_src = SYS;
        end
        default: begin

        end
    endcase
end

endmodule
