module data_mem (
    input logic clk, wr_en, rd_en,
    input logic [31:0] addr,
    input logic [31:0] wdata,
    input logic [2:0] mem_mode,
    output logic [31:0] out_data
);

    parameter Byte = 3'b000;
    parameter HalfWord = 3'b001;
    parameter Word = 3'b010;
    parameter U_Byte = 3'b011;
    parameter U_HalfWord = 3'b100;

    logic [7:0] data_mem [100];

    //ASYNC LOAD
    always_comb
    begin
        if(rd_en)
        begin
        case(mem_mode)
            Byte:
                out_data = $signed(data_mem[addr]);
            HalfWord:
                out_data = $signed({data_mem[addr+1], data_mem[addr]});
            Word:
                out_data = $signed({data_mem[addr+3], data_mem[addr+2], data_mem[addr+1], data_mem[addr]});
            U_Byte:
                out_data = {24'b0,{data_mem[addr]}};
            U_HalfWord:
                out_data = {16'b0,{data_mem[addr]}};
	    endcase
        end
    end

    //SYNC STORE
    always_ff @( posedge clk )
    begin
        case (mem_mode)
            Byte:
            begin
                data_mem[addr] <= wdata[7:0];
            end
            HalfWord:
            begin
                data_mem[addr]   <= wdata[7:0];
                data_mem[addr+1] <= wdata[15:8];
            end
            Word:
            begin
                data_mem[addr]   <= wdata[ 7: 0];
                data_mem[addr+1] <= wdata[15: 8];
                data_mem[addr+2] <= wdata[23:16];
                data_mem[addr+3] <= wdata[31:24];
            end
        endcase

    end

endmodule