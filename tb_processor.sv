module tb_processor();


    logic clk;
    logic rst;

    processor dut 
    (
        .clk ( clk ),
        .rst ( rst )
    );
    // clock generator
    initial
    begin
        clk = 0;
        forever
        begin
            #5 clk = 1;
            #5 clk = 0;
    end
    end 

        // reset generator
    initial
    begin
        rst = 1;
        #10;
        rst = 0;
        #150;

        //Test case : For conditional jumps: 
        //$display("x2: %h", dut.reg_file_i.reg_mem[2]);

        //For storing 32bit immediate in register
        // $display("x6: %h", dut.reg_file_i.reg_mem[6]);
        // $display("x7: %h", dut.reg_file_i.reg_mem[7]);

        //For finding a gcd of two numbers
        $display("GCD of 12 and 9: x9: %h", dut.reg_file_i.reg_mem[8]);

        //load store
        // $display ("x10: %h", dut.reg_file_i.reg_mem[10]);
        $finish;
    end

    // initialize memory
    initial
    begin
        $readmemh("inst.mem", dut.inst_mem_i.mem);
        $readmemb("rf.mem", dut.reg_file_i.reg_mem);
    end

    // dumping the waveform
    initial
    begin
        $dumpfile("processor.vcd");
        $dumpvars(0, dut);
    end

endmodule