`timescale 1ns / 1ps  // Define time unit / precision

module butterfly_tb();

    localparam WIDTH = 32;
    bit clk; // using "bit" instead of "logic" because "logic" initializes to X and "bit" initializes to 0
    logic [3:0] case_number; 
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

// New approach to the testbench
    always #5 clk = ~clk; // 10ns clock period

    // Easier to use a "task" instead of a bunch of cases because this is way cleaner
    task drive_sample(input [WIDTH-1:0] next_a, next_b, next_w);
        @(posedge clk); // waits for the next clock edge
        a <= next_a;
        b <= next_b;
        w <= next_w;
    endtask

    initial begin
        // Initialize
        a = 0; b = 0; w = 0;
        
        // Drive Test Cases
        //      note that each drive_sample call will wait for the next clock edge before applying the inputs, so we don't need to worry about timing here
        drive_sample(32'h00010001, 32'h00020002, 32'h00030003);
        drive_sample(32'h00040004, 32'h00050005, 32'h00060006);
        drive_sample(32'h00070007, 32'h00080008, 32'h00090009);

        // Wait for pipeline to clear, then stop
        repeat(5) @(posedge clk);
        $display("All tests completed.");
        $finish;
    end

    // Use always_ff ONLY for monitoring/logging
    always_ff @(posedge clk) begin
        $display("Time %0t | a=%h b=%h w=%h | out1=%h out2=%h", $time, a, b, w, out1, out2);
        // prints result at every time with aligned inputs and outputs
        // this is also aligned with the drive_samples because it happens at every clk posedge
    end

endmodule