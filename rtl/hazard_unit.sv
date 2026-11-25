//So the idea I'm going with for the datapath is a simple: Take the Regwrite and output registers 
//for the two previous instructions, then see if they clash with the registers about to be used,
//then output a Hazard signal for a MUX in the pipeline registers module to select the correct input. 
//Output signal = 10 for Mem forward, 01 for Write, 00 for no forward 

module hazard_unit(
    input  logic [4:0] Rs1E, //connect to a1
    input  logic [4:0] Rs2E, //connect to a2
    input  logic [4:0] RdM, //connect to a3
    input  logic [4:0] RdW, //connect to a3
    input  logic       RegWriteM,
    input  logic       RegWriteW,
    output logic [1:0] Forward1E,
    output logic [1:0] Forward2E
);

always_comb begin : data_hazard
    Forward1E = 2'b00;
    Forward2E = 2'b00;
    if (RegWriteM) begin
        if ((RdM == Rs1E) && (Rs1E != '0))
            Forward1E = 2'b10;
        if ((RdM == Rs2E) && (Rs2E != '0))
            Forward2E = 2'b10;
    end
    if (RegWriteW) begin
        if ((RdW == Rs1E) && (Forward1E != 2'b10) && (Rs1E != '0))
            Forward1E = 2'b01;
        if ((RdW == Rs2E) && (Forward2E != 2'b10) && (Rs2E != '0))
            Forward2E = 2'b01;
    end
    
end

endmodule