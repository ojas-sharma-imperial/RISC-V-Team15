module rom #(
    parameter       ADDRESS_WIDTH = 8,
                    DATA_WIDTH = 8
)(
    input logic     [ADDRESS_WIDTH-1:0] address,
    output logic    [31:0]              instruction
);

logic [DATA_WIDTH-1:0] rom_array [2**ADDRESS_WIDTH-1:0];

initial $readmemh("../rtl/program.hex", rom_array);

assign instruc = {rom_array[addr+3], rom_array[addr+2], rom_array[addr+1], rom_array[addr]};

endmodule