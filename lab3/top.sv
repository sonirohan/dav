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

    clock_divider clanker_divider (
         .clk_in(clk),
         .rst(rst),
         .pulse_out(vgaclk)
    );
    vga clanker_vga (
        .vgaclk(vgaclk),
        .rst(rst),
        .input_red(3'b111), // max red
        .input_green(3'b000), // no green
        .input_blue(2'b00), // no blue
        .hc_out(), // TODO USE LATER
        .vc_out(), // TODO USE LATER
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue)
    );
endmodule