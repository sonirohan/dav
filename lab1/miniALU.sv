//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2025 04:56:20 PM
// Design Name: 
// Module Name: miniALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module miniALU(
input logic [3:0] op1,
input logic [3:0] op2,
input logic operation,
input logic sign,
output logic [19:0] result
    );
always_comb begin
    if(operation == 1'b0)
        if(sign == 1'b0)
           result = op1+op2;
        else
           result = op1-op2;
    else
        if(sign == 1'b0)
           result = op1<<op2;
        else
           result = op1>>op2;

end
endmodule
