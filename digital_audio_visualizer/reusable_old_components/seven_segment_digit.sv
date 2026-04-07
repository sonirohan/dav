`timescale 1ns / 1ps


module seven_segment_digit (
    input logic [3:0] digit,
    output logic [6:0] display_bits // Active low
);
always_comb begin
case(digit)
4'b0000: display_bits = 7'b1000000; // 0 (g is OFF)
4'b0001: display_bits = 7'b1111001; // 1 (b,c are ON)
4'b0010: display_bits = 7'b0100100; // 2 
4'b0011: display_bits = 7'b0110000; // 3
4'b0100: display_bits = 7'b0011001; // 4
4'b0101: display_bits = 7'b0010010; // 5
4'b0110: display_bits = 7'b0000010; // 6
4'b0111: display_bits = 7'b1111000; // 7
4'b1000: display_bits = 7'b0000000; // 8 (All ON)
4'b1001: display_bits = 7'b0010000; // 9
default: display_bits = 7'b1111111; // all off
endcase
end
endmodule