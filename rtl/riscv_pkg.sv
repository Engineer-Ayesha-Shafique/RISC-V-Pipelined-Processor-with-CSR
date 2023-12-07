package riscv_pkg;
   localparam DW = 32;
   localparam REG_SIZE = 32;
   localparam NO_OF_REGS_REG_FILE = 32;
   localparam REGW = $clog2(REG_SIZE);
   localparam MEM_SIZE_IN_KB = 1;
   localparam NO_OF_REGS = MEM_SIZE_IN_KB * 1024 / 4;
   localparam ADDENT = 4;
endpackage