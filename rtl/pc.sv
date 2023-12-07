//making PC register for processor

module pc #(
   parameter DW = 32
)(
   input  logic clk_i,
   input  logic rst_i,
   input  logic stall,

   input  logic [DW-1:0] pc_next,
   output logic [DW-1:0] pc
);

   always_ff @ (posedge clk_i, posedge rst_i) begin
      if (rst_i) begin
         pc <= 0;
      end else if (!stall) begin
         pc <= pc_next;
      end
   end
endmodule