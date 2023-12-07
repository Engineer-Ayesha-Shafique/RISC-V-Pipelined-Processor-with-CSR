//used to generate signed/unsigned immediates
//sign extender unit
module imm_generator #(
   parameter DW = 32
)(
   input  logic [DW-1:0] inst,        //instruction input to this unit
   input  logic [2:0]    s,
   output logic [DW-1:0] imm_ext      //output (extended input to 32-bits)
);

   always_comb begin
      case(s)
         3'b000: begin     //I-type
            imm_ext = {{20{inst[31]}}, inst[31:20]};
         end
         3'b001: begin     //S-type
            imm_ext = {{20{inst[31]}}, inst[31:25], inst[11:7]};
         end
         3'b010: begin     //B-type
            imm_ext = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
         end
         3'b011: begin     //J-type
            imm_ext = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
         end
         3'b100: begin     //U-type
            imm_ext = {{inst[31:12]}, {12{1'b0}}};
         end
         3'b101: begin
            imm_ext = {{20{1'b0}}, inst[31:20]};
         end
      endcase
   end

endmodule
