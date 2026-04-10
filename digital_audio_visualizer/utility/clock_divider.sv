`timescale 1ns / 1ps

module clock_divider#(
    parameter DIVISER = 4
   )(
   input logic clk_in, //input 100 MHZ
   input logic rst,
   output logic pulse_out // output 25 MHZ
    );
    localparam DIVISOR = DIVISER / 2; // we want to toggle pulse_out every DIVISOR/2 clock cycles to get the correct frequency
    logic [$clog2(DIVISOR)-1: 0] counter;
    
    always @(posedge clk_in) begin // on every clock edge so Divisor is 4, we will have 4 clock edges before we toggle pulse_out
        if (rst) begin
            counter <= 0;
            pulse_out <= 0;
        end
        else begin
            if(counter == DIVISOR - 1) begin
                pulse_out <= !pulse_out;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end 
        end
     end
    
endmodule
