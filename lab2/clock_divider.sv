`timescale 1ns / 1ps

module clock_divider#(
    parameter DIVISOR = 100000
   )(
   input logic clk_in, //input 100 MHZ
   input logic rst, // Active High Reset
   output logic pulse_out // output 1 kHZ
    );
    logic [$clog2(DIVISOR)-1: 0] counter;
    
    always @(posedge clk_in) begin
    if(rst) begin
        counter <= 0;
        pulse_out <= 0;
    end else begin
        if(counter == DIVISOR - 1) begin
            pulse_out <= 1;
            counter <= 0;
        end else begin
            pulse_out <= 0;
            counter <= counter + 1;
        end
      end 
     end
    
endmodule
