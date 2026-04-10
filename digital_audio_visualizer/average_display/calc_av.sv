module calc_av #(
    parameter samples = 64,
    parameter sample_rate = 16000,
    parameter clk_freq = 100000000
)
(
    input logic clk, // processing clock
    input logic rst,
    input logic [11:0] freq_data [0:samples-1], // input array of frequency magnitudes from the FFT module
    input logic start, // signal from sampler to indicate new data is ready
    output logic [3:0] an, // output to 7-segment display anodes
    output logic [6:0] seg_nums, // output to 7-segment display
);
localparam binsize = sample_rate / samples; // frequency represented by each FFT bin

typedef enum logic { IDLE, PROCESSING } state_t;

logic [31:0] accumulator; // to hold the sum of freq_data[i] * i * binsize
logic [31:0] total_magnitude; // to hold the sum of freq_data[i]
logic [31:0] expected_value; // the final calculated average frequency to output
logic [$clog2(samples)-1:0] index; // to iterate through the freq_data array

binary_to_ssd convert(.binary_in(expected_value[13:0]), // take the lower 14 bits to convert to 4-digit decimal
                            .display_out(seg_nums));
basys_ssd #(.clk_in(clk_freq)) drive
                    (.clk(clk),
                   .rst(rst), // TODO: CHECK THIS: reset only when rst is clicked, rst will cause it go black
                   .ssd_in(seg_nums),    
                   .an(an),
                   .seg(seg_nums));

state_t current_state;

    always_ff @(posedge clk) begin
        if(rst) begin 
            current_state <= IDLE;
            expected_value <= 0;
            accumulator <= 0;
            total_magnitude <= 0;
            index <= 0;
        end else begin
            if(start) begin
                current_state <= PROCESSING;
                accumulator <= 0;
                total_magnitude <= 0;
                index <= 0;
            end else if (current_state == PROCESSING) begin
                if(index == samples) begin
                    if (total_magnitude != 0) expected_value <= accumulator / total_magnitude; // avoid division by zero
                    else expected_value <= 0;
                    current_state <= IDLE; // go back to idle after processing
                end else begin
                accumulator <= accumulator + freq_data[index] * index * binsize;
                total_magnitude <= total_magnitude + freq_data[index];
                index <= index + 1;
            end
        end
    end
    end

endmodule