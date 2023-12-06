module controller
(   input  logic [6:0] opcode,
    input  logic [6:0] funct7,
    input  logic [2:0] funct3,
    output logic [3:0] aluop,

    output logic       rf_en,
    //selection of operand B in ALU
    output logic       sel_b,       //0: immediate, 1: register
    output logic       sel_a,       //0: register, 1: PC
    output logic [1:0] wb_sel,      //0: ALU, 1: MEM, 2: PC
    //data memory signals
    output logic       rd_en,       //0: read disable, 1: read enable
    output logic       wr_en,       //0: write disable, 1: write enable
    output logic [2:0] mem_mode,    //000: byte, 001: half word, 010: word, 
    output logic [2:0] br_type,     //000: beq, 001: bne, 010: no branch, 011: unconditional branch, 
                                    //100: blt, 101: bge, 110: bltu, 111: bgeu
    output logic       jump,

    output logic CSR_reg_rd,
    output logic CSR_reg_wr,
    output logic is_mret

);

    parameter R_Type        = 7'b0110011; // R-type    // 0x33
    parameter I_Type_Alu    = 7'b0010011; // I type Ops // 0x13
    parameter I_Type_Load   = 7'b0000011; // I type load // 0x03
    parameter I_Type_Jalr   = 7'b1100111; // I type JALR    // 0x67
    parameter S_Type        = 7'b0100011; // S-type     // 0x23
    parameter B_TYPE        = 7'b1100011; // B-type     // 0x63
    parameter U_Type_LUI    = 7'b0110111; // U-type LUI // 0x37
    parameter U_Type_AUIPC  = 7'b0010111; // U-type AUIPC// 0x17
    parameter J_Type        = 7'b1101111; // J-Type  
    parameter Z_Type        = 7'b1110011; // CSRRW Instruction

    parameter ADD           = 4'b0000;  // ADD
    parameter NULL         = 4'b1111;  // NULL


    parameter NB        = 3'b010; //No branch

    always_comb
    begin
        case(opcode)
            R_Type: // R-type
                begin
                    $display("R-Type\n");
                    sel_a   = 1'b0;
                    sel_b   = 1'b0;
                    rf_en  = 1'b1;
                    wb_sel = 2'd0;
                    br_type = NB;
                    jump =0;
                
                    aluop = {funct7[5],funct3} ;

                    CSR_reg_wr = 0; 
				    CSR_reg_rd = 0;
				    is_mret = 0;
                end

            I_Type_Alu: // I type Arithmetic Logic Ops
                begin
                    $display("I-Type\n");
                    sel_a   = 1'b0;
                    sel_b   = 1'b1;
                    rf_en  = 1'b1;
                    wb_sel = 2'd0;
                    br_type = NB;
                    jump =0;
                    case(funct3) 
                        3'b101:
                        aluop = {funct7[5],funct3} ;
                        default:
                        aluop = {1'b0,funct3} ;
                    endcase   

                    CSR_reg_wr = 0; 
				    CSR_reg_rd = 0;
				    is_mret = 0;
                end
            I_Type_Load: // Load
                begin
                    $display("Load\n");
                    sel_a  = 1'b0;
                    sel_b  = 1'b1;
                    rd_en = 1'b1;
                    wr_en = 1'b0;
                    rf_en  = 1'b1;
                    wb_sel = 2'd1;
                    aluop = ADD;
                    br_type = NB;
                    jump =0;
                    mem_mode = funct3;
                    // 3'b000: //LB
                    // 3'b001: //LH
                    // 3'b010: //LW
                    // 3'b100: //LBU
                    // 3'b101: //LHU

                    CSR_reg_wr = 0; 
				    CSR_reg_rd = 0;
				    is_mret = 0;

                end
            I_Type_Jalr: // JALR
                begin
                    $display("JALR\n");
                    sel_a  = 1'b0;
                    sel_b  = 1'b1;
                    rf_en  = 1'b1;
                    wb_sel = 2'd2;
                    aluop = ADD;
                    jump =1;
                    //br_type = UC;
                    br_type = NB;
                    CSR_reg_wr = 0; 
				    CSR_reg_rd = 0;
				    is_mret = 0;
                end
            S_Type: // Store
                begin
                    $display("Store\n");
                    sel_a   = 1'b0;
                    sel_b   = 1'b1;
                    rd_en = 1'b0;
                    wr_en = 1'b1;
                    rf_en  = 1'b0;
                    jump = 0;
                    aluop = ADD;
                    br_type = NB;
                    mem_mode = funct3;
                    // 3'b000: //SB
                    // 3'b001: //SH
                    // 3'b010: //SW

                    CSR_reg_wr = 0; 
				    CSR_reg_rd = 0;
				    is_mret = 0;
                end
            B_TYPE: // Branch
                begin
                    $display("Branch\n");
                    sel_a  = 1'b1;
                    sel_b  = 1'b1;
                    rf_en  = 1'b0;
                    aluop = ADD;
                    br_type = funct3;
                    // 3'b000: //beq
                    // 3'b001: //bne
                    // 3'b100: //blt
                    // 3'b101: //bge
                    // 3'b110: //bltu
                    // 3'b111: //bgeu
                    // 3'b010: //no branch

                    CSR_reg_wr = 0; 
				    CSR_reg_rd = 0;
				    is_mret = 0;
                end
            U_Type_LUI: // LUI
                begin
                    $display("LUI\n");
                    sel_b  = 1'b1;
                    rf_en  = 1'b1;
                    wb_sel = 2'd0;
                    aluop = NULL;
                    jump = 0;   
                    br_type = NB;

                    CSR_reg_wr = 0; 
				    CSR_reg_rd = 0;
				    is_mret = 0;

                end
            U_Type_AUIPC: // AUIPC
                begin
                    $display("AUIPC\n");
                     rf_en = 1;
                    aluop = ADD;
                    sel_a = 1;
                    sel_b = 1;
                    wb_sel = 2'd0;
                    jump = 0;
                    br_type = NB;

                    CSR_reg_wr = 0; 
				    CSR_reg_rd = 0;
				    is_mret = 0;
                end
            J_Type: // JAL
                begin
                    $display("JAL\n");
                    sel_a  = 1'b1;
                    sel_b  = 1'b1;
                    rf_en  = 1'b1;
                    wb_sel = 2'd2;
                    aluop = ADD;
                    jump = 1;
                    br_type = NB;

                    CSR_reg_wr = 0; 
				    CSR_reg_rd = 0;
				    is_mret = 0;
                end
            Z_Type: // CSRRW
                begin
                    $display("CSRRW\n");
                    sel_a  = 1'b1;
                    sel_b  = 1'b0;
                    rf_en  = 1'b1;
                    wb_sel = 2'd3;
                    wr_en = 1'b1;
                    aluop = NULL;
                    case (funct3)
                    3'b000: 
                        begin  
                            is_mret <= 1; 
                            CSR_reg_wr = 0; 
                            CSR_reg_rd = 0; 
                            end // MRET instruction
		        	3'b001: 
                        begin  
                            is_mret <= 0; 
                            CSR_reg_wr = 1; 
                            CSR_reg_rd = 0; 
                        end // CSRRW instruction
		        	3'b010: 
                        begin  
                            is_mret <= 0; 
                            CSR_reg_wr = 0; 
                            CSR_reg_rd = 1; 
                        end // CSRRS instruction
				    endcase
                    jump = 0;
                    br_type = NB;

                end               
            default:
                begin
                    rf_en  = 1'b0;
                    sel_a  = 1'b0;
                end
        endcase
    end

endmodule

