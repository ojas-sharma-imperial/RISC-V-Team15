//So the idea I'm going with for the datapath is a simple: Take the Regwrite and output registers 
//for the two previous instructions, then see if they clash with the registers about to be used,
//then output a Hazard signal for a MUX in the pipeline registers module to select the correct input. 
//Output signal = 10 for Mem forward, 01 for Write, 00 for no forward 

//Stalling only occurs when a load instruction is followed by an instruction that uses the register
//that is being loaded to so all we have to do is check that then send a stall signal if true

module hazard_unit(
    input  logic [4:0] rs1_e, //connect to a1
    input  logic [4:0] rs2_e, //connect to a2
    input  logic [4:0] rd_m, //connect to a3
    input  logic [4:0] rd_w, //connect to a3
    input  logic       reg_write_m,
    input  logic       reg_write_w,
    output logic [1:0] forward1_e,
    output logic [1:0] forward2_e,
    input logic [4:0] rs1_d, rs2_d, rd_e,
    input logic [1:0] result_src_e,
    output logic stall //stall should freeze PC, and the two first pipeline registers, and send no-op into ALU.
);

always_comb begin : data_hazard_forwarding
    forward1_e = 2'b00;
    forward2_e = 2'b00;
    if (reg_write_m) begin
        if ((rd_m == rs1_e) && (rs1_e != '0))
            forward1_e = 2'b10;
        if ((rd_m == rs2_e) && (rs2_e != '0))
            forward2_e = 2'b10;
    end
    if (reg_write_w) begin
        if ((rd_w == rs1_e) && (forward1_e != 2'b10) && (rs1_e != '0))
            forward1_e = 2'b01;
        if ((rd_w == rs2_e) && (forward2_e != 2'b10) && (rs2_e != '0))
            forward2_e = 2'b01;
    end
    
end

always_comb begin : data_hazard_stalling
    stall = 0;
    if (result_src_e == 2'b01) begin
        if ((rs1_d == rd_e) | (rs2_d == rd_e))
            stall = 1;
    end
end

endmodule