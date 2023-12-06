module reg_file 
(
    input  logic        clk,
    input  logic        rf_en,
    input  logic [ 4:0] rs1,
    input  logic [ 4:0] rs2,
    input  logic [ 4:0] waddr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata1,
    output logic [31:0] rdata2
);

    logic [31:0] reg_mem [32];

    // asynchronous read
    always_comb 
    begin 
        rdata1 = reg_mem[rs1];
        rdata2 = reg_mem[rs2];

    end

    // synchronus write
    always_ff @(posedge clk) 
    begin
        if(rf_en)
        begin
            if(waddr != 5'b00000)
            begin
                reg_mem[waddr] <= wdata;
            end
        end
    end

endmodule