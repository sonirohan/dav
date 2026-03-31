module top (
    input logic clk, // 100 MHz clock from the crystal
    input logic rst, // active-high reset signal from the button
    output logic hsync, // horizontal sync signal to VGA
    output logic vsync, // vertical sync signal to VGA
    output logic [3:0] red, // 4-bit red signal to VGA
    output logic [3:0] green, // 4-bit green signal to VGA
    output logic [3:0] blue // 4-bi t blue signal to VGA
   );

   logic vgaclk; // 25 MHz clock for VGA timing
   logic [9:0] hc_out; // horizontal counter output from VGA module
   logic [9:0] vc_out; // vertical counter output from VGA module

    clock_divider clanker_divider (
         .clk_in(clk),
         .rst(rst),
         .pulse_out(vgaclk)
    );

    // TODO WE Want the vga to read from a 32x24 buffer but it needs data for each pixel
    // therefore we will divide out hc and vc by 20 to get the pixel in the buffer
    vga clanker_vga (
        .vgaclk(vgaclk),
        .rst(rst),
        .input_red(3'b111), // max red
        .input_green(3'b000), // no green
        .input_blue(2'b00), // no blue
        .hc_out(hc_out),
        .vc_out(vc_out),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue)
    );

    graphics_driver clanker_graphics_driver (
        .hc_out(hc_out), 
        .vc_out(vc_out), 
        .clk(vgaclk),
        .rst(rst),
        .red(red),
        .green(green),
        .blue(blue)
    );

    buffer clanker_buffer (
        .vgaclk(vgaclk),
        .rst(rst),
        .hc(hc_out),
        .vc(vc_out),
        .red_in(3'b111), // max red
        .green_in(3'b000), // no green
        .blue_in(2'b00) // no blue
    );

endmodule