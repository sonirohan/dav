`timescale 1ns / 1ps

module binary_to_ssd(
    input logic [13:0] binary_in, // up to 9999
    output logic [6:0] display_out [3:0]
    );
     logic [3:0] thousands;
     logic [3:0] hundreds;
     logic [3:0] tens;
     logic [3:0] ones;
     
     binary_to_bcd bcd(.in(binary_in), 
                   .thousands(thousands),
                   .hundreds(hundreds),
                   .tens(tens),
                   .ones(ones));
     seven_segment_digit thous(
                        .digit(thousands),
                        .display_bits(display_out[3]));
     
     seven_segment_digit hund(
                        .digit(hundreds),
                        .display_bits(display_out[2]));
     seven_segment_digit ten(
                        .digit(tens),
                        .display_bits(display_out[1]));
     seven_segment_digit one(
                        .digit(ones),
                        .display_bits(display_out[0]));
     
    
endmodule
