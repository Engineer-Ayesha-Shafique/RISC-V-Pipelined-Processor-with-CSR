module branch_cond (
    input logic [31:0] rdata1,
    input logic [31:0] rdata2,
    input logic [2:0] br_type,
    output logic br_taken
);


    parameter EQUAL     = 3'b000;  //beq
    parameter NOTEQUAL  = 3'b001; //bne
    parameter NB        = 3'b010; //No branch
    //parameter UC = 3'b011; //unconditional branch
    parameter LESSTHAN  = 3'b100;    //blt
    parameter GREATEREQ = 3'b101;  //bge
    parameter ULESSTHAN = 3'b110;  //bltu
    parameter UGREATEREQ = 3'b111;  //bgeu  

    

    always_comb
    begin
        case (br_type)
            EQUAL:      //beq
                br_taken = $signed(rdata1) == $signed(rdata2) ? 1 : 0;
            NOTEQUAL:   //bne
                br_taken = $signed(rdata1) != $signed(rdata2) ? 1 : 0;
            LESSTHAN:   //blt
                br_taken = $signed(rdata1) < $signed(rdata2) ? 1 : 0;
            GREATEREQ:  //bge
                br_taken = $signed(rdata1) >= $signed(rdata2) ? 1 : 0;
            ULESSTHAN:  //bltu
                br_taken = $unsigned(rdata1) < $unsigned(rdata2) ? 1 : 0;
            UGREATEREQ: //bgeu 
                br_taken = $unsigned(rdata1) >= $unsigned(rdata2) ? 1 : 0;
            NB:         //No branch
                br_taken = 0;
            default:
                br_taken = 0;
        endcase
    end

endmodule