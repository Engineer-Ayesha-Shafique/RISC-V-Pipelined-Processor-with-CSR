//2 to 1 mux for to select PC and PC target

module mux_2x1 #(
   parameter DW = 32
)(
   input  logic [DW-1:0] in0,
   input  logic [DW-1:0] in1,
   input  logic          s,

   output logic [DW-1:0] out
);

   assign out = s ? in1 : in0;
endmodule