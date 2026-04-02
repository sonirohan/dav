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

localparam w_0 = 1;
localparam w_1 = 1;

logic [31:0] mid_0;
logic [31:0] mid_1;
logic [31:0] mid_2;
logic [31:0] mid_3;

// top left
butterfly_unit clanker_0(
    .a(time_signal_a),
    .b(time_signal_c),
    .w(w_0),
    .out1(mid_0),
    .out2(mid_1)
);

// bottom left
butterfly_unit clanker_1(
    .a(time_signal_b),
    .b(time_signal_d),
    .w(w_0),
    .out1(mid_2),
    .out2(mid_3)
);

// top right
butterfly_unit clanker_2(
    .a(mid_0),
    .b(mid_2),
    .w(w_0),
    .out1(freq_signal_a),
    .out2(freq_signal_c)
);

// bottom right
butterfly_unit clanker_3(
    .a(mid_1),
    .b(mid_3),
    .w(w_1),
    .out1(freq_signal_b),
    .out2(freq_signal_d)
);

endmodule