module processor 
(
    input logic clk,
    input logic rst
); 
    // wires
    logic        rf_en;
    logic        sel_a;
    logic        sel_b;
    logic [1:0]  wb_sel;
    logic        rd_en;
    logic        wr_en;
    logic [31:0] pc_in;
    logic [31:0] pc_out;
    logic [31:0] inst;
    logic [ 4:0] rd;
    logic [ 4:0] rs1;
    logic [ 4:0] rs2;
    logic [ 6:0] opcode;
    logic [ 2:0] funct3;
    logic [ 6:0] funct7;
    logic [31:0] rdata1;
    logic [31:0] rdata2;
    logic [31:0] wdata;
    logic [3 :0] aluop;
    logic [31 :0] imm;
    logic [31 :0] alu_out;
    logic [31:0] opr_a;
    logic [31:0] opr_b;
    logic [31:0] data_mem_out;
    logic [2:0] mem_mode;
    logic [2:0] br_type;
    logic br_taken;
    logic jump;


    logic CSR_reg_wr, CSR_reg_rd, CSR_reg_wrMW, CSR_reg_rdMW, is_mret, is_mretMW, CSR_epc_taken;
	logic [1:0]  CSR_interrupt;
	logic [11:0] CSR_addr;
	logic [31:0] CSR_wdata, CSR_rdata, CSR_PC, CSR_epc, CSR_prior_PC;

    // program counter
    pc pc_i
    (
        .clk   ( clk            ),
        .rst   ( rst            ),
        .pc_in ( pc_in          ),
        .pc_out( pc_out         )
    );


    // instruction memory
    inst_mem inst_mem_i
    (
        .addr  ( pc_out         ),
        .data  ( inst           )
    );

    //imm_gen

    imm_gen imm_gen_i
    (
        .inst  ( inst         ),
        .imm   ( imm        )
    );




    // instruction decoder
    inst_dec inst_dec_i
    (
        .inst  ( inst           ),
        .rs1   ( rs1            ),
        .rs2   ( rs2            ),
        .rd    ( rd             ),
        .opcode( opcode         ),
        .funct3( funct3         ),
        .funct7( funct7         )
    );

    // register file
    reg_file reg_file_i
    (
        .clk   ( clk            ),
        .rf_en ( rf_en          ),
        .waddr ( rd             ),
        .rs1   ( rs1            ),
        .rs2   ( rs2            ),
        .rdata1( rdata1         ),
        .rdata2( rdata2         ),
        .wdata ( wdata          )
        
    );


    // controller
    controller controller_i
    (
        .opcode( opcode         ),
        .funct3( funct3         ),
        .funct7( funct7         ),
        .aluop ( aluop          ),
        .rf_en ( rf_en          ),
        .sel_b ( sel_b          ),
        .sel_a ( sel_a          ),
        .wb_sel( wb_sel         ),
        .rd_en ( rd_en          ),
        .wr_en ( wr_en          ),
        .mem_mode(mem_mode),
        .br_type(br_type),
        .jump(jump),
        .CSR_reg_rd(CSR_reg_rd),
        .CSR_reg_wr(CSR_reg_wr),
        .is_mret(is_mret)
    );

    // alu
    alu alu_i
    (
        .aluop   ( aluop          ),
        .opr_a   ( opr_a         ),
        .opr_b   ( opr_b          ),
        .opr_res ( alu_out          )
    );


    //Branch condition
    branch_cond branch_cond_i(
        .rdata1(rdata1),
        .rdata2(rdata2),
        .br_type(br_type),
        .br_taken(br_taken)
    );
    // data memory
    data_mem data_mem_i
    (
        .clk      ( clk           ),
        .rd_en    ( rd_en         ),
        .wr_en    ( wr_en         ),
        .addr     ( alu_out         ),
        .wdata  ( rdata2        ),
        .mem_mode ( mem_mode      ),
        .out_data ( data_mem_out  )
    );
    //ALL MUX

    //sel_a_mux
    mux2x1 sel_a_mux
    (
        .sel(sel_a),
        .dataIn1(rdata1),
        .dataIn2(pc_out),
        .dataOut(opr_a)
    );

    //sel_b_mux for I-type
    mux2x1 sel_b_mux
    (
        .sel(sel_b),
        .dataIn1(rdata2),
        .dataIn2(imm),
        .dataOut(opr_b)
    );

    //write back selection for load instructions
    mux4x1 wb_sel_mux
    (
        .sel(wb_sel),
        .dataIn1(alu_out),
        .dataIn2(data_mem_out),
        .dataIn3(pc_out+4),
        .dataIn4(CSR_wdata),
        .dataOut(wdata)
    );

    mux2x1 pc_sel_mux
    (
        .sel(br_taken | jump),
        .dataIn1(pc_out + 32'd4),
        .dataIn2(alu_out),
        .dataOut(pc_in)
    );
    

    CSR_RegisterFile	CSR_register_file(
        .clk(clk), 
        .rst(rst), 
        .addr(CSR_addr[11:0]), 
        .wdata(CSR_wdata), 
        .pc(pc_out), 
        .interrupt(CSR_interrupt), 
        .csr_wr(CSR_reg_wrMW), 
        .csr_rd(CSR_reg_rdMW), 
        .is_mret(is_mretMW), 
        .inst(inst),       
        .epc_taken(CSR_epc_taken), 
        .rdata(CSR_rdata), 
        .exc_pc(CSR_epc)
        );
    


    
endmodule

