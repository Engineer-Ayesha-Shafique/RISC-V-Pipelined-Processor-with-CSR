/////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2022 UET Lahore (All Rights Reserved)
//
// Project Name: RISC-V Core
// Module Name:  [forwarding_unit]
// Designer:     [AHSAN ALI]
// Description:  [The unit to solve RAW data hazards in RISC-V Core
//                actually both forwarding and stalling unit ]
//                
/////////////////////////////////////////////////////////////////////////////////

module forwarding_unit
   import riscv_pkg::*;
(
   // input  logic       clk_i,
   // input  logic       rst_i,
   input  logic [REGW-1:0] rs1_e,         //rs1 in execute stage
   input  logic [REGW-1:0] rs2_e,         //rs2 in execute stage
   input  logic [REGW-1:0] rd_m,          //rd in memory/wb stage (Becaue M and WB are same stages)
   input  logic            reg_write_m,
   input  logic            wb_sel_0,      //checks whether the inst was LOAD
   input  logic            br_taken,
   input  logic            is_mret,      //detection of mret instruction

   output logic            forward_a,     //forward to input A of ALU
   output logic            forward_b,      //forward to input B of ALU

   output logic            stall_mw,      //stall MW stage
   output logic            stall_fd,       //stall FD stage
   output logic            flush
);

/////////////////////////////////////////////////////////////////////////////////
   always_comb begin
      if (rs1_e == rd_m && reg_write_m && |rs1_e) begin
         forward_a = 1;
         forward_b = 0;
      end else if (rs2_e == rd_m && reg_write_m && |rs2_e) begin
         forward_b = 1;
         forward_a = 0;
      end else begin
         forward_a = 0;
         forward_b = 0;
      end
   end

   always_comb begin
      if (wb_sel_0 && (rs1_e == rd_m || rs2_e == rd_m)) begin
         stall_fd = 1;
         stall_mw = 1;
      end
      else begin
         stall_fd = 0;
         stall_mw = 0;   
      end
   end

   always_comb begin
      if (br_taken || is_mret) begin // || stall_fd
         flush = 1;
      end
      else begin
         flush = 0;
      end
   end
/////////////////////////////////////////////////////////////////////////////////

endmodule: forwarding_unit