module buffer(
    input logic vgaclk, // 25 MHz clock for VGA timing
    input logic rst,
    input logic [9:0] hc,
    input logic [9:0] vc,
    input logic [2:0] red_in,
    input logic [2:0] green_in,
    input logic [1:0] blue_in,
    output logic [7:0] buffer_out [0:767]
);
logic buffer_write_switch = 0; // this will switch between writing to buffer_out_1 and buffer_out_2
logic [7:0] buffer_out_1 [0:767];
logic [7:0] buffer_out_2 [0:767];


always_ff @(posedge vgaclk) begin
    if(hc == 0 && vc == 0) begin
        buffer_write_switch <= !buffer_write_switch;
    end
    end

// writing to the buffer on every clock cycle, we will write to one buffer while the other is being read by the graphics driver
always_ff @(posedge vgaclk) begin
    if(buffer_write_switch) begin
        buffer_out_1[vc*32 + hc] <= {red_in, green_in, blue_in};
    end else begin
        buffer_out_2[vc*32 + hc] <= {red_in, green_in, blue_in};
    end
end

always_comb begin
    if(buffer_write_switch) begin
        buffer_out = buffer_out_2;
    end else begin
        buffer_out = buffer_out_1;
    end
end
endmodule