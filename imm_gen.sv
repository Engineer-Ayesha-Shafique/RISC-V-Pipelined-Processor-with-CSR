module imm_gen
(
    input logic [31:0] inst,
    output logic [31:0] imm
);

    parameter I_Type_Alu    = 7'b0010011; // I type Arithmetic Logic Ops
    parameter I_Type_Load   = 7'b0000011; // I type Arithmetic Logic Ops
    parameter I_Type_Jalr   = 7'b1101111; // I type JALR
    parameter S_Type        = 7'b0100011; // S-type
    parameter B_TYPE        = 7'b1100011; // B-type
    parameter U_Type_LUI    = 7'b0110111; // U-type LUI
    parameter U_Type_AUIPC  = 7'b0010111; // U-type AUIPC
    parameter J_Type        = 7'b0010111; // J-Type
    parameter Z_Type        = 7'b1110011; // CSRRW Instruction
    always_comb
        case(inst[6:0])
            I_Type_Alu:/*I-type addi*/ 
                begin 
                    case (inst[14:12])           //   ->I-Type-Arithmetic-Logic
                        3'b010: imm = {20'b0, inst[31:20]}; // SLTIU (SetLessThanImmUnsigned) doing zero-extension since the operation is for unsigned immediate
                        3'b001: imm = {{27{inst[31]}}, inst[24:20]};
                        3'b101: imm = {{27{inst[31]}}, inst[24:20]};
                        default: 
                        begin
                            imm = {{21{inst[31]}}, inst[30:20]};
                        end
                    endcase
                end

            I_Type_Load:/*I-type lw*/
                imm = { {21{inst[31]}}, inst[30:20]};   // LW       -> I-Type-Load

            I_Type_Jalr:/*I-type jalr*/
                imm = { {21{inst[31]}}, inst[30:20]};   // JALR     -> I-Type-Jump

            S_Type:/*S-type */
                imm = { {21{inst[31]}}, inst[30:25], inst[11:7]};     // SW       -> S-Type

            U_Type_LUI /*LUI-type*/    : 
                imm = {inst[31:12], {12{1'b0}}};       // LUI      -> U-Type-LUI

            U_Type_AUIPC:/*AUIPC-type*/ 
                imm = { inst[31:12], {12{1'b0}} };             // AUIPC    -> U-Type-AUIPC

            J_Type:/*J-type jal*/
                imm = { {12{inst[31]}}, inst[19:12], inst[20], inst[30:21], {1{1'b0}}};  // JAL -> J-Type

            B_TYPE: /*B-type */
                imm = { {20{inst[31]}}, inst[7], inst[30:25], inst[11:8], {1{1'b0}}};  // BRANCH -> B-Type

			Z_Type: /*Z-type*/ // CSRRW
                imm = $signed(inst[31:20]);      // CSRRW    -> Z-Type
            default: 
                imm = { {21{inst[31]}}, inst[30:20]};
        endcase
    endmodule