module fft(
    input logic [63:0][31:0] time_signals,

    input logic clk,
    input logic rst,
    input logic start,
    
    // instead of 31:0, we probably use 16-bits because they're gonna be real
    output logic [63:0][31:0] freq_signals,
    output logic completed
);

// COPY-AND-PASTED Twiddle Factors definitions from twiddle_defs.txt
// --- 64-Point FFT Twiddle Factors ---
// Formula: W_n^k = cos(2*pi*k/n) - j*sin(2*pi*k/n)
// Format: Hex (Upper half: Real, Lower half: Imaginary)
// Scaling: Q15 Format (Multiplied by 32767)

localparam logic [WIDTH-1:0] bfu_w_0_64 = 32'h7FFF0000; localparam logic [WIDTH-1:0] bfu_w_1_64 = 32'h7F61F374; localparam logic [WIDTH-1:0] bfu_w_2_64 = 32'h7D89E707; localparam logic [WIDTH-1:0] bfu_w_3_64 = 32'h7A7CDAD8;
localparam logic [WIDTH-1:0] bfu_w_4_64 = 32'h7641CF05; localparam logic [WIDTH-1:0] bfu_w_5_64 = 32'h70E2C3AA; localparam logic [WIDTH-1:0] bfu_w_6_64 = 32'h6A6DB8E4; localparam logic [WIDTH-1:0] bfu_w_7_64 = 32'h62F1AECD;
localparam logic [WIDTH-1:0] bfu_w_8_64 = 32'h5A82A57E; localparam logic [WIDTH-1:0] bfu_w_9_64 = 32'h51339D0F; localparam logic [WIDTH-1:0] bfu_w_10_64 = 32'h471C9593; localparam logic [WIDTH-1:0] bfu_w_11_64 = 32'h3C568F1E;
localparam logic [WIDTH-1:0] bfu_w_12_64 = 32'h30FB89BF; localparam logic [WIDTH-1:0] bfu_w_13_64 = 32'h25288584; localparam logic [WIDTH-1:0] bfu_w_14_64 = 32'h18F98277; localparam logic [WIDTH-1:0] bfu_w_15_64 = 32'h0C8C809F;
localparam logic [WIDTH-1:0] bfu_w_16_64 = 32'h00008001; localparam logic [WIDTH-1:0] bfu_w_17_64 = 32'hF374809F; localparam logic [WIDTH-1:0] bfu_w_18_64 = 32'hE7078277; localparam logic [WIDTH-1:0] bfu_w_19_64 = 32'hDAD88584;
localparam logic [WIDTH-1:0] bfu_w_20_64 = 32'hCF0589BF; localparam logic [WIDTH-1:0] bfu_w_21_64 = 32'hC3AA8F1E; localparam logic [WIDTH-1:0] bfu_w_22_64 = 32'hB8E49593; localparam logic [WIDTH-1:0] bfu_w_23_64 = 32'hAECD9D0F;
localparam logic [WIDTH-1:0] bfu_w_24_64 = 32'hA57EA57E; localparam logic [WIDTH-1:0] bfu_w_25_64 = 32'h9D0FAECD; localparam logic [WIDTH-1:0] bfu_w_26_64 = 32'h9593B8E4; localparam logic [WIDTH-1:0] bfu_w_27_64 = 32'h8F1EC3AA;
localparam logic [WIDTH-1:0] bfu_w_28_64 = 32'h89BFCF05; localparam logic [WIDTH-1:0] bfu_w_29_64 = 32'h8584DAD8; localparam logic [WIDTH-1:0] bfu_w_30_64 = 32'h8277E707; localparam logic [WIDTH-1:0] bfu_w_31_64 = 32'h809FF374;


// now we need 6 stages for the 64-point FFT, and we can reuse the same butterfly units for each stage
typedef enum logic [1:0] {idle, stage_1, stage_2, stage_3, stage_4, stage_5, stage_6, done} state_t;
state_t state;

/* // Better way to do the butterfly wiring:


*/

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


// Butterfly Unit Definitions
butterfly_unit clanker_0( .a(bfu_0_in_a), .b(bfu_0_in_b),
    .w(bfu_0_in_w), .out1(bfu_0_out_a), .out2(bfu_0_out_b) );

butterfly_unit clanker_1( .a(bfu_1_in_a), .b(bfu_1_in_b),
    .w(bfu_1_in_w), .out1(bfu_1_out_a), .out2(bfu_1_out_b) );

butterfly_unit clanker_2( .a(bfu_0_in_a), .b(bfu_0_in_b),
    .w(bfu_0_in_w), .out1(bfu_0_out_a), .out2(bfu_0_out_b) );

butterfly_unit clanker_3( .a(bfu_1_in_a), .b(bfu_1_in_b),
    .w(bfu_1_in_w), .out1(bfu_1_out_a), .out2(bfu_1_out_b) );

butterfly_unit clanker_4( .a(bfu_0_in_a), .b(bfu_0_in_b),
    .w(bfu_0_in_w), .out1(bfu_0_out_a), .out2(bfu_0_out_b) );

butterfly_unit clanker_5( .a(bfu_1_in_a), .b(bfu_1_in_b),
    .w(bfu_1_in_w), .out1(bfu_1_out_a), .out2(bfu_1_out_b) );

butterfly_unit clanker_6( .a(bfu_0_in_a), .b(bfu_0_in_b),
    .w(bfu_0_in_w), .out1(bfu_0_out_a), .out2(bfu_0_out_b) );

