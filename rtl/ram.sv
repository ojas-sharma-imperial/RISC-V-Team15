module ram #(
    parameter       ADDRESS_WIDTH = 8
)(
    input  logic                         clk,
    input  logic                         wen,
    // Updated to add SB support: decode the instruction's store width.
    input  logic [2:0]                   store_funct3,
    input  logic    [ADDRESS_WIDTH-1:0]  address,
    input  logic    [31:0]     write_data,
    output logic    [31:0]     read_data
);

logic [7:0] rom_array [2**ADDRESS_WIDTH-1:0];

assign read_data = {rom_array[address+3], rom_array[address+2], rom_array[address+1], rom_array[address]};

// Updated to add SB support: write only the bytes selected by funct3.
always_ff @(posedge clk) begin
    if (wen) begin
        case (store_funct3)
            3'b000: begin // SB
                rom_array[address] <= write_data[7:0];
            end
            3'b001: begin // SH
                rom_array[address]   <= write_data[7:0];
                rom_array[address+1] <= write_data[15:8];
            end
            3'b010: begin // SW
                rom_array[address]   <= write_data[7:0];
                rom_array[address+1] <= write_data[15:8];
                rom_array[address+2] <= write_data[23:16];
                rom_array[address+3] <= write_data[31:24];
            end
            default: ;
        endcase
    end
end

endmodule
