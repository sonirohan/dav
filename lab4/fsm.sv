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

typedef enum logic [1:0] {idle, stage_1, stage_2, done} state_t;
state_t state;

logic [31:0] mid_0 = 32'd0;
logic [31:0] mid_1 = 32'd0;
logic [31:0] mid_2 = 32'd0;
logic [31:0] mid_3 = 32'd0;

logic [31:0] bfu_0_in_a = 32'd0;
logic [31:0] bfu_0_in_b = 32'd0;
logic [31:0] bfu_0_in_w = 32'd0;
logic [31:0] bfu_1_in_a = 32'd0;
logic [31:0] bfu_1_in_b = 32'd0;
logic [31:0] bfu_1_in_w = 32'd0;

logic [31:0] bfu_0_out_a = 32'd0;
logic [31:0] bfu_0_out_b = 32'd0;
logic [31:0] bfu_1_out_a = 32'd0;
logic [31:0] bfu_1_out_b = 32'd0;

// top
butterfly_unit clanker_0(
    .a(bfu_0_in_a),
    .b(bfu_0_in_b),
    .w(bfu_0_in_w),
    .out1(bfu_0_out_a),
    .out2(bfu_0_out_b)
);

// bottom
butterfly_unit clanker_1(
    .a(bfu_1_in_a),
    .b(bfu_1_in_b),
    .w(bfu_1_in_w),
    .out1(bfu_1_out_a),
    .out2(bfu_1_out_b)
);

always_comb begin

    // default values
    bfu_0_in_a = 32'd0; 
    bfu_0_in_b = 32'd0; 
    bfu_0_in_w = 32'd0;
    bfu_1_in_a = 32'd0; 
    bfu_1_in_b = 32'd0; 
    bfu_1_in_w = 32'd0;

    // drive completed to 0 by default and is overriden if in done state
    completed = 1'b0;

    case (state)
        stage_1 : begin
            bfu_0_in_a = time_signal_a;
            bfu_0_in_b = time_signal_c;
            bfu_0_in_w = w_0;      
            bfu_1_in_a = time_signal_b;
            bfu_1_in_b = time_signal_d;
            bfu_1_in_w = w_0;
        end

        stage_2 : begin
            bfu_0_in_a = mid_0;
            bfu_0_in_b = mid_2;
            bfu_0_in_w = w_0;
            bfu_1_in_a = mid_1;
            bfu_1_in_b = mid_3;
            bfu_1_in_w = w_1;
        end

        done : begin
            completed = 1'b1;
        end

    endcase
end

always @(posedge clk) begin
    if(rst) begin
        state <= idle;
    end else begin
        case (state)
            idle : begin
                if(start) begin
                    state <= stage_1;
                end
            end

            stage_1 : begin
                mid_0 <= bfu_0_out_a;
                mid_1 <= bfu_0_out_b;
                mid_2 <= bfu_1_out_a;
                mid_3 <= bfu_1_out_b;
                state <= stage_2;
            end

            stage_2: begin
                freq_signal_a <= bfu_0_out_a;
                freq_signal_c <= bfu_0_out_b;
                freq_signal_b <= bfu_1_out_a;
                freq_signal_d <= bfu_1_out_b;
                state <= done;
            end
        endcase
    end
end


endmodule


/*
Some comments on implementation:
State transitions definetely need to go in a sequential logic block
the butterfly unit is internally combinatoric
if we want to save the output of the first stage of butterfly units, then the output of the butterfly unit
must be in a sequential block. aka the butterfly unit must be in always ff such that the output doesn't change until the next clock
cycle.the butterfly unit itself isn't put in the sequential logic but rather the changing input / output wiring goes in it
so in the sequential block we should have the entire state transition but then what goes in the combinational block
in the combinatational block we should have the result tying and the flag setting

since we are doing it sequentially and there is a propogation delay between beginning and end
of the butterfly unit, we cannot set the input sequentially then immediately save the output

what's the solution: what absolutely has to be sequential the output of the
first stage going into the input of the second stage.

so it would go stage 1 is entered, then the inputs can be combinationally entered and the outputs will be sequentially wired on the next clock cycle?
so it goes idle then stage 1 is entered (when start is high), 
when stage 1 is entered combinationally wire the inputs to the unit
then on the next clock cycle we see that the state is stage 1. we can wire the output of the butterfly unit to our mid logics so it could be used. set stage to stage2.
in our combinational block we should see that stage is 2 then wire the mids into the unit inputs
then on the next clock cycle we see that the state is stage 2. we can then set the outputs of the unit to the fsm outputs and set completed to high 
*/