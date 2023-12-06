module mux4x1(
	input [1:0] sel,
	input[31:0] dataIn1, dataIn2, dataIn3, dataIn4,
	output logic [31:0] dataOut
);
always_comb
begin
	case(sel)
	2'd0 : dataOut = dataIn1;
	2'd1 : dataOut = dataIn2;
	2'd2 : dataOut = dataIn3;
	2'd3 : dataOut = dataIn4;
	default : dataOut = dataIn1;
	endcase
end 
endmodule
