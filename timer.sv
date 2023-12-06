module timer (
    input  logic clk,
    input  logic rst,
    output logic timer_interrupt
);
    parameter TIMER_LIMIT = 50000; // clock frequency

    reg [31:0] timer_counter;
    
    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            timer_counter <= 0;
        end
        else
        begin
            timer_counter <= timer_counter + 1;
            if (timer_counter == TIMER_LIMIT)
            begin
                timer_counter <= 0;
                timer_interrupt <= 1;
            end
            else
            begin
                timer_interrupt <= 0;
            end
        end
    end

endmodule