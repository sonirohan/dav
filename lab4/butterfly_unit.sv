module butterfly_unit #(
    parameter WIDTH = 32
    )(
        input logic signed [WIDTH-1:0] a,
        input logic signed [WIDTH-1:0] b, // complex operands
        input logic signed [WIDTH-1:0] w, // twiddle factor
        output logic signed [WIDTH-1:0] out1,
        output logic signed [WIDTH-1:0] out2 // complex outputs
    );

    // split the inputs into their components
    logic real_part_a = a[WIDTH-1:WIDTH/2];
    logic imag_part_a = a[WIDTH/2-1:0];
    logic real_part_b = b[WIDTH-1:WIDTH/2];
    logic imag_part_b = b[WIDTH/2-1:0];

    always_comb begin
        // implement math for the butterfly module here
    end

endmodule