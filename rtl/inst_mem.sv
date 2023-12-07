//instruction memory for the processor

module inst_mem #(
   parameter REG_SIZE = 32,
   parameter MEM_SIZE_IN_KB = 1,   //size of the instruction memory
   parameter NO_OF_REGS = MEM_SIZE_IN_KB * 1024 / 4    //4 bytes in 32 bits
)(
   input  logic [REG_SIZE-1:0] addr_i,     //PC will be given in place of it
   output logic [REG_SIZE-1:0] inst_o
);

   logic [REG_SIZE-1:0] inst_mem [0:NO_OF_REGS-1];

   initial begin
      $readmemh("sim/machine_codes.mem", inst_mem);
   end
   
   always_comb begin 
      inst_o = inst_mem[addr_i[REG_SIZE-1:2]];  //making it byte addressible
   end

endmodule