
module sevenSegDigit(
input logic [3:0] digit,
output logic [6:0] displayBits
    );
always_comb begin
    case (digit)
        4'b0000: displayBits = 7'b1000000; // 0
        4'b0001: displayBits = 7'b1111001; // 1
        4'b0010: displayBits = 7'b0100100; // 2
        4'b0011: displayBits = 7'b0110000; // 3
        4'b0100: displayBits = 7'b0011001; // 4
        4'b0101: displayBits = 7'b0010010; // 5
        4'b0110: displayBits = 7'b0000010; // 6
        4'b0111: displayBits = 7'b1111000; // 7
        4'b1000: displayBits = 7'b0000000; // 8
        4'b1001: displayBits = 7'b0010000; // 9
        default: displayBits = 7'b1111111; // blank/error
    endcase
end
endmodule
