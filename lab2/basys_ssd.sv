`timescale 1ns / 1ps

module basys_ssd(
    input logic clk,
    input logic rst,
    input logic [6:0] ssd_in [3:0],
    output logic [3:0] an,
    output logic [6:0] seg
); 

    logic two_hundred_hz_tick;

    clock_divider #(.DIVISOR(500000)) div (
        .clk_in(clk), 
        .rst(rst), 
        .pulse_out(two_hundred_hz_tick)
    );

    logic [1:0] switch;

    always @(posedge clk) begin
        if(rst) begin
            switch <= 0;
            an <= 4'b1111;     // All OFF
            seg <= 7'b1111111; // All OFF
        end else begin
            // Only run this block when the slow tick happens
            if(two_hundred_hz_tick) begin
                
                // 1. COUNTER LOGIC: Just increment. 
                // 2 bits (0-3) automatically wraps back to 0. No "if" needed.
                switch <= switch + 1;

                // 2. OUTPUT LOGIC: Describe the Mux
                case(switch)
                    2'b00: begin
                        an <= 4'b1110;     // Rightmost digit
                        seg <= ssd_in[0];
                    end
                    2'b01: begin
                        an <= 4'b1101;
                        seg <= ssd_in[1];
                    end
                    2'b10: begin
                        an <= 4'b1011;
                        seg <= ssd_in[2];
                    end
                    2'b11: begin
                        an <= 4'b0111;     // Leftmost digit
                        seg <= ssd_in[3];
                    end
                endcase
            end 
        end
    end 

endmodule