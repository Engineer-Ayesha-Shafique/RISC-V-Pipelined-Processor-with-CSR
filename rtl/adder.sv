//adder will be used for PC+4 to access next instruction
//it can be used for other purposes as well

module adder #(
   parameter DW = 32,
   parameter ADDENT = 4      //value to be added
)(
   input  logic [DW-1:0] in,
   output logic [DW-1:0] out
);

   assign out = in + ADDENT;
endmodule