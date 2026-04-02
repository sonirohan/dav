`timescale 1ns / 1ps  // Define time unit / precision

module butterfly_tb();

    localparam WIDTH = 32;
    bit clk; // using "bit" instead of "logic" because "logic" initializes to X and "bit" initializes to 0
    logic signed [WIDTH-1:0] a, b, w; // inputs to the butterfly unit
    logic signed [WIDTH-1:0] out1, out2; // outputs from the butterfly unit

    // instantiate the module we're testing
    butterfly_unit test_unit(
        .a(a),
        .b(b),
        .w(w),
        .out1(out1),
        .out2(out2)
    );

    always #5 clk = ~clk; // 10ns clock period

    initial begin
        clk = 0;
    end

    always_ff @(posedge clk) begin 
        
        // here, add testcases for the butterfly unit

    end


endmodule