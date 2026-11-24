module ram #(
    parameter ADDRESS_WIDTH = 8
)(
    input  logic                     clk,
    input  logic                     wen,
    input  logic [2:0]               store_funct3,
    input  logic [ADDRESS_WIDTH-1:0] address,
    input  logic [31:0]              write_data,
    output logic [31:0]              read_data
);

    localparam integer MEM_SIZE = 2**ADDRESS_WIDTH;

    logic [7:0] ram_array [0:MEM_SIZE-1];

    //Ensures that data isn't read outside of bounds
    always_comb begin
        read_data = 32'b0;

        if (int'(address) < MEM_SIZE)
            read_data[7:0] = ram_array[int'(address)];

        if ((int'(address) + 1) < MEM_SIZE)
            read_data[15:8] = ram_array[int'(address) + 1];

        if ((int'(address) + 2) < MEM_SIZE)
            read_data[23:16] = ram_array[int'(address) + 2];

        if ((int'(address) + 3) < MEM_SIZE)
            read_data[31:24] = ram_array[int'(address) + 3];
    end

    // Synchronous writes. Out-of-range stores are ignored.
    always_ff @(posedge clk) begin
        if (wen) begin
            case (store_funct3)
                3'b000: begin // SB
                    if (int'(address) < MEM_SIZE)
                        ram_array[int'(address)] <= write_data[7:0];
                end

                3'b001: begin // SH
                    if (int'(address) <= MEM_SIZE-2) begin
                        ram_array[int'(address)]     <= write_data[7:0];
                        ram_array[int'(address) + 1] <= write_data[15:8];
                    end
                end

                3'b010: begin // SW
                    if (int'(address) <= MEM_SIZE-4) begin
                        ram_array[int'(address)]     <= write_data[7:0];
                        ram_array[int'(address) + 1] <= write_data[15:8];
                        ram_array[int'(address) + 2] <= write_data[23:16];
                        ram_array[int'(address) + 3] <= write_data[31:24];
                    end
                end

                default: begin
                    // Unsupported store widths do not modify memory.
                end
            endcase
        end
    end

endmodule
