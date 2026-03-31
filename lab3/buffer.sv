module buffer(
    input logic vgaclk, // 25 MHz clock for VGA timing
    input logic rst,
    input logic [9:0] hc_in,
    input logic [9:0] vc_in,
    input logic [2:0] red_in,
    input logic [2:0] green_in,
    input logic [1:0] blue_in,
    output logic [7:0] buffer_out [0:767]
);
logic buffer_write_switch = 0; // this will switch between writing to buffer_out_1 and buffer_out_2
logic [7:0] buffer_out_1 [0:767];
logic [7:0] buffer_out_2 [0:767];


always_ff @(posedge vgaclk) begin
    if (rst) begin
        buffer_write_switch <= 0;
    end else if (hc_in == 0 && vc_in == 0) begin
        buffer_write_switch <= !buffer_write_switch;
    end
end

// writing to the buffer on every clock cycle, we will write to one buffer while the other is being read by the graphics driver
always_ff @(posedge vgaclk) begin
    if (vc_in < 480 && hc_in < 640) begin // only write to the buffer if we are in the visible area of the screen
        if(buffer_write_switch) begin
            buffer_out_1[(vc_in/20)*32 + hc_in/20] <= {red_in, green_in, blue_in};
        end else begin
            buffer_out_2[(vc_in/20)*32 + hc_in/20] <= {red_in, green_in, blue_in};
        end
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