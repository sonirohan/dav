module fsm_tb ();

    logic [31:0] time_signal_a, time_signal_b, time_signal_c, time_signal_d;
    logic [31:0] freq_signal_a, freq_signal_b, freq_signal_c, freq_signal_d;
    logic clk, rst, start, completed;
    logic [4:0] case_number = 5'd0; // To keep track of which test case we're on
    initial clk = 0;
    always #5 clk = ~clk;

    fsm clanker(
        .time_signal_a(time_signal_a),
        .time_signal_b(time_signal_b),
        .time_signal_c(time_signal_c),
        .time_signal_d(time_signal_d),
        .clk(clk),
        .rst(rst),
        .start(start),
        .freq_signal_a(freq_signal_a),
        .freq_signal_b(freq_signal_b),
        .freq_signal_c(freq_signal_c),
        .freq_signal_d(freq_signal_d),
        .completed(completed)
    );

    task drive_sample(input [31:0] next_a, next_b, next_c, next_d);

        $display("Starting Testcase %0d: Driving new sample", case_number);
        case_number = case_number + 1; // Increment the case number for the next test

        @(posedge clk); // waits for the next clock edge
        start <= 1; // Assert start signal to indicate new input is ready
        time_signal_a <= next_a;
        time_signal_b <= next_b;
        time_signal_c <= next_c;
        time_signal_d <= next_d;

        @(posedge clk); // Wait for the next clock edge to deassert start
        start <= 0; // Deassert start signal after one clock cycle

        @(posedge completed); // Wait for the FSM to signal that it's done processing the input
        $display("Output A: %h", freq_signal_a);
        $display("Output B: %h", freq_signal_b);
        $display("Output C: %h", freq_signal_c);
        $display("Output D: %h", freq_signal_d);

        // Reset for the next test
        rst = 1;
        @(posedge clk);
        rst <= 0;

    endtask

    initial begin
        rst = 1;
        time_signal_a = 0;
        time_signal_b = 0;
        time_signal_c = 0;
        time_signal_d = 0;
        start = 0;

        @(posedge clk);
        rst <= 0;

        // Testcase 1: Simple impulse input
        drive_sample(32'h00000001, 32'h00000000, 32'h00000000, 32'h00000000);

        drive_sample(32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFFF);

        // Testcase 3: Ramp input
        drive_sample(32'h00000000, 32'h00000001, 32'h00000002, 32'h00000003);

        // Testcase 4: Sinusoidal input (scaled to fit in 32 bits)
        drive_sample(32'h00007FFF, 32'h0000B504, 32'h0000D504, 32'h0000E504);

        // Testcase 5: Random input
        drive_sample(32'h12345678, 32'h9ABCDEF0, 32'h0F0F0F0F, 32'hF0F0F0F0);

        $finish;

    end

endmodule
