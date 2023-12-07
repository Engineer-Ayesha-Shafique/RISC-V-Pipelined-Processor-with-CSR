//Arithmetic and logic unit for the processor

module alu #(
   parameter DW = 32
)(
   input  logic [6:0] opcode,
   input  logic [2:0] func3,
   input  logic       func7_5,   //take only 5th bit of func7

   // output logic [2:0] alu_control
   input  logic [DW-1:0] alu_operand_1_i,
   input  logic [DW-1:0] alu_operand_2_i,

   output logic [DW-1:0] alu_result_o
);

   always_comb begin
      //zero = (alu_operand_1_i == alu_operand_2_i) ? 1 : 0;
      
      case(opcode)
         7'h33: begin    //opcode for R-type
            case(func3)
               3'b000: begin  //add subtract
                  if (!func7_5) begin
                     alu_result_o = alu_operand_1_i + alu_operand_2_i;
                  end else begin
                     alu_result_o = alu_operand_1_i - alu_operand_2_i;
                  end
               end
               3'b001: begin   //sll
                  alu_result_o = alu_operand_1_i << alu_operand_2_i;
               end
               3'b010: begin   //slt
                  alu_result_o = $signed(alu_operand_1_i) < $signed(alu_operand_2_i);
               end
               3'b011: begin   //sltu
                  alu_result_o = alu_operand_1_i < alu_operand_2_i;
               end
               3'b100: begin   //xor
                  alu_result_o = alu_operand_1_i ^ alu_operand_2_i;
               end
               3'b101: begin   
                  if (!func7_5) begin  //srl
                     alu_result_o = alu_operand_1_i >> alu_operand_2_i;
                  end else begin       //sra
                     alu_result_o = alu_operand_1_i >>> alu_operand_2_i;
                  end
               end
               3'b110: begin   //or
                  alu_result_o = alu_operand_1_i | alu_operand_2_i;
               end
               3'b111: begin   //and
                  alu_result_o = alu_operand_1_i & alu_operand_2_i;
               end
            endcase
         end
         
         7'h13: begin    //opcode for I-type
            case(func3)
               3'b000: begin  //add subtract
                  alu_result_o = alu_operand_1_i + alu_operand_2_i;
               end
               3'b001: begin   //sll
                  if (func7_5 == 0)
                  alu_result_o = alu_operand_1_i << alu_operand_2_i;
               end
               3'b010: begin   //slt
                  alu_result_o = alu_operand_1_i < alu_operand_2_i;
               end
               3'b011: begin   //sltu
                  alu_result_o = alu_operand_1_i < alu_operand_2_i;
               end
               3'b100: begin   //xor
                  alu_result_o = alu_operand_1_i ^ alu_operand_2_i;
               end
               3'b101: begin   
                  if (func7_5 == 0) begin  //srl
                     alu_result_o = alu_operand_1_i >> alu_operand_2_i;
                  end else begin       //sra
                     alu_result_o = alu_operand_1_i >>> alu_operand_2_i;
                  end
               end
               3'b110: begin   //or
                  alu_result_o = alu_operand_1_i | alu_operand_2_i;
               end
               3'b111: begin   //and
                  alu_result_o = alu_operand_1_i & alu_operand_2_i;
               end
            endcase
         end
            
         7'h03: begin    //opcode for I-type (LOADS)
            alu_result_o = alu_operand_1_i + alu_operand_2_i;  //always addition in LOADS
         end

         7'd35: begin    //opcode for S-type
            alu_result_o = alu_operand_1_i + alu_operand_2_i;
         end

         7'd99: begin    //opcode for B-type
            alu_result_o = alu_operand_1_i + alu_operand_2_i;
         end

         7'd23 , 7'd55: begin    //opcode for U-type
            alu_result_o = alu_operand_1_i + alu_operand_2_i;
         end

         7'd103 , 7'd111: begin    //opcode for Jumps  
            alu_result_o = alu_operand_1_i + alu_operand_2_i;
         end
      endcase

   end



endmodule