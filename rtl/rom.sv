module rom #(
    parameter       ADDRESS_WIDTH = 8
)(
    input logic                         clk,
    input logic     [ADDRESS_WIDTH-1:0] address,
    output logic    [31:0]    data
);

logic [7:0] rom_array [2**ADDRESS_WIDTH-1:0];

initial $readmemh("../rtl/program.hex", rom_array);

always_ff @(posedge clk) begin
    data <= {rom_array[address+3], rom_array[address+2], rom_array[address+1], rom_array[address]};
end

endmodule
