`timescale 1ns / 1ps  // Define time unit / precision

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

localparam w_0 = 32'b01111111111111110000000000000000;
localparam w_1 = 32'b00000000000000001000000000000000;

typedef enum logic {idle, stage_1, stage_2, done} state_t;
state_t state;

logic [31:0] mid_0;
logic [31:0] mid_1;
logic [31:0] mid_2;
logic [31:0] mid_3;

logic [31:0] bfu_0_in_a;
logic [31:0] bfu_0_in_b;
logic [31:0] bfu_1_in_a;
logic [31:0] bfu_1_in_b;

logic [31:0] bfu_0_out_a;
logic [31:0] bfu_0_out_b;
logic [31:0] bfu_1_out_a;
logic [31:0] bfu_1_out_b;

// top
butterfly_unit clanker_0(
    .a(bfu_0_in_a),
    .b(bfu_0_in_b),
    .w(w_0),
    .out1(bfu_0_out_a),
    .out2(bfu_0_out_b)
);

// bottom
butterfly_unit clanker_1(
    .a(bfu_1_in_a),
    .b(bfu_1_in_b),
    .w(w_0),
    .out1(bfu_1_out_a),
    .out2(bfu_1_out_b)
);

// TODO FIX THE W INPUTS AND FIGURE OUT STATE MACHINE VALIDITY

always_comb begin
    if(state == stage_1) begin
        bfu_0_in_a = time_signal_a;
        bfu_0_in_b = time_signal_c;
        mid_0 = bfu_0_out_a;
        mid_1 = bfu_0_out_b;
        bfu_1_in_a = time_signal_b;
        bfu_1_in_b = time_signal_d;
        mid_2 = bfu_1_out_a;
        mid_3 = bfu_1_out_b;
    end else if(state == stage_2) begin
        bfu_0_in_a = mid_0;
        bfu_0_in_b = mid_2;
        freq_signal_a = bfu_0_out_a;
        freq_signal_c = bfu_0_out_b;
        bfu_1_in_a = mid_1;
        bfu_1_in_b = mid_3;
        freq_signal_b = bfu_1_out_a;
        freq_signal_d = bfu_1_out_b;
    end
end

always @(posedge clk) begin
    if(rst) begin
        state <= idle;
        completed <= 0;
    end else begin
        if(start && state == idle) state <= stage_1; 
        if(state == stage_1) state <= stage_2;
        if(state == stage_2) state <= done;
    end
    if(state == done)
    completed = 1;

end


endmodule