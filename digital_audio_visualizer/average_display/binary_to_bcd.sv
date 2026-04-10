`timescale 1ns / 1ps


module binary_to_bcd(
    input logic [13:0] in,
    output logic [3:0] thousands,
    output logic [3:0] hundreds,
    output logic [3:0] tens,
    output logic [3:0] ones
    );
    
    integer i;
    logic [29:0] scratch; // 4* 4 output and 14 input is 30 bits needed, 
    
always_comb begin

scratch = {16'b0 , in}; // msb 16 will be output, the lsb will be the input, concat the two

for(i = 0; i < 14; i = i + 1)begin // loop 14 times, one for each input dig

//  now we check each bcd to see if it is greater than 5, if it is, we add 3
// at the end we shift everything left by 1

if(scratch[29:26] >= 5)
    scratch[29:26] = scratch[29:26] + 3;
    
if(scratch[25:22] >= 5)
    scratch[25:22] = scratch[25:22] + 3;

if(scratch[21:18] >= 5)
    scratch[21:18] = scratch[21:18] + 3;

if(scratch[17:14] >= 5)
    scratch[17:14] = scratch[17:14] + 3;
// now we shift by 1
scratch = scratch << 1;

end // for loop

    thousands = scratch[29:26];
    hundreds = scratch[25:22];
    tens = scratch[21:18];
    ones = scratch[17:14];

end // always comb
    
endmodule
