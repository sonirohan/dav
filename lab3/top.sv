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

    clock_divider our_divider (
         .clk_in(clk),
         .pulse_out(vgaclk)
    );
endmodule