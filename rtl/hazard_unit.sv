//So the idea I'm going with for the datapath is a simple: Take the Regwrite and output registers 
//for the two previous instructions, then see if they clash with the registers about to be used,
//then output a Hazard signal for a MUX in the pipeline registers module to select the correct input. 
//Output signal = 10 for Mem forward, 01 for Write, 00 for no forward 

//Stalling only occurs when a load instruction is followed by an instruction that uses the register
//that is being loaded to so all we have to do is check that then send a stall signal if true

//For the moment the control hazard can be handled by always not taking the branch and if it turns out
//that the branch should be taken then we flush everything and the PC automatically points at the right
//instruction. At some point we could implement that finite state machine branching.
module hazard_unit(
    //data hazard forwarding
    input  logic [4:0] rs1_E, //connect to a1
    input  logic [4:0] rs2_E, //connect to a2
    input  logic [4:0] rd_M, //connect to a3
    input  logic [4:0] rs_W, //connect to a3
    input  logic       reg_write_M,
    input  logic       reg_write_W,
    output logic [1:0] forward1_E,
    output logic [1:0] forward2_E,
    //data hazard stalling
    input logic [4:0] rs1_D, rs2_D, rd_E,
    input logic [1:0] result_src_E,
    output logic stall, //stall should freeze PC, and the two first pipeline registers, and send no-op into ALU.
    //control hazard flushing
    input logic pc_src_E,
    output logic flush
);

always_comb begin : data_hazard_forwarding
    forward1_E = 2'b00;
    forward2_E = 2'b00;
    if (reg_write_M) begin
        if ((rd_M == rs1_E) && (rs1_E != '0))
            forward1_E = 2'b10;
        if ((rd_M == rs2_E) && (rs2_E != '0))
            forward2_E = 2'b10;
    end
    if (reg_write_W) begin
        if ((rs_W == rs1_E) && (forward1_E != 2'b10) && (rs1_E != '0))
            forward1_E = 2'b01;
        if ((rs_W == rs2_E) && (forward2_E != 2'b10) && (rs2_E != '0))
            forward2_E = 2'b01;
    end
    
end

always_comb begin : data_hazard_stalling
    stall = 0;
    if (result_src_E == 2'b01) begin
        if ((rs1_D == rd_E) | (rs2_D == rd_E))
            stall = 1;
    end
end

always_comb begin : control_hazard_flushing
    if (pc_src_E)
        flush = 1;
    else
        flush = 0; 
end

endmodule