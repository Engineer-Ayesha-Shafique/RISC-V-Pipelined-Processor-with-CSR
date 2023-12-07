//4 to 1 mux for write back

module mux_4x1 #(
   parameter DW = 32
)(
   input  logic [DW-1:0] in0,
   input  logic [DW-1:0] in1,
   input  logic [DW-1:0] in2,
   input  logic [DW-1:0] in3,
   input  logic [1:0]    s,

   output logic [DW-1:0] out
);

   always_comb begin
      case(s)
         2'b00: out = in0;
         2'b01: out = in1;
         2'b10: out = in2;
         2'b11: out = in3;
      endcase
   end
endmodule