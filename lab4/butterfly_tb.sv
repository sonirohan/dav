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
        
// ---------------------------------------------------------
        // High-Magnitude A & B, with Q15 Unit-Circle Twiddle Factors
        // Upper 16-bits = Real, Lower 16-bits = Imaginary
        // ---------------------------------------------------------

        // Testcase 1: W = 1 + 0j (Angle 0)
        // Ideal W: (1.0, 0.0) -> Scaled W: (32767, 0)
        // A = 150 + 200j, B = 100 + 50j
        // Hex breakdown: A(0x0096, 0x00C8), B(0x0064, 0x0032), W(0x7FFF, 0x0000)
        drive_sample(32'h009600C8, 32'h00640032, 32'h7FFF0000);

        // Testcase 2: W = 0.707 - 0.707j (Angle -pi/4)
        // Ideal W: (0.7071, -0.7071) -> Scaled W: (23170, -23170)
        // A = -200 + 150j, B = -100 - 100j
        // Hex breakdown: A(0xFF38, 0x0096), B(0xFF9C, 0xFF9C), W(0x5A82, 0xA57E)
        drive_sample(32'hFF380096, 32'hFF9CFF9C, 32'h5A82A57E);

        // Testcase 3: W = -0.5 + 0.866j (Angle 2pi/3)
        // Ideal W: (-0.5, 0.866) -> Scaled W: (-16384, 28377)
        // A = 300 - 250j, B = 180 + 120j
        // Hex breakdown: A(0x012C, 0xFF06), B(0x00B4, 0x0078), W(0xC000, 0x6ED9)
        drive_sample(32'h012CFF06, 32'h00B40078, 32'hC0006ED9);

        // Testcase 4: W = 0 + 1j (Angle pi/2)
        // Ideal W: (0.0, 1.0) -> Scaled W: (0, 32767)
        // A = 500 + 400j, B = -250 + 350j
        // Hex breakdown: A(0x01F4, 0x0190), B(0xFF06, 0x015E), W(0x0000, 0x7FFF)
        drive_sample(32'h01F40190, 32'hFF06015E, 32'h00007FFF);

        // Testcase 5: W = -1 + 0j (Angle pi)
        // Ideal W: (-1.0, 0.0) -> Scaled W: (-32768, 0)
        // A = -300 - 450j, B = 150 - 200j
        // Hex breakdown: A(0xFED4, 0xFE3E), B(0x0096, 0xFF38), W(0x8000, 0x0000)
        drive_sample(32'hFED4FE3E, 32'h0096FF38, 32'h80000000);

        // Testcase 6: W = 0.5 - 0.866j (Angle -pi/3)
        // Ideal W: (0.5, -0.866) -> Scaled W: (16384, -28377)
        // A = 800 - 100j, B = -400 - 300j
        // Hex breakdown: A(0x0320, 0xFF9C), B(0xFE70, 0xFED4), W(0x4000, 0x9127)
        drive_sample(32'h0320FF9C, 32'hFE70FED4, 32'h40009127);

        // Testcase 7: W = -0.707 + 0.707j (Angle 3pi/4)
        // Ideal W: (-0.7071, 0.7071) -> Scaled W: (-23170, 23170)
        // A = 1000 + 1000j, B = 500 - 500j
        // Hex breakdown: A(0x03E8, 0x03E8), B(0x01F4, 0xFE0C), W(0xA57E, 0x5A82)
        drive_sample(32'h03E803E8, 32'h01F4FE0C, 32'hA57E5A82);

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