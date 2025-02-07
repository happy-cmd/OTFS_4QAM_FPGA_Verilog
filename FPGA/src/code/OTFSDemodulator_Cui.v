`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/14 10:49:07
// Design Name: 
// Module Name: OTFSDemodulator_Cui
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


module OTFSDemodulator_Cui (
    Clk,
    Srst,
    Start,
    RecSigDataValid,
    RecSigRe,
    RecSigIm,
    OTFSRxDemodValid,
    OTFSRxDemodRe,
    OTFSRxDemodIm
);
  input Clk;
  input Srst;
  input Start;

  input RecSigDataValid;
  input [15:0] RecSigRe;
  input [15:0] RecSigIm;

  output OTFSRxDemodValid;
  output signed [23:0] OTFSRxDemodRe;
  output signed [23:0] OTFSRxDemodIm;


  parameter [2:0]  StateType_IDLE = 0,
                    StateType_RECORD_SIGNAL = 1,
                    StateType_FEED_FFT_DATA_0 = 2,
                    StateType_FEED_FFT_DATA_1 = 3,
                    StateType_FEED_FFT_DATA_2 = 4,
                    StateType_FEED_FFT_DATA_3 = 5,
                    StateType_FEED_FFT_DATA_4 = 6;
  reg     [ 2:0] State;

  reg     [ 7:0] s_axis_config_tdata;
  reg            s_axis_config_tvalid;
  wire           s_axis_config_tready;
  wire    [31:0] s_axis_data_tdata;
  reg            s_axis_data_tready_delay = 0;
  wire           s_axis_data_tready;
  wire           s_axis_data_tlast;
  wire    [47:0] m_axis_data_tdata;
  wire           m_axis_data_tvalid;
  wire           m_axis_data_tready;
  wire           m_axis_data_tlast;
  wire           event_frame_started;
  wire           event_tlast_unexpected;
  wire           event_tlast_missing;
  wire           event_status_channel_halt;
  wire           event_data_in_channel_halt;
  wire           event_data_out_channel_halt;

  reg            wea;
  reg     [11:0] addra = 0;
  reg     [31:0] dina;
  reg     [11:0] addrb = 0;
  wire    [31:0] doutb;

  integer        FFTDataCount = 0;


  DualRAM_OTFSDemod inst_OTFS_matrix (
      .clka (Clk),    // input wire clka
      .wea  (wea),    // input wire [0 : 0] wea
      .addra(addra),  // input wire [11 : 0] addra
      .dina (dina),   // input wire [31 : 0] dina
      .clkb (Clk),    // input wire clkb
      .addrb(addrb),  // input wire [11 : 0] addrb
      .doutb(doutb)   // output wire [31 : 0] doutb
  );


  assign m_axis_data_tready = 1'b1;
  reg  s_axis_data_tvalid = 0;
  wire FFT_data_in;  // 有效数据输入标志

  xfft_0_4QAM fft_inst_rec (
      .aclk                (Clk),                   // input wire aclk
      .s_axis_config_tdata (s_axis_config_tdata),   // input wire [7 : 0] s_axis_config_tdata
      .s_axis_config_tvalid(s_axis_config_tvalid),  // input wire s_axis_config_tvalid
      .s_axis_config_tready(s_axis_config_tready),  // output wire s_axis_config_tready

      .s_axis_data_tdata (s_axis_data_tdata),   // input wire [31 : 0] s_axis_data_tdata
      .s_axis_data_tvalid(FFT_data_in),         // input wire s_axis_data_tvalid
      .s_axis_data_tready(s_axis_data_tready),  // output wire s_axis_data_tready
      .s_axis_data_tlast (s_axis_data_tlast),   // input wire s_axis_data_tlast

      .m_axis_data_tdata (m_axis_data_tdata),   // output wire [47 : 0] m_axis_data_tdata
      .m_axis_data_tvalid(m_axis_data_tvalid),  // output wire m_axis_data_tvalid
      .m_axis_data_tready(m_axis_data_tready),  // input wire m_axis_data_tready
      .m_axis_data_tlast (m_axis_data_tlast),   // output wire m_axis_data_tlast

      .event_frame_started(event_frame_started),  // output wire event_frame_started
      .event_tlast_unexpected(event_tlast_unexpected),  // output wire event_tlast_unexpected
      .event_tlast_missing(event_tlast_missing),  // output wire event_tlast_missing
      .event_status_channel_halt(event_status_channel_halt),      // output wire event_status_channel_halt
      .event_data_in_channel_halt(event_data_in_channel_halt),    // output wire event_data_in_channel_halt
      .event_data_out_channel_halt(event_data_out_channel_halt)  // output wire event_data_out_channel_halt
  );

  assign OTFSRxDemodValid = m_axis_data_tvalid;
  assign OTFSRxDemodRe = m_axis_data_tdata[23:0];
  assign OTFSRxDemodIm = m_axis_data_tdata[47:24];

  reg [15:0] cnt_OTFSDemod;


  integer FFT_data_out_file;
  initial begin
    // Open the IFFT output data file
    FFT_data_out_file = $fopen("../../../../../sim_result/OTFSDemod_xfft_data_out_4QAM.txt", "w");
    if (FFT_data_out_file == 0) begin
      $display("Error opening IFFT output file.");
      $finish;
    end
  end

  always @(posedge Clk) begin
    if (Srst == 1'b1) begin
      cnt_OTFSDemod <= 0;
    end else begin
      if (OTFSRxDemodValid) begin
        cnt_OTFSDemod <= cnt_OTFSDemod + 1;
        $display("OTFS Demod xfft data out :Num = %d, Real = %d, Imag = %d", $unsigned(
                                                                                 cnt_OTFSDemod),
                 $signed(m_axis_data_tdata[18:0]), $signed(m_axis_data_tdata[42:24]));

        $fwrite(FFT_data_out_file, "%d %d\n", $signed(m_axis_data_tdata[15:0]),
                $signed(m_axis_data_tdata[39:24]));
      end
    end
  end


  wire signed [15:0] signed_doutb_29_18;
  wire signed [15:0] signed_doutb_13_02;



  // 符号扩展
  assign s_axis_data_tlast = (FFTDataCount == 64) ? 1'b1 : 1'b0;
  assign signed_doutb_29_18 = {
    {4{doutb[29]}}, doutb[29:18]
  };  // 将 QAMDataRe 扩展为 16 位  {s,7,8}--  {s,5,6}
  assign signed_doutb_13_02 = {{4{doutb[13]}}, doutb[13:2]};  // 将 QAMDataIm 扩展为 16 位

  //  assign signed_doutb_29_18 = 16'd1024;  // 将 QAMDataRe 扩展为 16 位  {s,7,8}--  {s,5,6}
  //  assign signed_doutb_13_02 = 0;  // 将 QAMDataIm 扩展为 16 位



  wire FFT_in_addr_start, FFT_in_addr_keep;

  // s_axis_data_tready_delay 为 s_axis_data_tready 延后一个时钟周期的信号，且在指定状态机的状态下才开始变化，初始为0，必然能抓到 FFT_in_addr_start
  assign FFT_in_addr_start= (State == StateType_FEED_FFT_DATA_0)? (!s_axis_data_tready_delay) & s_axis_data_tready:1'b0;// RAM读地址延迟一个时钟，当此标志拉高，开始地址变化  addr<=addr+'1'
  assign FFT_in_addr_keep= (State == StateType_FEED_FFT_DATA_0)?(s_axis_data_tready_delay) & (!s_axis_data_tready):1'b0;// 当此标志拉高 标志当前地址-1的所读出的数据已经无效 addr<=addr-'1'
  assign FFT_data_in = s_axis_data_tready_delay & s_axis_data_tready;


  assign s_axis_data_tdata = FFT_data_in ? {signed_doutb_29_18, signed_doutb_13_02} : 0;



  always @(posedge Clk) begin
    s_axis_config_tdata <= {8{1'b0}};
    s_axis_config_tvalid <= 1'b0;
    wea <= 1'b0;
    dina <= {32{1'b0}};
    //      s_axis_data_tvalid<=0; 
    if (Srst == 1'b1) begin
      State <= StateType_IDLE;

    end else begin


      case (State)
        StateType_IDLE: begin
          s_axis_data_tready_delay <= 0;
          State <= StateType_IDLE;
          addra <= 4095;
          if (Start == 1'b1) begin
            State <= StateType_RECORD_SIGNAL;
            s_axis_config_tvalid <= 1'b1;
            s_axis_config_tdata <= 8'b00000001;
          end
        end

        StateType_RECORD_SIGNAL: begin
          State <= StateType_RECORD_SIGNAL;
          addrb <= {12{1'b0}};
          if (RecSigDataValid == 1'b1) begin
            wea   <= 1'b1;
            dina  <= {RecSigIm, RecSigRe};
            addra <= (addra + 1);
            if (addra == 4094) State <= StateType_FEED_FFT_DATA_0;
          end
        end

        StateType_FEED_FFT_DATA_0: begin

          s_axis_data_tready_delay <= s_axis_data_tready;
          if (FFT_in_addr_start) begin
            addrb <= addrb + 64;
            FFTDataCount <= FFTDataCount + 1;
          end else if (FFT_in_addr_keep) begin
            addrb <= addrb - 64;
            FFTDataCount <= FFTDataCount - 1;
          end

          if (FFT_data_in) begin
            //s_axis_data_tdata <= {(resize(signed_xhdl0(doutb[29:18]), 16)), (resize(signed_xhdl0(doutb[13:2]), 16))};
            //                s_axis_data_tvalid<=1'b1; 

            FFTDataCount <= FFTDataCount + 1;
            addrb <= addrb + 64;

            if (FFTDataCount == 64) begin
              FFTDataCount <= 1;
            end
            if (addrb[11:6] == 6'b111111) begin
              addrb[11:6] <= {12{1'b0}};
              addrb[5:0]  <= ((addrb[5:0]) + 1);
              if (addrb[5:0] == 6'b111111) State <= StateType_IDLE;
            end
          end

        end



        default: State <= StateType_IDLE;
      endcase
    end
  end

  integer FFT_data_in_file;
  initial begin
    // Open the IFFT output data file
    FFT_data_in_file = $fopen("../../../../../sim_result/OTFSDemod_xfft_data_in_4QAM.txt", "w");
    if (FFT_data_in_file == 0) begin
      $display("Error opening IFFT output file.");
      $finish;
    end
  end

  always @(posedge Clk) begin
    if (FFT_data_in) begin
      $display("OTFS Demod xfft data in :Num = %d, Real = %d, Imag = %d", $unsigned(FFTDataCount),
               $signed(signed_doutb_13_02), $signed(signed_doutb_29_18));
      $fwrite(FFT_data_in_file, "%d %d\n", $signed(signed_doutb_13_02), $signed(
                                                                            signed_doutb_29_18));
    end
  end
endmodule

