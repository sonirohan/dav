module top (
    input logic clk, // 100 MHz clock from the crystal
    input logic rst, // active-high reset signal from the button
    output logic hsync, // horizontal sync signal to VGA
    output logic vsync, // vertical sync signal to VGA
    output logic [3:0] red, // 4-bit red signal to VGA
    output logic [3:0] green, // 4-bit green signal to VGA
    output logic [3:0] blue // 4-bit blue signal to VGA
   );

    logic vgaclk; // 25 MHz clock for VGA timing
    clock_divider clanker_divider (
         .clk_in(clk),
         .rst(rst),
         .pulse_out(vgaclk)
    );

    logic [9:0] hc; // horizontal counter output from VGA module
    logic [9:0] vc; // vertical counter output from VGA module

    // Produces the correct 8-bit color values for each pixel
    logic [2:0] intermediate_red;
    logic [2:0] intermediate_green;
    logic [1:0] intermediate_blue;
    graphics_driver clanker_graphics_driver (
        .hc_in(hc),
        .vc_in(vc),
        .red(intermediate_red),
        .green(intermediate_green),
        .blue(intermediate_blue)
    );

    // We want the vga to read from a 32x24 buffer but it needs data for each pixel
    // therefore we will divide out hc and vc by 20 to get the pixel in the buffer array (0 to 767)
    logic [9:0] buffer_index;
    logic [7:0] color;
    assign buffer_index = (vc / 20) * 32 + (hc / 20);

    buffer clanker_buffer (
        .vgaclk(vgaclk),
        .rst(rst),
        .hc_in(hc),
        .vc_in(vc),
        .red_in(intermediate_red), // max red
        .green_in(intermediate_green), // no green
        .blue_in(intermediate_blue), // no blue
        .buffer_index(buffer_index),
        .buffer_out(color) // we will connect this to the graphics driver later
    );
        
    vga clanker_vga (
        .vgaclk(vgaclk),
        .rst(rst),
        .input_red(color[7:5]), 
        .input_green(color[4:2]), 
        .input_blue(color[1:0]), 
        .hc_out(hc),
        .vc_out(vc),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue)
    );
    always @(posedge vgaclk) begin
        $display("Red: %b Green: %b Blue: %b", red, green, blue);
    end

endmodule