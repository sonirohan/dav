module fsm(
    input logic [31:0] time_signal_a,
    input logic [31:0] time_signal_b,
    input logic [31:0] time_signal_c,
    input logic [31:0] time_signal_d,

    input logic clk,
    input logic rst,
    input logic start,
    
    output logic [31:0] freq_signal_a,
    output logic [31:0] freq_signal_b,
    output logic [31:0] freq_signal_c,
    output logic [31:0] freq_signal_d,

    output logic completed
);


endmodule