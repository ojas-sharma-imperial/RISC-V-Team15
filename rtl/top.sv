module top (
    input   logic clk,
    input   logic rst
);

localparam [31:0] BOOT_VECTOR = 32'hBFC00000;

logic [6:0] opcode;
logic [4:0] rd;
logic [4:0] rs1;
logic [4:0] rs2;
logic [6:0] funct7;
logic [2:0] funct3;

logic [31:0] pc;
logic [31:0] next_instruction;
logic [31:0] target_instruction;
logic [31:0] pc_offset;

always_comb begin
    target_instruction = pc + pc_offset;
    pc_plus4 = pc + 32'd4;
end

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        pc <= BOOT_VECTOR;
    end else begin
        pc <= (pc_src) ? target_instruction : pc_plus4;
    end
end

alu alu_inst (
    .alu_src (),
    .branch (),
    .alu_op1 (),
    .alu_op2 (),
    .alu_control (),
    .funct7 (),
    .alu_out (),
    .zero ()
);

regfile regfile_inst (
    .clk (),
    .a3_wen (),
    .a1 (),
    .a2 (),
    .a3 (),
    .wd3 (),
    .rd1 (),
    .rd2 ()
);

rom #(.ADDRESS_WIDTH(), .DATA_WIDTH()) rom_inst (
    .address (),
    .data()
);

sign_extend sign_extend_inst (
    .instr(),
    .imm_src (),
    .ext_im ()
);

endmodule
