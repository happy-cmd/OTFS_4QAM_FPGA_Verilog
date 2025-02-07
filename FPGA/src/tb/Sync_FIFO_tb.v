`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/13 14:41:34
// Design Name: 
// Module Name: Sync_FIFO_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module Sync_FIFO_tb();
    parameter PERIOD = 20;
    reg clk;
    reg rst_n;
    reg wr_en;
    reg rd_en;
    wire full;
    wire empty;
    reg [1:0] din;
    wire [1:0] dout;
    initial begin
        clk = 0;
        forever begin
            #(PERIOD / 2) clk = ~clk;
        end
    end
    initial begin
        rst_n = 0;
        #(PERIOD) rst_n = 1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            din <= 2'd0;
        end
        else begin
            din <= din + 1;
        end
    end

    initial begin
        wr_en = 0;
        #(PERIOD *2 + PERIOD / 2)  wr_en = 1;
    end

    initial begin
        rd_en = 0;
        #(PERIOD *4 + PERIOD / 2)  rd_en = 1;
    end

    wire wr_ack,overflow,valid,underflow,wr_rst_busy,rd_rst_busy;
    fifo_generator_0 test_fifo (
      .clk(clk),                  // input wire clk
      .srst(~rst_n),                // input wire srst
      .din(din),                  // input wire [1 : 0] din
      .wr_en(wr_en),              // input wire wr_en
      .rd_en(rd_en),              // input wire rd_en
      .dout(dout),                // output wire [1 : 0] dout
      .full(full),                // output wire full
      .wr_ack(wr_ack),            // output wire wr_ack
      .overflow(overflow),        // output wire overflow
      .empty(empty),              // output wire empty
      .valid(valid),              // output wire valid
      .underflow(underflow),      // output wire underflow
      .wr_rst_busy(wr_rst_busy),  // output wire wr_rst_busy
      .rd_rst_busy(rd_rst_busy)  // output wire rd_rst_busy
    );
endmodule

