module alu 
(
    input  logic [ 3:0] aluop,
    input  logic [31:0] opr_a,
    input  logic [31:0] opr_b,
    output logic [31:0] opr_res
);
   
    always_comb
    begin
        case(aluop)
            4'b0000:     opr_res = opr_a + opr_b;                       //add
            4'b1000:     opr_res = opr_a - opr_b;                       //sub
            4'b0001:     opr_res = opr_a << opr_b[4:0];	                //sll
            4'b0010:     opr_res = opr_a < opr_b;                       //slt
            4'b0011:     opr_res = $unsigned(opr_a) <  $unsigned(opr_b);//sltu
            4'b0100:     opr_res = opr_a ^ opr_b;                       //xor
            4'b0101:     opr_res = opr_a >> opr_b[4:0];                 //srl
            4'b1101:     opr_res = opr_a >>> opr_b[4:0];                //sra
            4'b0110:     opr_res = opr_a | opr_b;                       //or
            4'b0111:     opr_res = opr_a & opr_b;                       //and
            4'b1111:     opr_res = opr_b;                               //pass
                endcase
            end
endmodule
