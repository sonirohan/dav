module sampler #(
    parameter samples = 64,
    parameter sample_rate = 16000,
    parameter clk_freq = 100000000 // If this is changed, xadc setup will need to change as well
) (
    input logic clk, // 100 MHz clock for the ADC sampling
    input logic rst,
    input vauxp6, // positive side of the differential pair for the ADC input
    input vauxn6, // negative side of the differential pair for the ADC input
    output logic [11:0] sample_data [0:samples-1], // output array to hold the sampled data
    output logic start
);
    typedef logic [11:0] sample_t; // 12-bit samples from the ADC
    sample_t sample_buffer_1 [0:samples-1]; // first buffer for double buffering
    sample_t sample_buffer_2 [0:samples-1]; // second buffer for double buffering
    logic buffer_select; // flag to indicate which buffer is currently being filled
    logic enable;
    logic ready;
    logic [$clog2(samples)-1:0] sample_index; 
    logic [15:0] adc_data; // 16-bit value from the ADC

    localparam CLK_DIV = clk_freq / sample_rate; // calculate the clock division factor for the desired sample rate
    logic [$clog2(CLK_DIV)-1:0] clk_div_counter; // counter for clock division

    logic convst; 
    logic eoc;

    // Trigger the ADC conversion exactly when your 16 kHz counter hits 0
    assign convst = (clk_div_counter == 0);

    // Automatically tell the DRP to read the data the moment the conversion finishes
    assign enable = eoc; 

    xadc_audio adc_inst (
        .daddr_in(7'h16),       
        .dclk_in(clk),          
        .den_in(enable),        // Now driven by the EOC pulse
        .di_in(16'h0000),       
        .dwe_in(1'b0),          
        .reset_in(rst),        
        .vauxp6(vauxp6),     
        .vauxn6(vauxn6),        
        .busy_out(),            
        .channel_out(),         
        .do_out(adc_data),
        .drdy_out(ready),       
        .eoc_out(eoc),          // pulses when conversion is done, used to trigger DRP read
        .eos_out(),             
        .alarm_out(),           
        .vp_in(1'b0),           
        .vn_in(1'b0),           
        .convst_in(convst)      // Trigger conversion at the start of each sampling period
    );

    always_comb begin
        if (buffer_select) sample_data = sample_buffer_1; // Output the buffer that is not currently being filled
        else sample_data = sample_buffer_2;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < samples; i++) begin
                sample_buffer_1[i] <= 12'b0;
                sample_buffer_2[i] <= 12'b0;
            end
            sample_index <= 0;
            buffer_select <= 0;
            clk_div_counter <= 0;
            start <= 0;
        end else begin
            if (clk_div_counter == CLK_DIV - 1) clk_div_counter <= 0;
            else clk_div_counter <= clk_div_counter + 1;

            // default set start to 0, we will set it to 1 for one cycle when we have a new batch of samples ready
            start <= 0;
            if (ready) begin
                if (buffer_select) begin
                    sample_buffer_2[sample_index] <= adc_data[15:4]; // Store the 12-bit sample
                    sample_index <= sample_index + 1;
                end else begin
                    sample_buffer_1[sample_index] <= adc_data[15:4]; // Store the 12-bit sample
                    sample_index <= sample_index + 1;
                end
                if(sample_index == samples - 1) begin
                    buffer_select <= ~buffer_select; // Toggle buffer selection for double buffering
                    sample_index <= 0; // Reset sample index for the next round of sampling
                    start <= 1; // Signal that a new batch of samples is ready for processing
                end
            end

    end
    end

endmodule

/*
logic flow:
- rst or initialization: buffers are cleared, sample index set to 0, buffer_select set to 0, enable set to 0
- on our processing clock (100 MHz):
    - clock divider counts up to set 16 kHz sample rate.
    - when counter hits 0, pulse `convst` to trigger a perfectly timed hardware ADC conversion.
    - XADC takes the sample and pulses `eoc` (End of Conversion) when finished.
    - `eoc` directly drives `enable` (den_in) to automatically read the DRP register.
    - wait for `ready` signal from DRP.
        - once ready, read data into active buffer, increment sample index.
        - when sample index reaches samples-1, toggle buffer_select to switch buffers and reset sample index to 0.
        - set `start` high for exactly one cycle to alert downstream modules that a new frame is ready.
*/