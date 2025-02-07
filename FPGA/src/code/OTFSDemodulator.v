
module OTFSDemodulator (
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

  reg    [ 7:0] s_axis_config_tdata;
  reg           s_axis_config_tvalid;
  wire           s_axis_config_tready;
  reg     [31:0] s_axis_data_tdata;
  reg            s_axis_data_tvalid;
  wire           s_axis_data_tready;
  reg            s_axis_data_tlast;
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

  reg      wea;
  reg     [11:0] addra = 0;
  reg     [31:0] dina;
  reg     [11:0] addrb=0;
  wire    [31:0] doutb;

  integer        FFTDataCount;


blk_mem_gen_0_1 bram_inst (
    .clka(Clk),    // input wire clka
    .wea(wea),      // input wire [0 : 0] wea
    .addra(addra),  // input wire [11 : 0] addra
    .dina(dina),    // input wire [31 : 0] dina
    .clkb(Clk),    // input wire clkb
    .addrb(addrb),  // input wire [11 : 0] addrb
    .doutb(doutb)  // output wire [31 : 0] doutb
  );
  
assign m_axis_data_tready=1'b1;

xfft_0 fft_inst_rec (
  .aclk(Clk),                                                // input wire aclk
  .s_axis_config_tdata(s_axis_config_tdata),                  // input wire [7 : 0] s_axis_config_tdata
  .s_axis_config_tvalid(s_axis_config_tvalid),                // input wire s_axis_config_tvalid
  .s_axis_config_tready(s_axis_config_tready),                // output wire s_axis_config_tready
  
  .s_axis_data_tdata(s_axis_data_tdata),                      // input wire [31 : 0] s_axis_data_tdata
  .s_axis_data_tvalid(s_axis_data_tvalid),                    // input wire s_axis_data_tvalid
  .s_axis_data_tready(s_axis_data_tready),                    // output wire s_axis_data_tready
  .s_axis_data_tlast(s_axis_data_tlast),                      // input wire s_axis_data_tlast
  
  .m_axis_data_tdata(m_axis_data_tdata),                      // output wire [47 : 0] m_axis_data_tdata
  .m_axis_data_tvalid(m_axis_data_tvalid),                    // output wire m_axis_data_tvalid
  .m_axis_data_tready(m_axis_data_tready),                    // input wire m_axis_data_tready
  .m_axis_data_tlast(m_axis_data_tlast),                      // output wire m_axis_data_tlast
  
  .event_frame_started(event_frame_started),                  // output wire event_frame_started
  .event_tlast_unexpected(event_tlast_unexpected),            // output wire event_tlast_unexpected
  .event_tlast_missing(event_tlast_missing),                  // output wire event_tlast_missing
  .event_status_channel_halt(event_status_channel_halt),      // output wire event_status_channel_halt
  .event_data_in_channel_halt(event_data_in_channel_halt),    // output wire event_data_in_channel_halt
  .event_data_out_channel_halt(event_data_out_channel_halt)  // output wire event_data_out_channel_halt
);

  assign OTFSRxDemodValid = m_axis_data_tvalid;
  assign OTFSRxDemodRe = m_axis_data_tdata[23:0];
  assign OTFSRxDemodIm = m_axis_data_tdata[47:24];


  wire signed [15:0] signed_doutb_29_18;
  wire signed [15:0] signed_doutb_13_02;

  // 符号扩展
  assign signed_doutb_29_18 = {{4{doutb[29]}}, doutb[29:18]};  // 将 QAMDataRe 扩展为 16 位
  assign signed_doutb_13_02 = {{4{doutb[13]}}, doutb[13:2]};  // 将 QAMDataIm 扩展为 16 位

  always @(posedge Clk) begin
      s_axis_data_tvalid <= 1'b0;
      s_axis_data_tlast <= 1'b0;
      s_axis_data_tdata <= {32{1'b0}};
      s_axis_config_tdata <= {8{1'b0}};
      s_axis_config_tvalid <= 1'b0;
      wea <= 1'b0;
      dina <= {32{1'b0}};
    if (Srst == 1'b1) begin
      State <= StateType_IDLE;
      
    end else begin

      
      case (State)
        StateType_IDLE: begin
          State <= StateType_IDLE;
          addra <= {12{1'b1}};
          if (Start == 1'b1) begin
            State <= StateType_RECORD_SIGNAL;
            s_axis_config_tvalid <= 1'b1;
            s_axis_config_tdata <=  8'b00110001;
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
          State <= StateType_FEED_FFT_DATA_1;
          addrb <= 64;
        end

        StateType_FEED_FFT_DATA_1: begin
          State <= StateType_FEED_FFT_DATA_2;
          addrb <= 128;
          FFTDataCount <= 0;
        end

        StateType_FEED_FFT_DATA_2: begin
          State <= StateType_FEED_FFT_DATA_2;
          s_axis_data_tvalid <= 1'b1;
          //s_axis_data_tdata <= {(resize(signed_xhdl0(doutb[29:18]), 16)), (resize(signed_xhdl0(doutb[13:2]), 16))};
          s_axis_data_tdata <= {signed_doutb_29_18, signed_doutb_13_02};
          FFTDataCount <= FFTDataCount + 1;
          if (FFTDataCount == 63) begin
            FFTDataCount <= 0;
            s_axis_data_tlast <= 1'b1;
          end
          addrb <= (addrb + 64);
          if (addrb[11:6] == 6'b111111) begin
            addrb[11:6] <= {12{1'b0}};
            addrb[5:0]  <= ((addrb[5:0]) + 1);
            if (addrb[5:0] == 6'b111111) State <= StateType_FEED_FFT_DATA_3;
          end
        end

        StateType_FEED_FFT_DATA_3: begin
          State <= StateType_FEED_FFT_DATA_4;
          s_axis_data_tvalid <= 1'b1;
          //s_axis_data_tdata <= {(resize(signed_xhdl0(doutb[29:18]), 16)), (resize(signed_xhdl0(doutb[13:2]), 16))};
          s_axis_data_tdata <= {signed_doutb_29_18, signed_doutb_13_02};
        end

        StateType_FEED_FFT_DATA_4: begin
          State <= StateType_IDLE;
          s_axis_data_tlast <= 1'b1;
          s_axis_data_tvalid <= 1'b1;
          //s_axis_data_tdata <= {(resize(signed_xhdl0(doutb[29:18]), 16)), (resize(signed_xhdl0(doutb[13:2]), 16))};
          s_axis_data_tdata <= {signed_doutb_29_18, signed_doutb_13_02};
        end

        default: State <= StateType_IDLE;
      endcase
    end
  end
endmodule
