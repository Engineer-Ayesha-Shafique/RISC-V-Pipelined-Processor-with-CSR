module inst_dec 
(
    input  logic [31:0] inst,
    output logic [ 4:0] rs1,
    output logic [ 4:0] rs2,
    output logic [ 4:0] rd,
    output logic [ 6:0] opcode,
    output logic [ 2:0] funct3,
    output logic [ 6:0] funct7
);
    assign opcode = inst[ 6: 0];
    assign rd     = inst[11: 7];
    assign rs1    = inst[19:15];
    assign rs2    = inst[24:20];
    assign funct3 = inst[14:12];
    assign funct7 = inst[31:25];

endmodule