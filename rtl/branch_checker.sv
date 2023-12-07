//a unit for both jump and branch instructions

module branch_checker #(
   parameter REG_SIZE = 32
)(
   input  logic [REG_SIZE-1:0] rdata1,
   input  logic [REG_SIZE-1:0] rdata2,

   input  logic [6:0]    opcode,
   input  logic [2:0]    func3,

   output logic          br_taken
);

   always_comb begin
      if (opcode == 7'd99) begin      //opcode for branch
         case (func3)
            3'b000: begin  //beq
               br_taken = (rdata1 == rdata2) ? 1 : 0;
            end
            3'b001: begin  //bne
               br_taken = (rdata1 != rdata2) ? 1 : 0;
            end
            3'b100: begin  //blt
               br_taken = ($signed(rdata1) < $signed(rdata2)) ? 1 : 0;
            end
            3'b101: begin  //bge
               br_taken = ($signed(rdata1) >= $signed(rdata2)) ? 1 : 0;
            end
            3'b110: begin  //bltu
               br_taken = (rdata1 < rdata2) ? 1 : 0;
            end
            3'b111: begin  //bgeu
               br_taken = (rdata1 >= rdata2) ? 1 : 0;
            end
            default: br_taken = 0;
         endcase
      end else if (opcode == 7'd103 || opcode == 7'd111) begin   //jumps
         br_taken = 1;
      end else begin
         br_taken = 0;
      end
   end



endmodule