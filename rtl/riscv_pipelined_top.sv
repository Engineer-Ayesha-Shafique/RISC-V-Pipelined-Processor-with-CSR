//top file of 3 stage pipelined riscv

module riscv_pipelined_top #(
   parameter  DW                  = 32,   //data width
   parameter  REG_SIZE            = 32,   //register size
   parameter  NO_OF_REGS_REG_FILE = 32,    //number of registers in register file
   parameter  MEM_SIZE_IN_KB      = 1,     //size of the instruction memory
   parameter  ADDENT              = 4,     //address entry
   parameter  ADDRW               = 12,    //address width
   localparam REGW                = $clog2(REG_SIZE),     //register width
   localparam NO_OF_REGS          = MEM_SIZE_IN_KB * 1024 / 4   //4 bytes in 32 bits
)(
   input  logic                  clk_i,
   input  logic                  rst_i,
   input  logic                  t_intr,   //timer interrupt
   input  logic                  e_intr   //external interrupt
);

   localparam ADDRW_DM = $clog2(NO_OF_REGS);

   logic [DW-1:0] pc_next;
   logic [DW-1:0] pc;
   logic [DW-1:0] inst_o;

   logic [6:0] opcode_f;
   logic [6:0] opcode_m;
   assign opcode_f = inst_o[6:0];   //declaration and assignment on the same line is prohibited
   
   logic [DW-1:0] instr_d;
   logic [6:0] opcode_d;
   assign opcode_d = instr_d[6:0];   //declaration and assignment on the same line is prohibited

   
   logic [2:0] func3;
   assign func3 = instr_d[14:12];
   
   logic [6:0] func7;
   assign func7 = instr_d[31:25];

   logic [DW-1:0] rdata1;
   logic [DW-1:0] rdata2;
   logic [DW-1:0] alu_result;
   logic [DW-1:0] scr_b;              //signal to support I-type

   //control signals
   logic          reg_write;
   logic          mem_write;
   logic [2:0]    imm_src;
   logic          alu_src;
   logic          alu_src_a;
   logic [1:0]    wb_sel;

   logic csr_we;
   logic csr_re;

   //extend unit signls
   logic [DW-1:0] imm_ext;

   //alu signals
   logic [DW-1:0] alu_operand_1;
   logic [2:0]    alu_control;

   //data memory signals
   logic [REG_SIZE-1:0] rdata_data_mem;
   logic [DW-1:0]       addr_data_mem;
   logic [DW-1:0]       data_l_o;
   logic [DW-1:0]       data_s_o;

   logic [3:0]          mask;

   //write back signals
   logic [REG_SIZE-1:0] data_wb;
   logic [REG_SIZE-1:0] pc_plus_4;

   //branch condition checker
   logic br_taken;

   logic [DW-1:0] pc_target;

   //pipelined signals
   logic [DW-1:0] pc_d;
   logic [DW-1:0] pc_plus_4_d;

   logic [DW-1:0] alu_out_e;
   logic [DW-1:0] alu_out_m;
   logic [DW-1:0] write_data_e;
   logic [DW-1:0] write_data_m;
   logic [REGW-1:0] rd_m;
   logic [DW-1:0] pc_plus_4_m;

   logic          reg_write_d;
   logic          reg_write_m;

   logic [1:0]    wb_sel_m;

   logic          mem_write_m;

   logic [2:0]    func3_m;

   logic [DW-1:0] imm_ext_d;

   logic [DW-1:0] instr_m;

   logic [DW-1:0] imm_csr_d;
   logic [DW-1:0] imm_csr_m;

   logic [DW-1:0] pc_m;

   logic [DW-1:0] rs1_m;

   //forwarding unit signals
   logic          forward_a;
   logic          forward_b;
   logic          stall_fd;
   logic          stall_mw;
   logic          flush;

   logic [DW-1:0] going_in_alu_a;
   logic [DW-1:0] going_in_alu_b;

   //CSR signals
   logic [DW-1:0] epc;
   logic [DW-1:0] data_csr_o; 

   logic          csr_we_m;
   logic          csr_re_m;
   logic          intr;
   logic          is_mret;
   logic [DW-1:0] pc_final;

   logic          t_intr_d;
   logic          e_intr_d;

   //peripheral bus related signals
   logic [3:0] mask_dm;

   logic [ADDRW_DM-1:0] addr_dm;
   logic [DW-1:0]       data_l_pb_o;  //data load from data memory and output of peripheral bus (pb) input to lsu
   logic [DW-1:0]       data_s_pb_o;  //data to be stored at data memory and output of peripheral bus (pb) input to lsu



