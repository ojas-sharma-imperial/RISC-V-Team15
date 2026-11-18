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

logic [2:0] instruction_type;

always_comb begin
    case (instruction)
        LUI: begin

        end
        AUIPC: begin
            
        end
        JAL: begin
            
        end
        JALR: begin
            
        end
        BRANCH: begin
            
        end
        LOAD_MEM: begin
            
        end
        STORE_MEM: begin
            
        end
        ALU_IMM: begin
            
        end
        ALU_REG: begin
            
        end
        FENCE: begin
            
        end
        ENVIRONMENT_CSR: begin
            
        end
        default: begin

        end
    endcase
end

endmodule
