//CSR register file

module csr_regs # (
   parameter DW    = 32,
   parameter ADDRW = 12
) (
   input  logic             clk_i,
   input  logic             rst_i,

   input  logic             t_intr,     //timer interrupt
   input  logic             e_intr,     //external interrupt
   input  logic             is_mret,
   
   input  logic [2:0]       csr_cntr,

   input  logic [ADDRW-1:0] addr,
   input  logic             we,
   input  logic             re,

   input  logic [DW-1:0]    pc_i,
   input  logic [DW-1:0]    data_i,

   output logic             intr_flag,
   output logic [DW-1:0]    pc_o,
   output logic [DW-1:0]    data_o

);

   parameter [ADDRW-1:0] MSTATUS_ADDR = 12'h300;
   parameter [ADDRW-1:0] MIE_ADDR     = 12'h304;
   parameter [ADDRW-1:0] MTVEC_ADDR   = 12'h305;
   parameter [ADDRW-1:0] MEPC_ADDR    = 12'h341;
   parameter [ADDRW-1:0] MCAUSE_ADDR  = 12'h342;
   parameter [ADDRW-1:0] MIP_ADDR     = 12'h344;

   //internal registers of CSR register file
   logic [DW-1:0] mstatus_ff;
   logic [DW-1:0] mie_ff;
   logic [DW-1:0] mtvec_ff;
   logic [DW-1:0] mepc_ff;
   logic [DW-1:0] mcause_ff;
   logic [DW-1:0] mip_ff;

   always_comb begin  //asynchrounus read from CSRs
      if (re) begin
         case(addr)
            MSTATUS_ADDR : data_o = mstatus_ff; //mstatus
            MIE_ADDR     : data_o = mie_ff;     //mie
            MTVEC_ADDR   : data_o = mtvec_ff;   //mtvec
            MEPC_ADDR    : data_o = mepc_ff;    //mepc
            MCAUSE_ADDR  : data_o = mcause_ff;  //mcause
            MIP_ADDR     : data_o = mip_ff;     //mip
         endcase
      end
      else begin
         data_o <= '0;
      end
   end

   always_ff @ (negedge clk_i, posedge rst_i) begin  //write at negative edge
      if (rst_i) begin
         mstatus_ff <= '0;
         mie_ff     <= '0;
         mtvec_ff   <= '0;
         // mepc_ff    <= '0;
         // mcause_ff  <= '0;
         // mip_ff     <= '0;
      end

      else if (we) begin
         case(addr)
            MSTATUS_ADDR : begin
               if (csr_cntr == 3'b000 || csr_cntr == 3'b001 || csr_cntr == 3'b011 || csr_cntr == 3'b100) begin   //CSRRW | CSRRS | CSRRWI | CSRRSI
                  mstatus_ff <= data_i;   //mstatus
               end
               else if (csr_cntr == 3'b010 || csr_cntr == 3'b101) begin  //CSRRC | CSRRCI
                  mstatus_ff <= ~data_i;   //because is is csr read and clear
               end
               else begin
                  mstatus_ff <= data_i;
               end
            end

            MIE_ADDR     : begin
               if (csr_cntr == 3'b000 || csr_cntr == 3'b001 || csr_cntr == 3'b011 || csr_cntr == 3'b100) begin   //CSRRW | CSRRS | CSRRWI | CSRRSI
                  mie_ff <= data_i;   //mie_ff
               end
               else if (csr_cntr == 3'b010 || csr_cntr == 3'b101) begin  //CSRRC | CSRRCI
                  mie_ff <= ~data_i;   //because is is csr read and clear
               end
               else begin
                  mie_ff <= data_i;
               end
            end

            MTVEC_ADDR   : begin
               if (csr_cntr == 3'b000 || csr_cntr == 3'b001 || csr_cntr == 3'b011 || csr_cntr == 3'b100) begin   //CSRRW | CSRRS | CSRRWI | CSRRSI
                  mtvec_ff <= data_i;   //mtvec_ff
               end
               else if (csr_cntr == 3'b010 || csr_cntr == 3'b101) begin  //CSRRC | CSRRCI
                  mtvec_ff <= ~data_i;   //because is is csr read and clear
               end
               else begin
                  mtvec_ff <= data_i;
               end
            end

         endcase
      end

   end

   localparam MTIP = 7;
   localparam MEIP = 11; 

   always_ff @ (posedge clk_i, posedge rst_i) begin
      if (rst_i) begin
         mip_ff <= '0;
      end
      if (t_intr) begin
         mip_ff[MTIP] <= 1'b1;
      end
      if (e_intr) begin
         mip_ff[MEIP] <= 1'b1;
      end
      else if (is_mret) begin
         mip_ff <= '0;
      end
   end

   always_ff @ (posedge t_intr, posedge e_intr, posedge rst_i ) begin
      if (rst_i) begin
         mepc_ff <= '0;
      end
      else begin
         mepc_ff    <= pc_i;
      end
   end
     
   always_ff @ (posedge clk_i, posedge rst_i, posedge t_intr) begin
      if (t_intr) begin
         mcause_ff <= 32'h2;
      end
      else if (e_intr) begin
         mcause_ff <= 32'h3;
      end
      else if (we && (addr == MCAUSE_ADDR)) begin
         mcause_ff <= data_i;
      end
      // else begin
      //    mcause_ff <= '0;
      // end
   end

csr_ops # (
   .DW(DW)
) i_csr_ops(

   .mstatus_reg(mstatus_ff),
   .mie_reg    (mie_ff    ),
   .mtvec_reg  (mtvec_ff  ),
   .mepc_reg   (mepc_ff   ),
   .mcause_reg (mcause_ff ),
   .mip_reg    (mip_ff    ),

   .is_mret    (is_mret   ),
   .intr_flag  (intr_flag ),
   .where_to_go(pc_o      )   //where we will go when interrupt comes, PC out


);

endmodule