pc #(
   .DW      (DW       )
)i_pc(
   .clk_i   (clk_i    ),
   .rst_i   (rst_i    ),
   .stall   (stall_fd ),
   .pc_next (pc_final ),
   .pc      (pc       )
);

logic flush_intr;   //flushing signal by interrupts

always_ff @ (posedge clk_i, posedge t_intr, posedge e_intr) begin
   if (t_intr || e_intr) begin
      flush_intr <= 1;
   end
   else begin
      flush_intr <= 0;
   end
end

pipeline_reg_1 #(
   .DW           (DW)
)i_pipeline_reg_1(
   .clk_i        (clk_i      ),
   .rst_i        (rst_i      ),
   
   .stall        (stall_fd   ),
   .flush        (flush || flush_intr     ),
   .instr_f      (inst_o     ),   //instruction in fetch stage
   .instr_d      (instr_d    ),   //instruction in decode stage

   .pc_f         (pc         ),   //PC in fetch stage
   .pc_d         (pc_d       ),   //PC in decode stage

   .pc_plus_4_f  (pc_plus_4  ),   //PC plus 4 in fetch stage
   .pc_plus_4_d  (pc_plus_4_d),   //PC plus 4 in decode stage
   .imm_ext_f    (imm_ext    ),
   .imm_ext_d    (imm_ext_d  )

);

mux_2x1 #(           //the mux to select PC+4 or PC+Target
   .DW   (DW        )
)i_mux_pc(
   .in0  (pc_next   ),
   .in1  (alu_result),
   .s    (br_taken  ),

   .out  (pc_target )
);

mux_2x1 #(           //the mux to select usual PC or EPC (exception PC)
   .DW   (DW         )
)i_mux_csr(
   .in0  (pc_target  ),
   .in1  (epc        ),
   .s    (t_intr_d || e_intr_d || is_mret  ),  //every of these is written because all write on PC.

   .out  (pc_final   )
);

adder #(
   .DW     (DW    ),
   .ADDENT (ADDENT)
)i_adder(
   .in     (pc     ),
   .out    (pc_next)
);



inst_mem #(
   .REG_SIZE       (REG_SIZE      ),
   .MEM_SIZE_IN_KB (MEM_SIZE_IN_KB),
   .NO_OF_REGS     (NO_OF_REGS    )
)i_inst_mem(
   .addr_i         (pc            ),
   .inst_o         (inst_o        )
);



reg_file #(
   .REG_SIZE   (REG_SIZE           ),
   .NO_OF_REGS (NO_OF_REGS_REG_FILE),
   .REGW       (REGW               )
)i_reg_file(
   .clk_i      (clk_i              ),
   .rst_i      (rst_i              ),

   .we         (reg_write_m        ),
   .raddr1_i   (instr_d[19:15]     ),
   .rdata1_o   (rdata1             ),

   .raddr2_i   (instr_d[24:20]     ),
   .rdata2_o   (rdata2             ),

   .waddr_i    (rd_m               ),
   .wdata_i    (data_wb            )
);

imm_generator #(
   .DW      (DW     )
)i_imm_generator(
   .inst    (instr_d),   //inst_o
   .s       (imm_src),
   .imm_ext (imm_ext)
);

mux_2x1 #(
   .DW  (DW            )
)i_mux_i_type(
   .in0 (going_in_alu_b),
   .in1 (imm_ext       ),   //imm_ext_d
   .s   (alu_src       ),
   .out (scr_b         )
);

