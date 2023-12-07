

module alu_decoder #(
   parameter DW = 32
)(
   input  logic [6:0] opcode,
   input  logic [2:0] func3,
   input  logic       func7_5,   //take only 5th bit of func7

   output logic [2:0] alu_control
);

   always_comb begin
      case(opcode)
         7'b0110011, 7'b0010011: begin    //opcode for R-type or I type
            case(func3)
               3'b000: begin  //both add and subtract
                  alu_control = 3'b000;
               end
               3'b001: begin   //sll
                  alu_control = 3'b001;
               end
               3'b010: begin   //slt
                  alu_control = 3'b010;
               end
               3'b011: begin   //sltu
                  alu_control = 3'b011;
               end
               3'b100: begin   //xor
                  alu_control = 3'b100;
               end
               3'b101: begin   //both srl and sra
                  alu_control = 3'b101;
               end
               3'b110: begin   //or
                  alu_control = 3'b110;
               end
               3'b111: begin   //and
                  alu_control = 3'b111;
               end
               default: alu_control = 3'b000;
            endcase
         end

         //the following comments are covered in the above case
         // 7'b0010011: begin    //I-type
         //    alu_control = 3'b000;
         // end
         7'b0000011: begin    //loads
            alu_control = 3'b000;
         end
         7'b0100011: begin                  //S
            alu_control = 3'b000;
         end
         7'b1100011: begin                  //B
            alu_control = 3'b000;
         end
         7'b0110111 , 7'b0010111: begin    //U
            alu_control = 3'b000;
         end
         7'b1101111 , 7'b1100111: begin    //J
            alu_control = 3'b000;
         end
         default: begin            //default case is to add only
            alu_control = 3'b000;
         end

      endcase
   end

endmodule