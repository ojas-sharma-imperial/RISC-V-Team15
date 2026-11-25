module pc(
    input logic clk,
    input logic rst,
    input logic pc_src,
    input logic [31:0] pc_target,
    output logic [31:0] pc_plus_4,
    output logic [31:0] pc_output);

    logic [31:0] pc_inc;
    logic [31:0] pc_next;

    localparam [31:0] BOOT_VECTOR = 32'hBFC00000;

    assign pc_inc = pc_output + 32'd4;
    assign pc_plus_4 = pc_inc;

    // Select sequential execution or the target calculated in execute.
    mux pc_select (
        .in0(pc_inc),
        .in1(pc_target),
        .sel(pc_src),
        .out(pc_next)
    );

    always_ff @(posedge clk) begin
        if (rst == 1) pc_output <= BOOT_VECTOR;
        else pc_output <= pc_next;
    end
endmodule
