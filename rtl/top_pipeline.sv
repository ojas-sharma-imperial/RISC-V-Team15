// Five-stage RV32I pipeline. The existing single-cycle top.sv is unchanged.
// Pipeline registers: IF/ID, ID/EX, EX/MEM, MEM/WB.
// Includes EX/MEM and MEM/WB forwarding, load-use stalls and EX-stage redirects.
module top_pipeline (
    input  logic        clk,
    input  logic        rst,
    input  logic        trigger,
    output logic [31:0] a0
);

    localparam logic [31:0] BOOT_VECTOR = 32'hBFC00000;
    localparam logic [6:0] OPC_LOAD   = 7'h03;
    localparam logic [6:0] OPC_STORE  = 7'h23;
    localparam logic [6:0] OPC_BRANCH = 7'h63;
    localparam logic [6:0] OPC_OPIMM  = 7'h13;
    localparam logic [6:0] OPC_OP     = 7'h33;
    localparam logic [6:0] OPC_JALR   = 7'h67;

    typedef struct packed {
        logic        valid;
        logic [31:0] pc;
        logic [31:0] instruction;
    } if_id_t;

    typedef struct packed {
        logic        valid;
        logic [31:0] pc;
        logic [31:0] pc_plus_4;
        logic [31:0] rs1_value;
        logic [31:0] rs2_value;
        logic [31:0] imm;
        logic [4:0]  rs1;
        logic [4:0]  rs2;
        logic [4:0]  rd;
        logic [6:0]  funct7;
        logic [2:0]  funct3;
        logic [1:0]  alu_src_1;
        logic        alu_src_2;
        logic [2:0]  alu_control;
        logic        branch;
        logic [1:0]  pc_src;
        logic [1:0]  result_src;
        logic        mem_wen;
        logic        reg_wen;
    } id_ex_t;

    typedef struct packed {
        logic        valid;
        logic [31:0] alu_result;
        logic [31:0] store_data;
        logic [31:0] pc_plus_4;
        logic [4:0]  rd;
        logic [2:0]  funct3;
        logic [1:0]  result_src;
        logic        mem_wen;
        logic        reg_wen;
    } ex_mem_t;

    typedef struct packed {
        logic        valid;
        logic [31:0] alu_result;
        logic [31:0] memory_result;
        logic [31:0] pc_plus_4;
        logic [4:0]  rd;
        logic [1:0]  result_src;
        logic        reg_wen;
    } mem_wb_t;

    logic [31:0] pc_if;
    logic [31:0] instruction_if;
    if_id_t if_id;
    id_ex_t id_ex;
    ex_mem_t ex_mem;
    mem_wb_t mem_wb;

    // IF: fetch an instruction using the current PC.
    rom #(.ADDRESS_WIDTH(12)) instruction_rom (
        .clk (clk),
        .address (pc_if[11:0]),
        .data (instruction_if)
    );

    // ID: decode the instruction held in IF/ID.
    logic [6:0] id_opcode;
    logic [4:0] id_rs1, id_rs2, id_rd;
    logic [2:0] id_funct3;
    logic [6:0] id_funct7;
    assign id_opcode = if_id.instruction[6:0];
    assign id_rd     = if_id.instruction[11:7];
    assign id_funct3 = if_id.instruction[14:12];
    assign id_rs1    = if_id.instruction[19:15];
    assign id_rs2    = if_id.instruction[24:20];
    assign id_funct7 = if_id.instruction[31:25];

    logic [1:0] id_pc_src, id_result_src, id_alu_src_1;
    logic id_alu_src_2, id_mem_wen, id_reg_wen, id_branch;
    logic [2:0] id_imm_src, id_alu_control;
    logic [31:0] id_imm;
    logic [31:0] rf_read1, rf_read2;
    logic [31:0] id_rs1_value, id_rs2_value;
    logic [31:0] wb_result;

    control decoder (
        .instruction (id_opcode),
        .funct3 (id_funct3),
        .funct7 (id_funct7),
        .zero (1'b0),
        .pc_src (id_pc_src),
        .result_src (id_result_src),
        .alu_src_1 (id_alu_src_1),
        .alu_src_2 (id_alu_src_2),
        .imm_src (id_imm_src),
        .alu_control (id_alu_control),
        .mem_wen (id_mem_wen),
        .reg_wen (id_reg_wen),
        .branch (id_branch)
    );

    sign_extend immediate_decoder (
        .instr (if_id.instruction),
        .imm_src (id_imm_src),
        .ext_im (id_imm)
    );

    regfile registers (
        .clk (clk),
        .a3_wen (mem_wb.valid && mem_wb.reg_wen && !rst),
        .a1 (id_rs1),
        .a2 (id_rs2),
        .a3 (mem_wb.rd),
        .wd3 (wb_result),
        .rd1 (rf_read1),
        .rd2 (rf_read2),
        .a0 (a0)
    );

    // WB-to-ID bypass covers reading a register while WB is updating it.
    always_comb begin
        id_rs1_value = rf_read1;
        id_rs2_value = rf_read2;
        if (mem_wb.valid && mem_wb.reg_wen && mem_wb.rd != 5'd0) begin
            if (id_rs1 == mem_wb.rd)
                id_rs1_value = wb_result;
            if (id_rs2 == mem_wb.rd)
                id_rs2_value = wb_result;
        end
    end

    // ID-stage load-use detection: hold IF/ID and inject an ID/EX bubble.
    logic id_uses_rs1, id_uses_rs2;
    logic load_use_stall;
    always_comb begin
        id_uses_rs1 = (id_opcode == OPC_LOAD) || (id_opcode == OPC_STORE) ||
                      (id_opcode == OPC_BRANCH) || (id_opcode == OPC_OPIMM) ||
                      (id_opcode == OPC_OP) || (id_opcode == OPC_JALR);
        id_uses_rs2 = (id_opcode == OPC_STORE) || (id_opcode == OPC_BRANCH) ||
                      (id_opcode == OPC_OP);
        load_use_stall = if_id.valid && id_ex.valid &&
                         id_ex.reg_wen && (id_ex.result_src == 2'b01) &&
                         (id_ex.rd != 5'd0) &&
                         ((id_uses_rs1 && (id_rs1 == id_ex.rd)) ||
                          (id_uses_rs2 && (id_rs2 == id_ex.rd)));
    end

    // EX: forward results from the newest eligible in-flight instruction.
    logic [31:0] ex_rs1_value, ex_rs2_value, ex_mem_forward;
    logic [31:0] ex_operand1, ex_operand2, ex_alu_result;
    logic ex_alu_zero;
    always_comb begin
        ex_mem_forward = (ex_mem.result_src == 2'b10)
                         ? ex_mem.pc_plus_4 : ex_mem.alu_result;

        ex_rs1_value = id_ex.rs1_value;
        ex_rs2_value = id_ex.rs2_value;

        if (mem_wb.valid && mem_wb.reg_wen && mem_wb.rd != 5'd0) begin
            if (mem_wb.rd == id_ex.rs1)
                ex_rs1_value = wb_result;
            if (mem_wb.rd == id_ex.rs2)
                ex_rs2_value = wb_result;
        end
        if (ex_mem.valid && ex_mem.reg_wen && ex_mem.rd != 5'd0 &&
            ex_mem.result_src != 2'b01) begin
            if (ex_mem.rd == id_ex.rs1)
                ex_rs1_value = ex_mem_forward;
            if (ex_mem.rd == id_ex.rs2)
                ex_rs2_value = ex_mem_forward;
        end

        case (id_ex.alu_src_1)
            2'b00: ex_operand1 = ex_rs1_value;
            2'b01: ex_operand1 = id_ex.pc;
            2'b10: ex_operand1 = 32'd0;
            default: ex_operand1 = ex_rs1_value;
        endcase
        ex_operand2 = id_ex.alu_src_2 ? id_ex.imm : ex_rs2_value;
    end

    alu executor (
        .alu_src_2 (id_ex.alu_src_2),
        .branch (id_ex.branch),
        .alu_op1 (ex_operand1),
        .alu_op2 (ex_operand2),
        .alu_control (id_ex.alu_control),
        .funct7 (id_ex.funct7),
        .alu_out (ex_alu_result),
        .zero (ex_alu_zero)
    );

    // Branches and jumps redirect fetch from EX, flushing two younger stages.
    logic branch_taken_ex;
    logic redirect_ex;
    logic [31:0] redirect_target_ex;
    always_comb begin
        branch_taken_ex = 1'b0;
        if (id_ex.branch) begin
            case (id_ex.funct3)
                3'b000: branch_taken_ex = ex_alu_zero;   // BEQ
                3'b001: branch_taken_ex = !ex_alu_zero;  // BNE
                3'b100: branch_taken_ex = !ex_alu_zero;  // BLT
                3'b101: branch_taken_ex = ex_alu_zero;   // BGE
                3'b110: branch_taken_ex = !ex_alu_zero;  // BLTU
                3'b111: branch_taken_ex = ex_alu_zero;   // BGEU
                default: branch_taken_ex = 1'b0;
            endcase
        end

        redirect_ex = id_ex.valid &&
                      ((id_ex.branch && branch_taken_ex) ||
                       (!id_ex.branch && (id_ex.pc_src != 2'b00)));
        redirect_target_ex = (id_ex.pc_src == 2'b10)
                             ? {ex_alu_result[31:1], 1'b0}
                             : id_ex.pc + id_ex.imm;
    end

    // MEM: data RAM is byte-addressed, with combinational reads.
    logic [31:0] mem_read_data, mem_load_result;
    ram #(.ADDRESS_WIDTH(17)) data_ram (
        .clk (clk),
        .wen (ex_mem.valid && ex_mem.mem_wen && !rst),
        .store_funct3 (ex_mem.funct3),
        .address (ex_mem.alu_result[16:0]),
        .write_data (ex_mem.store_data),
        .read_data (mem_read_data)
    );

    always_comb begin
        case (ex_mem.funct3)
            3'b000: mem_load_result = {{24{mem_read_data[7]}}, mem_read_data[7:0]}; // LB
            3'b001: mem_load_result = {{16{mem_read_data[15]}}, mem_read_data[15:0]}; // LH
            3'b010: mem_load_result = mem_read_data; // LW
            3'b100: mem_load_result = {24'd0, mem_read_data[7:0]}; // LBU
            3'b101: mem_load_result = {16'd0, mem_read_data[15:0]}; // LHU
            default: mem_load_result = mem_read_data;
        endcase
    end

    // WB: choose the correct result for this older instruction.
    always_comb begin
        case (mem_wb.result_src)
            2'b00: wb_result = mem_wb.alu_result;
            2'b01: wb_result = mem_wb.memory_result;
            2'b10: wb_result = mem_wb.pc_plus_4;
            default: wb_result = 32'd0;
        endcase
    end

    // All pipeline registers advance together on the same clock edge.
    always_ff @(posedge clk) begin
        if (rst) begin
            pc_if <= BOOT_VECTOR;
            if_id  <= '0;
            id_ex  <= '0;
            ex_mem <= '0;
            mem_wb <= '0;
        end else begin
            // IF and ID may stall or be flushed after an EX-stage redirect.
            if (redirect_ex) begin
                pc_if <= redirect_target_ex;
                if_id <= '0;
                id_ex <= '0;
            end else if (load_use_stall) begin
                pc_if <= pc_if;
                if_id <= if_id;
                id_ex <= '0;
            end else begin
                pc_if <= pc_if + 32'd4;

                if_id.valid <= 1'b1;
                if_id.pc <= pc_if;
                if_id.instruction <= instruction_if;

                id_ex.valid <= if_id.valid;
                id_ex.pc <= if_id.pc;
                id_ex.pc_plus_4 <= if_id.pc + 32'd4;
                id_ex.rs1_value <= id_rs1_value;
                id_ex.rs2_value <= id_rs2_value;
                id_ex.imm <= id_imm;
                id_ex.rs1 <= id_rs1;
                id_ex.rs2 <= id_rs2;
                id_ex.rd <= id_rd;
                id_ex.funct7 <= id_funct7;
                id_ex.funct3 <= id_funct3;
                id_ex.alu_src_1 <= id_alu_src_1;
                id_ex.alu_src_2 <= id_alu_src_2;
                id_ex.alu_control <= id_alu_control;
                id_ex.branch <= id_branch;
                id_ex.pc_src <= id_pc_src;
                id_ex.result_src <= id_result_src;
                id_ex.mem_wen <= id_mem_wen;
                id_ex.reg_wen <= id_reg_wen;
            end

            // EX/MEM and MEM/WB keep advancing even while IF/ID stalls.
            ex_mem.valid <= id_ex.valid;
            ex_mem.alu_result <= ex_alu_result;
            ex_mem.store_data <= ex_rs2_value;
            ex_mem.pc_plus_4 <= id_ex.pc_plus_4;
            ex_mem.rd <= id_ex.rd;
            ex_mem.funct3 <= id_ex.funct3;
            ex_mem.result_src <= id_ex.result_src;
            ex_mem.mem_wen <= id_ex.mem_wen;
            ex_mem.reg_wen <= id_ex.reg_wen;

            mem_wb.valid <= ex_mem.valid;
            mem_wb.alu_result <= ex_mem.alu_result;
            mem_wb.memory_result <= mem_load_result;
            mem_wb.pc_plus_4 <= ex_mem.pc_plus_4;
            mem_wb.rd <= ex_mem.rd;
            mem_wb.result_src <= ex_mem.result_src;
            mem_wb.reg_wen <= ex_mem.reg_wen;
        end
    end
endmodule
