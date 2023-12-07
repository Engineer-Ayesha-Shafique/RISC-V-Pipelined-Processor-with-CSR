//Arithmetic and logic unit for the processor

module alu_new #(
   parameter DW = 32
)(
   input  logic [6:0]    opcode,
   input  logic          func7_5,

   input  logic [DW-1:0] alu_operand_1_i,
   input  logic [DW-1:0] alu_operand_2_i,
   input  logic [2:0]    alu_control,
   output logic [DW-1:0] alu_result_o
);

   typedef enum logic [2:0] {
      ADD_SUB,
      SLL,
      SLT,
      SLTU,
      XOR,
      SRL_SRA,
      OR,
      AND
   } e_alu;

   logic [DW-1:0] operand_2;
   // logic          store_func7_5;
   // logic [DW-1:0] operand_2_branch;

   logic [DW-1:0] operand_2_srl_sra;   //the signal for only one shift for both srl and sra
   logic [DW-1:0] temp;                //the signal for only one shift for both srl and sra

   always_comb begin                   //to make less number of adders in hardware
      if (func7_5) begin
         operand_2 = ~alu_operand_2_i;
      end else begin
            operand_2 = alu_operand_2_i;
      end
   end

   always_comb begin
      operand_2_srl_sra = alu_operand_1_i;
      
      // operand_2_branch  = alu_operand_2_i
      case(alu_control)
         ADD_SUB: if (func7_5 && (opcode == 7'b1100011 || opcode == 7'b1101111 || opcode == 7'b1100111 || opcode == 7'b0010011)) begin //if there is a branch or jump or I-type, add the result even if func7_5 is 1
            alu_result_o = alu_operand_1_i + alu_operand_2_i;

         end else if (opcode == 7'b0110111) begin   //select operand 2 in lui only
            alu_result_o = alu_operand_2_i;
         end else if (alu_operand_1_i[DW-1] || alu_operand_2_i[DW-1]) begin  //Do not subtract -ve numbers, instead add them
            alu_result_o = alu_operand_1_i + alu_operand_2_i;

         end else begin
            alu_result_o = alu_operand_1_i + operand_2 + func7_5;
         end

         SLL    : alu_result_o = alu_operand_1_i          << alu_operand_2_i;
         SLT    : alu_result_o = $signed(alu_operand_1_i) < $signed(alu_operand_2_i);
         SLTU   : alu_result_o = alu_operand_1_i          < alu_operand_2_i;
         XOR    : alu_result_o = alu_operand_1_i          ^ alu_operand_2_i;
         SRL_SRA: begin   //Use only 1 shifter for both SRL and SRA
                     // for (int i = 0; i < alu_operand_2_i; i = i + 1) begin
                     //    operand_2_srl_sra = operand_2_srl_sra >> 1;       //srl by default

                     //    if (func7_5) begin
                     //       temp = {func7_5, operand_2_srl_sra};
                     //    end
                     // end

                     operand_2_srl_sra = operand_2_srl_sra >> alu_operand_2_i;

                     if (func7_5) begin
                        temp = {func7_5, operand_2_srl_sra};
                     end
                     else begin
                        temp = '0;
                     end
                     
                     if (func7_5) begin
                        alu_result_o = temp;
                     end else begin
                        alu_result_o = operand_2_srl_sra;
                     end
                     
                  end
         OR : alu_result_o = alu_operand_1_i          | alu_operand_2_i;
         AND: alu_result_o = alu_operand_1_i          & alu_operand_2_i;
      endcase
   end


endmodule