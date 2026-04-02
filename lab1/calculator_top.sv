`timescale 1ns / 1ps


module calculator_top(
input logic [3:0] op1, input logic [3:0] op2, input sign, input operation,
input clk, output logic [6:0] segBits, output logic [3:0] trigger
    );

logic [19:0] result;
logic [3:0] numberBits [3:0];
logic [6:0] displayBits [3:0];

miniALU operator (.op1(op1),
                 .op2(op2),
                 .operation(operation),
                 .sign(sign),
                 .result(result));
displayEncoder resultToDec (.result(result), .numberBits(numberBits));
sevenSegDigit decToSeg1 (.digit(numberBits[0]), .displayBits(displayBits[0]));
sevenSegDigit decToSeg2 (.digit(numberBits[1]), .displayBits(displayBits[1]));
sevenSegDigit decToSeg3 (.digit(numberBits[2]), .displayBits(displayBits[2]));
sevenSegDigit decToSeg4 (.digit(numberBits[3]), .displayBits(displayBits[3]));
seg_driver driver (.displayBits(displayBits), .clk(clk), .trigger(trigger), .segBits(segBits));

                              
endmodule
