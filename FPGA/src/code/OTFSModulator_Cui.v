`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/13 11:41:54
// Design Name: 
// Module Name: OTFSModulator_Cui
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

module OTFSModulator_Cui (
    Clk,
    Srst,
    Start,
    QAMDataValid,
    QAMDataRe,
    QAMDataIm,
    OTFSTxDataValid,
    OTFSTxDataRe,
    OTFSTxDataIm,
    QAMData_instruct
);
  input Clk;
  input Srst;

  input Start;
  input QAMDataValid;
  input [11:0] QAMDataRe;
  input [11:0] QAMDataIm;
  input [1:0] QAMData_instruct;

  output reg OTFSTxDataValid;
  output reg [15:0] OTFSTxDataRe;
  output reg [15:0] OTFSTxDataIm;
  


  parameter StateType_IDLE = 0, StateType_FEED_FFT_DATA = 1,StateType_FEED_FFT_DATA_2=2;
  reg [1:0] State;

  parameter  StateType2_IDLE = 0,
                    StateType2_RECORD_IFFT_DATA = 1,
                    StateType2_OUTPUT_OTFS_DATA_0 = 2,
                    StateType2_OUTPUT_OTFS_DATA_1 = 3,
                    StateType2_OUTPUT_OTFS_DATA_2 = 4,
                    StateType2_OUTPUT_OTFS_DATA_3 = 5,
                    StateType2_OUTPUT_OTFS_DATA_4 = 6;
  reg  [ 2:0] RecState;

  reg  wea;
  reg  [11:0] addra=0;
  reg  [31:0] dina;
  reg  [11:0] addrb=0;
  wire [31:0] doutb;

  reg  [ 7:0] s_axis_config_tdata;
  reg         s_axis_config_tvalid;
  wire        s_axis_config_tready;
  reg  [31:0] s_axis_data_tdata;
  reg         s_axis_data_tvalid;
  wire        s_axis_data_tready;
  wire         s_axis_data_tlast;
  wire [47:0] m_axis_data_tdata;
  wire        m_axis_data_tvalid;
  wire        m_axis_data_tready;
  wire        m_axis_data_tlast;
  wire        event_frame_started;
  wire        event_tlast_unexpected;
  wire        event_tlast_missing;
  wire        event_status_channel_halt;
  wire        event_data_in_channel_halt;
  wire        event_data_out_channel_halt;

  reg  [15:0] DataCount;
  
  
  
    // 用于缓存 QAM的数据
  wire fifo_wr_ack,fifo_overflow,fifo_valid,fifo_underflow,fifo_wr_rst_busy,fifo_rd_rst_busy,fifo_empty,fifo_full;
  
  wire fifo_rd_en;
  wire [1:0] fifo_out;
  wire fifo_wr_en;
  wire [1:0] fifo_din;
  
  reg [15:0]cnt_QAM;
  
always @ (posedge Clk)begin
    if(Srst)begin
        cnt_QAM<=0;
    end
    else begin
        if(QAMDataValid)
            cnt_QAM<=cnt_QAM+1;
    end
end
  
  assign fifo_wr_en=QAMDataValid;
  assign fifo_din = QAMData_instruct;
  assign fifo_rd_en= (State == StateType_FEED_FFT_DATA)&& s_axis_data_tready && (~fifo_empty);
  
  reg [31:0] fifo_s_axis_data_tdata;
 always @(*)begin
           case(fifo_out)
              2'b00:begin
               //s_axis_data_tdata <= {signed_QAMDataIm, signed_QAMDataRe};  // 拼接成 32 位
               fifo_s_axis_data_tdata = {4'b0000,12'b010110101000, 4'b1111,12'b101001011000};  // 拼接成 32 位
             end
             2'b01:begin
                fifo_s_axis_data_tdata = {4'b1111,12'b101001011000,4'b1111,12'b101001011000};  // 拼接成 32 位
             end
             2'b10:begin
                fifo_s_axis_data_tdata = {4'b0000,12'b010110101000,4'b0000,12'b010110101000};  // 拼接成 32 位
             end
             2'b11:begin
                fifo_s_axis_data_tdata = {4'b1111,12'b101001011000,4'b0000,12'b010110101000};  // 拼接成 32 位
             end
            endcase  
 end

        

  
    fifo_generator_0 test_fifo (
      .clk(Clk),                  // input wire clk
      .srst(Srst),                // input wire srst // 高电平复位
      .din(fifo_din),                  // input wire [1 : 0] din
      .wr_en(fifo_wr_en),              // input wire wr_en
      .rd_en(fifo_rd_en),              // input wire rd_en
      .dout(fifo_out),                // output wire [1 : 0] dout
      .full(fifo_full),                // output wire full
      .wr_ack(fifo_wr_ack),            // output wire wr_ack
      .overflow(fifo_overflow),        // output wire overflow
      .empty(fifo_empty),              // output wire empty
      .valid(fifo_valid),              // output wire valid
      .underflow(fifo_underflow),      // output wire underflow
      .wr_rst_busy(fifo_wr_rst_busy),  // output wire wr_rst_busy
      .rd_rst_busy(fifo_rd_rst_busy)  // output wire rd_rst_busy
    );
    
  
  blk_mem_gen_0_1 blk_inst (
    .clka(Clk),    // input wire clka
    .wea(wea),      // input wire [0 : 0] wea
    .addra(addra),  // input wire [11 : 0] addra
    .dina(dina),    // input wire [31 : 0] dina
    .clkb(Clk),    // input wire clkb
    .addrb(addrb),  // input wire [11 : 0] addrb
    .doutb(doutb)  // output wire [31 : 0] doutb
  );
  

  
  
assign m_axis_data_tready=1'b1;
  xfft_0_4QAM fft_inst (
    // 时钟与复位
    .aclk(Clk),                                                // input wire aclk
    // 配置
    .s_axis_config_tdata(s_axis_config_tdata),                  // input wire [7 : 0] s_axis_config_tdata
    .s_axis_config_tvalid(s_axis_config_tvalid),                // input wire s_axis_config_tvalid
    .s_axis_config_tready(s_axis_config_tready),                // output wire s_axis_config_tready
    // 输入数据
    .s_axis_data_tdata(fifo_s_axis_data_tdata),                      // input wire [31 : 0] s_axis_data_tdata 
    .s_axis_data_tvalid(fifo_rd_en),                   // input wire s_axis_data_tvalid
    .s_axis_data_tready(s_axis_data_tready),                    // output wire s_axis_data_tready
    .s_axis_data_tlast(s_axis_data_tlast),                      // input wire s_axis_data_tlast
    // 输出数据
    .m_axis_data_tdata(m_axis_data_tdata),                      // output wire [47 : 0] m_axis_data_tdata
    .m_axis_data_tvalid(m_axis_data_tvalid),                    // output wire m_axis_data_tvalid
    .m_axis_data_tready(m_axis_data_tready),                    // input wire m_axis_data_tready
    .m_axis_data_tlast(m_axis_data_tlast),                      // output wire m_axis_data_tlast
    //事务
    .event_frame_started(event_frame_started),                  // output wire event_frame_started
    .event_tlast_unexpected(event_tlast_unexpected),            // output wire event_tlast_unexpected
    .event_tlast_missing(event_tlast_missing),                  // output wire event_tlast_missing
    .event_status_channel_halt(event_status_channel_halt),      // output wire event_status_channel_halt
    .event_data_in_channel_halt(event_data_in_channel_halt),    // output wire event_data_in_channel_halt
    .event_data_out_channel_halt(event_data_out_channel_halt)  // output wire event_data_out_channel_halt
  );

  wire signed [15:0] signed_QAMDataRe;
  wire signed [15:0] signed_QAMDataIm;

  // 符号扩展
  assign signed_QAMDataRe = {{4{QAMDataRe[11]}}, QAMDataRe};  // 将 QAMDataRe 扩展为 16 位
  assign signed_QAMDataIm = {{4{QAMDataIm[11]}}, QAMDataIm};  // 将 QAMDataIm 扩展为 16 位
  
  reg [5:0]QAMDataValid_Delay;
  
 assign s_axis_data_tlast = (DataCount[5:0] == 6'b111111)?1:0;

  always @(posedge Clk) begin
      s_axis_data_tvalid <= 1'b0;
//      s_axis_data_tlast <= 1'b0;
      s_axis_data_tdata <= {32{1'b0}};
      s_axis_config_tdata <= {8{1'b0}};
      s_axis_config_tvalid <= 1'b0;
      QAMDataValid_Delay<=0;
    if (Srst == 1'b1) begin
      State <= StateType_IDLE;
    end else
      case (State)
        StateType_IDLE: begin
          DataCount <= {16{1'b0}};
          if (Start == 1'b1) begin
            State <= StateType_FEED_FFT_DATA;
            s_axis_config_tdata <= 8'b00000000;
            s_axis_config_tvalid <= 1'b1;
            
            QAMDataValid_Delay[0]<=1'b1;
          end
        end
        StateType_FEED_FFT_DATA_2:begin
            QAMDataValid_Delay<={QAMDataValid_Delay[4:0],QAMDataValid};
            if(QAMDataValid_Delay==6'b0)
            State <= StateType_FEED_FFT_DATA;
        end
        

        StateType_FEED_FFT_DATA: begin           
            if(fifo_rd_en)begin
                DataCount <= (DataCount + 1);
            end
             if (DataCount == 4095) State <= StateType_IDLE;
        end
        default: State <= StateType_IDLE;
      endcase
  end


  always @(posedge Clk) begin
        wea <= 1'b0;
        dina <= {32{1'b0}};
        OTFSTxDataValid <= 1'b0;
        OTFSTxDataRe <= {16{1'b0}};
        OTFSTxDataIm <= {16{1'b0}};
    if (Srst == 1'b1) begin
      RecState <= StateType2_IDLE;
      wea <= 1'b0;
      dina <= {32{1'b0}};
    end else begin
      case (RecState)
        StateType2_IDLE: begin

          wea <= 1'b0;
          dina <= {32{1'b0}};
          addra <= {12{1'b1}};
          if (Start == 1'b1) RecState <= StateType2_RECORD_IFFT_DATA;
        end

        StateType2_RECORD_IFFT_DATA: begin
          addrb <= {12{1'b0}};
          if (m_axis_data_tvalid == 1'b1) begin
            wea   <= 1'b1;
            dina  <= {m_axis_data_tdata[42:27], m_axis_data_tdata[18:3]};
            addra <= (addra + 1);
            if (addra == 4094) RecState <= StateType2_OUTPUT_OTFS_DATA_0;
          end
        end

        StateType2_OUTPUT_OTFS_DATA_0: begin
          RecState <= StateType2_OUTPUT_OTFS_DATA_1;
          addrb <= 64;
        end

        StateType2_OUTPUT_OTFS_DATA_1: begin
          RecState <= StateType2_OUTPUT_OTFS_DATA_2;
          addrb <= 128;
        end

        StateType2_OUTPUT_OTFS_DATA_2: begin
          OTFSTxDataValid <= 1'b1;
          OTFSTxDataRe <= doutb[15:0];
          OTFSTxDataIm <= doutb[31:16];
          addrb <= (addrb + 64);
          if (addrb[11:6] == 6'b111111) begin
            addrb[11:6] <= {12{1'b0}};
            addrb[5:0]  <= ((addrb[5:0]) + 1);
            if (addrb[5:0] == 6'b111111) RecState <= StateType2_OUTPUT_OTFS_DATA_3;
          end
        end

        StateType2_OUTPUT_OTFS_DATA_3: begin
          RecState <= StateType2_OUTPUT_OTFS_DATA_4;
          OTFSTxDataValid <= 1'b1;
          OTFSTxDataRe <= doutb[15:0];
          OTFSTxDataIm <= doutb[31:16];
        end

        StateType2_OUTPUT_OTFS_DATA_4: begin
          RecState <= StateType2_IDLE;
          OTFSTxDataValid <= 1'b1;
          OTFSTxDataRe <= doutb[15:0];
          OTFSTxDataIm <= doutb[31:16];
        end

        default: RecState <= StateType2_IDLE;
      endcase
    end
  end

endmodule

