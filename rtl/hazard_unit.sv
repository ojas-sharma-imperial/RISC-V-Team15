//So the idea I'm going with for the datapath is a simple: Take the Regwrite and output registers 
//for the two previous instructions, then see if they clash with the registers about to be used,
//then output a Hazard signal for a MUX in the pipeline registers module to select the correct input. 

module hazard_unit(

)