module CSR_RegisterFile(

    input logic clk, rst, 
    input logic [11:0] addr,    //address of register to be read/written
    input logic [31:0] wdata,   //data to be written
    input logic [31:0] pc, 
    input logic [1:0] interrupt,//   input  logic trap,
    input  logic csr_rd,        // control signal for read
    input  logic csr_wr,        // control signal for write
    input  logic is_mret,       // control signal for MRET inst
    input logic [31:0] inst,   // instruction to be executed 
    output logic epc_taken,     // control signal for epc
    output logic [31:0] rdata,  //data to be read
    output logic [31:0] exc_pc  //exception pc
    );

    logic [31:0] mstatus, mie, mepc, mip, mtvec, mcause;
    
    
    always_ff @(posedge clk) begin
		if (rst) begin
			mstatus	<= 0;
			mie		<= 0;
			mip		<= 2176;
			mtvec	<= 0;
			mcause	<= 0;
		end
		else if (csr_wr) begin
			case (addr)
				768: mstatus <= wdata;
				772: mie	 <= wdata;
				773: mtvec	 <= wdata;
			endcase
        end
    end

    always_comb begin
		rdata <= 0;
        if (csr_rd) begin
			case (addr)
				768: rdata <= mstatus;
				772: rdata <= mie;
				773: rdata <= mtvec;
			endcase
        end
    end
		
    always_comb begin
    	if (interrupt == 1) begin
    		mepc <= pc;
    		epc_taken <= 1;
    		exc_pc <= 4;
    	end else if (is_mret) begin
    		epc_taken <= 1;
    		exc_pc <= mepc;
    	end
    	else epc_taken <= 0;
    end

endmodule
// module csr_reg 
// (
//     input logic [31:0] addr,
//     input logic [31:0] wdata,
//     input logic [31:0] pc,
//     input logic [11:0] inst,
//     input logic        interrupt,

//     output logic [31:0] rdata,
//     output logic [31:0] epc,
//     output logic [31:0] reg_wr
// );

//     logic [31:0] mip;
//     logic [31:0] mie;
//     logic [31:0] mstatus;
//     logic [31:0] mepc;

// // read - async

//     always_comb begin
//         case (addr)
//             12'h4E0 : rdata = mstatus;
//             12'h4E1 : rdata = mie;
//             12'h4E2 : rdata = mip;
//             12'h4E3 : rdata = mepc;
//         endcase
//     end

// // write - sync

//     always_ff @(*)
//     begin
//         if (reg_wr)
//         begin
//             case (addr)
//                 12'h300: mstatus <= wdata;
//                 12'h304: mie     <= wdata;
//                 12'h341: mepc    <= wdata;
//                 12'h344: mip     <= wdata; 
//             endcase
//         end
//     end

// endmodule
