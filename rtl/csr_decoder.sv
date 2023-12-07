//contains CSR registers and interrupt generation process from those registers

module csr_decoder #(
   parameter DW = 32,
   parameter ADDRW = 12

) (
   input  logic [6:0] opcode,
   input  logic [2:0] func3,

   output logic [2:0] csr_cntr  //number of CSR instructions are 6
);

   typedef enum logic [2:0] {
      CSRRW  = 3'b001,
      CSRRS  = 3'b010,
      CSRRC  = 3'b011,
      CSRRWI = 3'b101,
      CSRRSI = 3'b110,
      CSRRCI = 3'b111
   } csr_t;

   always_comb begin
      if (opcode == 7'b1110011) begin
         case(func3)
            CSRRW   : csr_cntr = 3'b000;
            CSRRS   : csr_cntr = 3'b001;
            CSRRC   : csr_cntr = 3'b010;
            CSRRWI  : csr_cntr = 3'b011;
            CSRRSI  : csr_cntr = 3'b100;
            CSRRCI  : csr_cntr = 3'b101;
            default : csr_cntr = 3'b000;
         endcase
      end

      else begin
         csr_cntr = 3'b000;
      end
   end

endmodule