`timescale 1ns / 1ps


module stopwatch (
    input logic clk,         // System clock (100MHz)
    input logic rst,         // Active high reset
    input logic start_watch, // When high, the watch counts
    output logic [$clog2(10000)-1:0] elapsed_time // Time in ms (needs to hold up to 9999)
);

logic ms_tick;

clock_divider divider( .clk_in(clk),
                       .rst(rst),
                       .pulse_out(ms_tick));

always @(posedge clk) begin
if(rst) begin
    elapsed_time <= 0;
end else begin
if(start_watch && ms_tick) begin
    if(elapsed_time == 9999)
        elapsed_time <= 0;
    else
        elapsed_time <= elapsed_time + 1;
end
end
end

endmodule