butterfly_unit clanker_7( .a(bfu_1_in_a), .b(bfu_1_in_b),
    .w(bfu_1_in_w), .out1(bfu_1_out_a), .out2(bfu_1_out_b) );


butterfly_unit clanker_8( .a(bfu_0_in_a), .b(bfu_0_in_b),
    .w(bfu_0_in_w), .out1(bfu_0_out_a), .out2(bfu_0_out_b) );

butterfly_unit clanker_9( .a(bfu_1_in_a), .b(bfu_1_in_b),
    .w(bfu_1_in_w), .out1(bfu_1_out_a), .out2(bfu_1_out_b) );

butterfly_unit clanker_10( .a(bfu_0_in_a), .b(bfu_0_in_b),
    .w(bfu_0_in_w), .out1(bfu_0_out_a), .out2(bfu_0_out_b) );

butterfly_unit clanker_11( .a(bfu_1_in_a), .b(bfu_1_in_b),
    .w(bfu_1_in_w), .out1(bfu_1_out_a), .out2(bfu_1_out_b) );

butterfly_unit clanker_12( .a(bfu_0_in_a), .b(bfu_0_in_b),
    .w(bfu_0_in_w), .out1(bfu_0_out_a), .out2(bfu_0_out_b) );

butterfly_unit clanker_13( .a(bfu_1_in_a), .b(bfu_1_in_b),
    .w(bfu_1_in_w), .out1(bfu_1_out_a), .out2(bfu_1_out_b) );

butterfly_unit clanker_14( .a(bfu_0_in_a), .b(bfu_0_in_b),
    .w(bfu_0_in_w), .out1(bfu_0_out_a), .out2(bfu_0_out_b) );

butterfly_unit clanker_15( .a(bfu_1_in_a), .b(bfu_1_in_b),
    .w(bfu_1_in_w), .out1(bfu_1_out_a), .out2(bfu_1_out_b) );


butterfly_unit clanker_16( .a(bfu_0_in_a), .b(bfu_0_in_b),
    .w(bfu_0_in_w), .out1(bfu_0_out_a), .out2(bfu_0_out_b) );

butterfly_unit clanker_17( .a(bfu_1_in_a), .b(bfu_1_in_b),
    .w(bfu_1_in_w), .out1(bfu_1_out_a), .out2(bfu_1_out_b) );

butterfly_unit clanker_18( .a(bfu_0_in_a), .b(bfu_0_in_b),
    .w(bfu_0_in_w), .out1(bfu_0_out_a), .out2(bfu_0_out_b) );

butterfly_unit clanker_19( .a(bfu_1_in_a), .b(bfu_1_in_b),
    .w(bfu_1_in_w), .out1(bfu_1_out_a), .out2(bfu_1_out_b) );

butterfly_unit clanker_20( .a(bfu_0_in_a), .b(bfu_0_in_b),
    .w(bfu_0_in_w), .out1(bfu_0_out_a), .out2(bfu_0_out_b) );

butterfly_unit clanker_21( .a(bfu_1_in_a), .b(bfu_1_in_b),
    .w(bfu_1_in_w), .out1(bfu_1_out_a), .out2(bfu_1_out_b) );

butterfly_unit clanker_22( .a(bfu_0_in_a), .b(bfu_0_in_b),
    .w(bfu_0_in_w), .out1(bfu_0_out_a), .out2(bfu_0_out_b) );

butterfly_unit clanker_23( .a(bfu_1_in_a), .b(bfu_1_in_b),
    .w(bfu_1_in_w), .out1(bfu_1_out_a), .out2(bfu_1_out_b) );

butterfly_unit clanker_24( .a(bfu_0_in_a), .b(bfu_0_in_b),
    .w(bfu_0_in_w), .out1(bfu_0_out_a), .out2(bfu_0_out_b) );

butterfly_unit clanker_25( .a(bfu_1_in_a), .b(bfu_1_in_b),
    .w(bfu_1_in_w), .out1(bfu_1_out_a), .out2(bfu_1_out_b) );

butterfly_unit clanker_26( .a(bfu_0_in_a), .b(bfu_0_in_b),
    .w(bfu_0_in_w), .out1(bfu_0_out_a), .out2(bfu_0_out_b) );

butterfly_unit clanker_27( .a(bfu_1_in_a), .b(bfu_1_in_b),
    .w(bfu_1_in_w), .out1(bfu_1_out_a), .out2(bfu_1_out_b) );


butterfly_unit clanker_28( .a(bfu_0_in_a), .b(bfu_0_in_b),
    .w(bfu_0_in_w), .out1(bfu_0_out_a), .out2(bfu_0_out_b) );

butterfly_unit clanker_29( .a(bfu_1_in_a), .b(bfu_1_in_b),
    .w(bfu_1_in_w), .out1(bfu_1_out_a), .out2(bfu_1_out_b) );

butterfly_unit clanker_30( .a(bfu_0_in_a), .b(bfu_0_in_b),
    .w(bfu_0_in_w), .out1(bfu_0_out_a), .out2(bfu_0_out_b) );

butterfly_unit clanker_31( .a(bfu_1_in_a), .b(bfu_1_in_b),
    .w(bfu_1_in_w), .out1(bfu_1_out_a), .out2(bfu_1_out_b) );

// ==========================================


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