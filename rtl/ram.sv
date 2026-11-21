module ram #(
    parameter       ADDRESS_WIDTH = 8
)(
    input  logic                         clk,
    input  logic                         wen,
    input  logic    [ADDRESS_WIDTH-1:0]  address,
    input  logic    [31:0]     write_data,
    output logic    [31:0]     read_data
);

logic [7:0] rom_array [2**ADDRESS_WIDTH-1:0];

always_ff @(posedge clk) begin
    if (wen) begin
        rom_array[address+3] <= write_data[31:24];
        rom_array[address+2] <= write_data[23:16];
        rom_array[address+1] <= write_data[15:8];
        rom_array[address] <= write_data[7:0];
    end
    read_data <= {rom_array[address+3], rom_array[address+2], rom_array[address+1], rom_array[address]};
end

endmodule