branch_checker #(
   .REG_SIZE (REG_SIZE       )
)i_branch_checker(
   .rdata1   (going_in_alu_a ),    //rdata1
   .rdata2   (going_in_alu_b ),    //rdata2
   .opcode   (opcode_d       ),
   .func3    (instr_d[14:12] ),   //func3_d and not func3
   .br_taken (br_taken       )
);

mux_2x1 #(
   .DW  (DW            )
)i_mux_branch_pc(
   .in0 (pc_d          ),
   .in1 (going_in_alu_a),   //rdata1
   .s   (alu_src_a     ),   //according to Sir M. Tahir
   .out (alu_operand_1 )
);

alu_decoder #(
   .DW          (DW         )
)i_alu_decoder(
   .opcode      (opcode_d   ),  //opcode
   .func3       (func3      ),
   .func7_5     (func7[5]   ),

   .alu_control (alu_control)
);

alu_new #(   //reduced hardware
   .DW              (DW           )
)i_alu_new(
   .opcode          (opcode_d     ),   //opcode
   .func7_5         (func7[5]     ),

   .alu_operand_1_i (alu_operand_1),
   .alu_operand_2_i (scr_b        ),
   .alu_control     (alu_control  ),
   .alu_result_o    (alu_result   )
);

mux_2x1 #(
   .DW  (DW            )
)i_mux_forward_a(
   .in0 (rdata1        ),
   .in1 (alu_out_m     ),  //forward from memory stage  //previous: data_wb
   .s   (forward_a     ),
   .out (going_in_alu_a)
);

mux_2x1 #(
   .DW  (DW            )
)i_mux_forward_b(
   .in0 (rdata2        ),
   .in1 (alu_out_m     ),  //forward from memory stage  //previous: data_wb
   .s   (forward_b     ),
   .out (going_in_alu_b)
);

pipeline_reg_2 #(
   .DW           (DW           ),
   .REGW         (REGW         )
)i_pipeline_reg_2(
   .clk_i        (clk_i        ),
   .rst_i        (rst_i        ),
   
   .stall        (1'b0         ),    //stall_mw
   .alu_out_e    (alu_result   ),
   .alu_out_m    (alu_out_m    ),

   .write_data_e (rdata2       ),
   .write_data_m (write_data_m ),

   .rd_e         (instr_d[11:7]),
   .rd_m         (rd_m         ),

   .pc_plus_4_e  (pc_plus_4_d  ),    //because decode and execute stages are same
   .pc_plus_4_m  (pc_plus_4_m  ),

   .pc_d         (pc_d         ),
   .pc_m         (pc_m         ),

   .reg_write_d  (reg_write    ),
   .wb_sel_d     (wb_sel       ),
   .mem_write_d  (mem_write    ),

   .reg_write_m  (reg_write_m  ),
   .wb_sel_m     (wb_sel_m     ),
   .mem_write_m  (mem_write_m  ),

   .opcode_d     (opcode_d     ),
   .opcode_m     (opcode_m     ),

   .func3_d      (func3        ),
   .func3_m      (func3_m      ),

   .instr_d      (instr_d      ),
   .instr_m      (instr_m      ),

   .imm_csr_d    (imm_ext      ),
   .imm_csr_m    (imm_csr_m    ),

   .csr_we_d     (csr_we       ),  //from main_decoder
   .csr_we_m     (csr_we_m     ),

   .csr_re_d     (csr_re       ),  //from main_decoder
   .csr_re_m     (csr_re_m     ),

   .rs1_d        (going_in_alu_a),
   .rs1_m        (rs1_m        )
);

lsu #(
   .DW       (DW            )
)i_lsu(
   .opcode   (instr_m[6:0]  ),
   .func3    (instr_m[14:12]),        //func3

   .addr_in  (alu_out_m     ),    //alu_result
   .addr_out (addr_data_mem ),    

   .data_s   (write_data_m  ),
   .data_s_o (data_s_o      ),

   .data_l   (data_l_pb_o   ),     //rdata_data_mem
   .data_l_o (data_l_o      ),
   .mask     (mask          )
);



