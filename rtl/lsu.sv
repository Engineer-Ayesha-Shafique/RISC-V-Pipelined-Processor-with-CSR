module lsu #(
   parameter DW = 32
)(
   input  logic [6:0]    opcode,
   input  logic [2:0]    func3,

   input  logic [DW-1:0] addr_in,     //from alu out
   output logic [DW-1:0] addr_out,    //to mem

   input  logic [DW-1:0] data_s,      //data to be stored
   output logic [DW-1:0] data_s_o,    //data to be stored manipulated by LSU

   input  logic [DW-1:0] data_l,      //data to be loaded
   output logic [DW-1:0] data_l_o,     //data to be loaded manipulated by LSU

   output logic [3:0]    mask
);

   logic [7:0] rdata_byte;
   logic [15:0] rdata_hword;
   logic [DW-1:0] rdata_word;

//there is no masking in case of LOAD BYTES and LOAD HALF WORDS
//for this, we have to have mask in register file

   assign addr_out = addr_in;

   always_comb begin
      if (opcode == 7'b0000011) begin
         rdata_byte  = '0;
         rdata_hword = '0;
         rdata_word  = '0;

         case(func3)
            3'b000, 3'b100: begin   //LB, LBU
               case(addr_in[1:0])
                  2'b00: begin
                     rdata_byte = data_l[7:0];
                  end
                  2'b01: begin
                     rdata_byte = data_l[15:8];
                  end
                  2'b10: begin
                     rdata_byte = data_l[23:16];
                  end
                  2'b11: begin
                     rdata_byte = data_l[31:24];
                  end                  
               endcase
            end

            3'b001, 3'b101: begin   //LH, LHU
               case(addr_in[1])
                  1'b0: begin
                     rdata_hword = data_l[15:0];
                  end
                  1'b1: begin
                     rdata_hword = data_l[31:16];
                  end
               endcase
            end

            3'b010: begin
               rdata_word = data_l;
            end
         endcase
      end
   end

   always_comb begin
      if (opcode == 7'b0000011) begin
         case(func3)
            3'b000: data_l_o = {{24{rdata_byte[7]}},   rdata_byte };  //LB
            3'b100: data_l_o = {{24{1'b0}},            rdata_byte };  //LBU
            3'b001: data_l_o = {{16{rdata_hword[15]}}, rdata_hword};  //LH
            3'b101: data_l_o = {{16{1'b0}},            rdata_hword};  //LHU
            3'b010: data_l_o = {                       rdata_word };  //LW
         endcase
      end
   end

   always_comb begin
      if (opcode == 7'b0100011) begin
         data_s_o = '0;
         mask = '0;

         case(func3)
            3'b000: begin   //SB
               case(addr_in[1:0])
                  2'b00: begin
                     data_s_o[7:0] = data_s[7:0];
                     mask = 4'b0001;
                  end
                  2'b01: begin
                     data_s_o[15:8] = data_s[15:8];
                     mask = 4'b0010;
                  end
                  2'b10: begin
                     data_s_o[23:16] = data_s[23:16];
                     mask = 4'b0100;
                  end
                  2'b11: begin
                     data_s_o[31:24] = data_s[31:24];
                     mask = 4'b1000;
                  end
               endcase
            end
            3'b001: begin   //SH
               case(addr_in[1])
                  1'b0: begin
                     data_s_o[15:0] = data_s[15:0];
                     mask = 4'b0011;
                  end
                  1'b1: begin
                     data_s_o[31:16] = data_s[31:16];
                     mask = 4'b1100;
                  end
               endcase
            end
            3'b010: begin   //SW
               data_s_o = data_s;
               mask = 4'b1111;
            end
         endcase
      end
   end

   
   // always_comb begin
   //    if (opcode ==  7'b0000011) begin            //LOADS
   //       case (func3)
   //          3'b000: data_l_o = {{24{data_l[7]}},  data_l[7:0] };  //LB
   //          3'b001: data_l_o = {{16{data_l[15]}}, data_l[15:0]};  //LH
   //          3'b010: data_l_o = {                  data_l      };  //LW
   //          3'b100: data_l_o = {{24{1'b0}},       data_l[7:0] };  //LBU
   //          3'b101: data_l_o = {{16{1'b0}},       data_l[15:0]};  //LHU
   //       endcase

   //    end else if (opcode == 7'b0100011) begin   //STORE
   //       case(func3)
   //          3'b000: data_s_o = {{24{1'b0}},  data_s[7:0] }; //SB
   //          3'b001: data_s_o = {{16{1'b0}},  data_s[15:0]}; //SH
   //          3'b010: data_s_o = {             data_s      }; //SW
   //       endcase
   //    end
   // end
endmodule