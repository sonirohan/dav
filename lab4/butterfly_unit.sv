`timescale 1ns / 1ps  // Define time unit / precision

module butterfly_unit #(
    parameter WIDTH = 32
    )(
        input  logic signed [WIDTH-1:0] a,
        input  logic signed [WIDTH-1:0] b, // complex operands
        input  logic signed [WIDTH-1:0] w, // twiddle factor
        output logic signed [WIDTH-1:0] out1, // top
        output logic signed [WIDTH-1:0] out2  // bottom complex outputs
    );

    // 16-bit split components
    logic signed [WIDTH/2-1:0] real_part_a;
    logic signed [WIDTH/2-1:0] imag_part_a;
    logic signed [WIDTH/2-1:0] real_part_b;
    logic signed [WIDTH/2-1:0] imag_part_b;
    logic signed [WIDTH/2-1:0] real_part_w;
    logic signed [WIDTH/2-1:0] imag_part_w;

    // 32-bit products
    logic signed [WIDTH-1:0] prod1; // w_real * b_real
    logic signed [WIDTH-1:0] prod2; // w_imag * b_imag
    logic signed [WIDTH-1:0] prod3; // w_imag * b_real
    logic signed [WIDTH-1:0] prod4; // w_real * b_imag

    // 32-bit complex multiplication result (before scaling)
    logic signed [WIDTH-1:0] w_times_b_real; 
    logic signed [WIDTH-1:0] w_times_b_imag; 

    always_comb begin

        // Split the inputs into their components
        real_part_a = $signed(a[WIDTH-1:WIDTH/2]);
        imag_part_a = $signed(a[WIDTH/2-1:0]);
        real_part_b = $signed(b[WIDTH-1:WIDTH/2]);
        imag_part_b = $signed(b[WIDTH/2-1:0]);
        real_part_w = $signed(w[WIDTH-1:WIDTH/2]);
        imag_part_w = $signed(w[WIDTH/2-1:0]);

        // Calculate the intermediate products of the FOILing
        prod1 = real_part_w * real_part_b;
        prod2 = imag_part_w * imag_part_b;
        prod3 = imag_part_w * real_part_b;
        prod4 = real_part_w * imag_part_b;

        // Combine products for complex multiplication: (A+Bi)(C+Di) = (AC-BD) + (AD+BC)i
        w_times_b_real = prod1 - prod2;
        w_times_b_imag = prod3 + prod4;

        // Calculate the outputs of the butterfly unit
        // Extract bits [30:15] to achieve the Q15 right-shift and discard the lower bits
        out1 = {
            real_part_a + $signed(w_times_b_real[WIDTH-2:WIDTH/2-1]), 
            imag_part_a + $signed(w_times_b_imag[WIDTH-2:WIDTH/2-1])
        }; 
        
        out2 = {
            real_part_a - $signed(w_times_b_real[WIDTH-2:WIDTH/2-1]), 
            imag_part_a - $signed(w_times_b_imag[WIDTH-2:WIDTH/2-1])
        };
        
    end

endmodule