data_mem #(
   .DW             (DW            ),
   .MEM_SIZE_IN_KB (MEM_SIZE_IN_KB)
)i_data_mem(
   .clk_i          (clk_i         ),
   .rst_i          (rst_i         ),
   .we             (mem_write_m   ),
   .mask           (mask_dm       ),
   .addr_i         (addr_dm       ),
   .wdata_i        (data_s_pb_o   ),
   .rdata_o        (rdata_data_mem)
);

logic [2:0] csr_cntr;   //for all type of CSR instructions

csr_decoder #(
   .DW   (DW   ),
   .ADDRW(ADDRW)
) i_csr_decoder(
   .opcode  (instr_m[6:0]  ),
   .func3   (instr_m[14:12]),
   .csr_cntr(csr_cntr      )
);

csr_regs # (
   .DW       (DW             ),
   .ADDRW    (ADDRW          )
) i_csr_regs(
   .clk_i    (clk_i          ),
   .rst_i    (rst_i          ),

   .t_intr   (t_intr         ),     //timer interrupt
   .e_intr   (e_intr         ),     //external interrupt
   .is_mret  (is_mret        ),

   .csr_cntr (csr_cntr       ),

   .addr     (imm_csr_m[11:0]),
   .we       (csr_we_m       ),
   .re       (csr_re_m       ),

   .pc_i     (pc_m           ),
   .data_i   (rs1_m          ),

   .intr_flag(intr           ),
   .pc_o     (epc            ),
   .data_o   (data_csr_o     )

);

adder #(
   .DW     (DW       ),
   .ADDENT (ADDENT   )
)i_adder_j(
   .in     (pc       ),
   .out    (pc_plus_4)
);

mux_4x1 #(
   .DW   (DW         )
)i_mux_wb(
   .in0  (alu_out_m  ),           //alu_result
   .in1  (data_l_o   ),
   .in2  (pc_plus_4_m),           //for jumps and non-jumps (Branches also)
   .in3  (data_csr_o ),           //csr output data to be stored in reg_file
   .s    (wb_sel_m   ),
   .out  (data_wb    )            //forwarding will be taken from here
);

forwarding_unit
i_forwarding_unit(
   .rs1_e      (instr_d[19:15]),
   .rs2_e      (instr_d[24:20]),
   .rd_m       (instr_m[11:7] ),
   .reg_write_m(reg_write_m   ),
   .wb_sel_0   (wb_sel_m[0]   ),
   .br_taken   (br_taken      ),
   .is_mret    (is_mret       ),

   .forward_a  (forward_a     ),
   .forward_b  (forward_b     ),

   .stall_mw   (stall_mw      ),
   .stall_fd   (stall_fd      ),
   .flush      (flush         )
);

main_decoder i_main_decoder(
   .inst      (instr_d  ),   //inst
   
   .reg_write (reg_write),
   .mem_write (mem_write),
   .imm_src   (imm_src  ),
   .alu_src   (alu_src  ),
   .alu_src_a (alu_src_a),
   .wb_sel    (wb_sel   ),
   .csr_we    (csr_we   ),
   .csr_re    (csr_re   ),
   .is_mret   (is_mret  )
);



   // always_ff @ (posedge clk_i) begin
   //    //t_intr_d and e_intr_d are given to pc mux to select pc appropriately when interrupt comes
   //    // if configured
   //    if (intr) begin
   //       t_intr_d <= t_intr;
   //       e_intr_d <= e_intr;
   //    end

   //    //interrupt signal should not be generated if it is not configured
   //    else begin
   //       t_intr_d <= 0;
   //       e_intr_d <= 0;
   //    end
   // end

   always_ff @ (posedge clk_i) begin
      t_intr_d <= t_intr;
      e_intr_d <= e_intr;
      end

endmodule