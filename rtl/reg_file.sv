//register file for the processor

module reg_file #(
   parameter REG_SIZE = 32,
   parameter NO_OF_REGS = 32,
   parameter REGW = $clog2(REG_SIZE)
)(
   input  logic                clk_i,
   input  logic                rst_i,

   input  logic                we,
   input  logic [REGW-1:0]     raddr1_i,
   output logic [REG_SIZE-1:0] rdata1_o,

   input  logic [REGW-1:0]     raddr2_i,
   output logic [REG_SIZE-1:0] rdata2_o,

   input  logic [REGW-1:0]     waddr_i,
   input  logic [REG_SIZE-1:0] wdata_i
);

   //unpacked array can be veiwed in memory list of simulator, 
   //packed array cannot be seen in waveforms
   logic [REG_SIZE-1:0] reg_file [0:NO_OF_REGS-1];
   
   // initial begin  //this block is just for the testing of R-type instructions
   //    $readmemh("./reg_file.txt", reg_file);
   // end

   assign rdata1_o = (|raddr1_i) ? reg_file[raddr1_i] : '0;    //asynchronous read
   assign rdata2_o = (|raddr2_i) ? reg_file[raddr2_i] : '0;    //asynchronous read

   always_ff @(negedge clk_i, posedge rst_i) begin
      if (rst_i) begin //make sure that reg file is not written by rst for now only
         for (int i = 0; i < NO_OF_REGS; i = i + 1) begin 
            reg_file[i] <= 0;   //for now only
         end
      end else if ((|waddr_i) && (we == 1)) begin     //write addr is non-zero and we is 1'b1
         reg_file[waddr_i] <= wdata_i;
      end
   end
endmodule