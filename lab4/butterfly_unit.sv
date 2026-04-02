module butterfly_unit #(
    parameter WIDTH = 32
    )(
        input logic signed [WIDTH-1:0] a,
        input logic signed [WIDTH-1:0] b, // complex operands
        input logic signed [WIDTH-1:0] w, // twiddle factor
        output logic signed [WIDTH-1:0] out1, // top
        output logic signed [WIDTH-1:0] out2 // bottom complex outputs
    );

    // split the inputs into their components
    logic real_part_a = a[WIDTH-1:WIDTH/2];
    logic imag_part_a = a[WIDTH/2-1:0];
    logic real_part_b = b[WIDTH-1:WIDTH/2];
    logic imag_part_b = b[WIDTH/2-1:0];
    logic real_part_w = w[WIDTH-1:WIDTH/2];
    logic imag_part_w = w[WIDTH/2-1:0];

    logic prod1 [WIDTH-1:0]; // w_real * b_real
    logic prod2 [WIDTH-1:0]; // w_imag * b_imag
    logic prod3 [WIDTH-1:0]; // w_imag * b_real
    logic prod4 [WIDTH-1:0]; // w_real * b_imag

    logic w_times_b [WIDTH-1:0]; // the result of multiplying w and b, which is a complex number

    always_comb begin
        prod1 = real_part_w * real_part_b;
        prod2 = imag_part_w * imag_part_b;
        prod3 = imag_part_w * real_part_b;
        prod4 = real_part_w * imag_part_b;
        
        w_times_b = {prod1 - prod2, prod3 + prod4}; // combine the real and imaginary parts of the product
        out1 = {real_part_a + w_times_b[WIDTH-1:WIDTH/2], imag_part_a + w_times_b[WIDTH/2-1:0]}; // top output is a + w*b
        out2 = {real_part_a - w_times_b[WIDTH-1:WIDTH/2], imag_part_a - w_times_b[WIDTH/2-1:0]}; // bottom output is a - w*b
    end

endmodule