`timescale 1ns / 1ps

module lab_2_top(
    input logic clk,
    input logic start_stop,
    input logic rst_button,
    output logic LED,
    output logic [3:0] an,
    output logic [6:0] seg
    );
    
    // only allows start stop to be active for one tick when clicked
    logic start_stop_prev;
    logic start_stop_edge;
    assign start_stop_edge = start_stop && ~start_stop_prev;
    // start stop edge should be 1 when start stop is 1 and start stop prev is 0, it should be 0 ow
    
    logic rst;
    logic watch_active_random;
    logic[13:0] elapsed_time_random;
    logic watch_active_user;
    logic[13:0] elapsed_time_user;
    logic [6:0] seg_nums [3:0];
    logic [7:0] random_number;
    logic generate_num;
    logic [1:0] state;
    assign rst = rst_button || state == 0;

    
    initial begin
    state = 0;
    end
    
    stopwatch random_time_stopwatch(.clk(clk),
                        .rst(rst),
                        .start_watch(watch_active_random),
                        .elapsed_time(elapsed_time_random)); // reset in state 0
    stopwatch user_react_stopwatch(.clk(clk),
                        .rst(rst), // reset whenever we are are in state 0 to keep it 0
                        .start_watch(watch_active_user),
                        .elapsed_time(elapsed_time_user));
                        
    random_number_generator gen(.clk(clk), 
                            .rst(rst_button),
                            .generate_num(generate_num), // reset only when rst is clciked
                            .random_number(random_number)); // random number max value is 255, consider doing x10 on the delay
                        
    binary_to_ssd convert(.binary_in(elapsed_time_user),
                            .display_out(seg_nums));
    
    basys_ssd drive(.clk(clk),
                   .rst(rst_button), // reset only when rst is clicked, rst will cause it go black
                   .ssd_in(seg_nums),    
                   .an(an),
                   .seg(seg));     
   always @(posedge clk) begin
   start_stop_prev <= start_stop;
   if(rst_button) begin
       state <= 0;
       LED <= 0;
   end else begin
       case(state)
       2'b00: begin 
           if(start_stop_edge) begin
               state <= 2'b01;
               generate_num <= 0; // stop generating random numbers
               watch_active_random <= 1; // start counting time for random
           end else begin // end if start stop, start else
               generate_num <= 1;
               watch_active_random <= 0;
               watch_active_user <= 0;
               LED <= 0;
           end // end else
       end // 2'b00 case
       2'b01: begin
            if(elapsed_time_random == random_number * 20) begin
                LED <= 1; // turn on led for reaction
                watch_active_random <= 0; // stop counting random time
                watch_active_user <=1; // start counting user delay
                state <= 2'b10; // switch state
            end // if elapsed time is over
       end // end 2'b01 case
       2'b10: begin
            if(start_stop_edge) begin
                watch_active_user <=0;
                state <= 2'b11;
            end // if start stop
       end // 2'b10 
       2'b11: begin
            LED <= 0;
       end// 2'b11 case
       
       endcase
   end // else for rst
   
   
   end
   
endmodule
