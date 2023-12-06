module mux2x1(
	input sel,
	input[31:0] dataIn1, dataIn2,  
	output logic [31:0] dataOut
);
always_comb
begin
	case(sel)
	1'd0: dataOut = dataIn1;
	1'd1: dataOut = dataIn2;
	default: dataOut = dataIn1;
	endcase
end 
endmodule

