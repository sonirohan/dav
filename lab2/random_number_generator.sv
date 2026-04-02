`timescale 1ns / 1ps

module random_number_generator (
    input logic clk,
    input logic rst, // Active high, resets LFSR to a non-zero seed
    input logic generate_num, // When high, generate the next number
    output logic [7:0] random_number
);
logic feedback;
assign feedback = random_number[7] ^ random_number[5] ^ random_number[4] ^ random_number[3];
always @(posedge clk)begin
    if(rst) 
    random_number <= 8'b01001010;
    else begin
        if(generate_num)
        random_number <= {random_number[6:0], feedback};
    end // else rst
end // posedge clk
endmodule