`timescale 1ns / 1ps

module clock_divider#(
    parameter DIVISOR = 4
   )(
   input logic clk_in, //input 100 MHZ
   output logic pulse_out = 1'b0 // output 25 MHZ
    );
    logic [$clog2(DIVISOR)-1: 0] counter;
    
    always @(clk_in) begin // on every clock edge so Divisor is 4, we will have 4 clock edges before we toggle pulse_out

        if(counter == DIVISOR - 1) begin
            pulse_out <= !pulse_out;
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end 
     end
    
endmodule
