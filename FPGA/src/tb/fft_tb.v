`timescale 1ns / 1ps

module fft_tb;

  // Testbench signals
  reg Clk;
  reg [7:0] s_axis_config_tdata;
  reg s_axis_config_tvalid;
  wire s_axis_config_tready;
  reg [31:0] s_axis_data_tdata;
  reg s_axis_data_tvalid;
  wire s_axis_data_tready;
  reg s_axis_data_tlast;
  wire [47:0] m_axis_data_tdata;
  wire m_axis_data_tvalid;
  reg m_axis_data_tready;
  wire m_axis_data_tlast;
  wire event_frame_started;
  wire event_tlast_unexpected;
  wire event_tlast_missing;
  wire event_status_channel_halt;
  wire event_data_in_channel_halt;
  wire event_data_out_channel_halt;

  // File handlers
  integer file, output_file_fft, output_file_ifft, i;
  reg signed [15:0] real_part, imag_part;  // 16-bit signed for real and imaginary parts
  reg signed [15:0] signed_QAMDataRe, signed_QAMDataIm;
  reg [5:0] FrameCnt;
  reg [10:0]cnt;
  // State to control the FFT and IFFT operations
  reg [2:0] stage;  // 

//   Instantiate the FFT module
  xfft_0_4QAM xfft_ip_tb (
      .aclk(Clk),  // input wire aclk
      
      .s_axis_config_tdata(s_axis_config_tdata),  // input wire [7 : 0] s_axis_config_tdata
      .s_axis_config_tvalid(s_axis_config_tvalid),  // input wire s_axis_config_tvalid
      .s_axis_config_tready(s_axis_config_tready),  // output wire s_axis_config_tready
      
      .s_axis_data_tdata(s_axis_data_tdata),  // input wire [31 : 0] s_axis_data_tdata
      .s_axis_data_tvalid(s_axis_data_tvalid),  // input wire s_axis_data_tvalid
      .s_axis_data_tready(s_axis_data_tready),  // output wire s_axis_data_tready
      .s_axis_data_tlast(s_axis_data_tlast),  // input wire s_axis_data_tlast
      
      .m_axis_data_tdata(m_axis_data_tdata),  // output wire [47 : 0] m_axis_data_tdata
      .m_axis_data_tvalid(m_axis_data_tvalid),  // output wire m_axis_data_tvalid
      .m_axis_data_tready(m_axis_data_tready),  // input wire m_axis_data_tready
      .m_axis_data_tlast(m_axis_data_tlast),  // output wire m_axis_data_tlast
      
      .event_frame_started(event_frame_started),  // output wire event_frame_started
      .event_tlast_unexpected(event_tlast_unexpected),  // output wire event_tlast_unexpected
      .event_tlast_missing(event_tlast_missing),  // output wire event_tlast_missing
      .event_status_channel_halt(event_status_channel_halt),      // output wire event_status_channel_halt
      .event_data_in_channel_halt(event_data_in_channel_halt),    // output wire event_data_in_channel_halt
      .event_data_out_channel_halt(event_data_out_channel_halt)  // output wire event_data_out_channel_halt
  );

  // Clock generation
  always #5 Clk = ~Clk;  // 100MHz clock
// 定义一个64个元素的数组，每个元素是一个2位宽的字段，存储实部和虚部
  reg [31:0] QAMData [0:63];  // 每个元素存储32位的数据：[signed_QAMDataIm, signed_QAMDataRe]
  reg [6:0] addr;  // 地址计数器
  
  initial begin
    Clk = 0;
    s_axis_config_tdata = 8'b0;  // Default configuration
    s_axis_config_tvalid = 1'b0;
    s_axis_data_tvalid = 1'b0;
    s_axis_data_tlast = 1'b0;
    m_axis_data_tready = 1'b1;  // Assume always ready to receive data
    stage = 0;
    FrameCnt = 0;
    cnt=0;
    
   // Open the FFT output data file
   // 仿真默认目录为 FPGA/OTFS_prj/OTFS_prj.sim/sim_1/behav/xsim'
       file = $fopen("../../../../../sim_result/input_data_xfft_tb.txt", "r");
       if (file == 0) begin
         $display("Error opening data  file.");
         $finish;
       end

     // 读取文件并将数据存储到数组中
      for (i = 0; i < 64; i = i + 1) begin
        if ($fscanf(file, "%d %d\n", real_part, imag_part) != 2) begin
          $display("Error reading file at line %d", i);
          $finish;
        end
        // 将读取的实部和虚部合并成一个16位的数据（假设每个部分为8位，符号扩展即可）
        QAMData[i] = {imag_part, real_part};
//            QAMData[i] = {16'd1024, 16'd0};
      end
      $fclose(file);  
    
    
    // Open the FFT output data file
      output_file_fft = $fopen("../../../../../sim_result/output_data_xfft_tb.txt", "w");
      if (output_file_fft == 0) begin
        $display("Error opening FFT output file.");
        $finish;
      end
      
    // Open the IFFT output data file
    output_file_ifft =$fopen("../../../../../sim_result/output_data_IFFT_xfft_tb.txt", "w");
    if (output_file_ifft == 0) begin
      $display("Error opening IFFT output file.");
      $finish;
    end
    s_axis_data_tlast = 1'b0;
  end

  // Handle output for IFFT, FFT, and IFFT->FFT sequence
  always @(posedge Clk) begin
    if (m_axis_data_tvalid) begin
      if (FrameCnt == 0) begin
        $display("FFT Output: Real = %d, Imag = %d", $signed(m_axis_data_tdata[18:0]),
                 $signed(m_axis_data_tdata[42:24]));
        $fwrite(output_file_fft, "%d %d\n", $signed(m_axis_data_tdata[18:0]),
                $signed(m_axis_data_tdata[42:24]));
      end else if (FrameCnt == 1) begin
        $display("IFFT Output: Real = %d, Imag = %d", $signed(m_axis_data_tdata[18:0]),
                 $signed(m_axis_data_tdata[42:24]));
        $fwrite(output_file_ifft, "%d %d\n", $signed(m_axis_data_tdata[18:0]),
                $signed(m_axis_data_tdata[42:24]));
      end
    end
  end
  //  时序逻辑见 pdf Figure 3-44
  // stage 0  第一个的计算-配置输入 FFT
  // stage 1 配置 第一个计算-数据输入
  // stage 2  第二个的计算-配置输入
  // stage 3 配置 第二个计算-数据输入
  
  
  always @(posedge Clk) begin
    if (s_axis_data_tready) begin
      case (stage)
        0: begin
          stage <= 1;
          // Start with FFT configuration     
          // --- s_axis_config_tdata(0) <= '1'; -- forward
          // --- s_axis_config_tdata(0) <= '0'; -- inverse
          s_axis_config_tdata <= 8'b00000001;  // Forward FFT
          s_axis_config_tvalid <= 1'b1;
          s_axis_data_tvalid <= 1'b0;
          addr<=0;

        end
        1: begin      
          s_axis_config_tvalid <= 1'b0;     
           if (addr < 64) begin
               // 从QAMData数组中读取数据，并设置传输信号
               s_axis_data_tdata  = QAMData[addr];
               s_axis_data_tvalid <= 1'b1;
               s_axis_data_tlast  <= (addr == 63) ? 1'b1 : 1'b0;  // 最后一个数据的时钟周期设置tlast
               addr <= addr + 1;  // 增加地址计数器
             end
           else begin
               stage <= 2;
           end
        end
        2: begin
          cnt<=cnt+1;
          stage <= 3;
          s_axis_config_tdata <= 8'b00000000;  // Inverse FFT
          s_axis_config_tvalid <= 1'b1;
          s_axis_data_tvalid = 1'b0;
          addr<=0;
        end
        3: begin
        s_axis_config_tvalid <= 1'b0;
           if (addr < 64) begin
            // 从QAMData数组中读取数据，并设置传输信号
            s_axis_data_tdata  = QAMData[addr];
            s_axis_data_tvalid <= 1'b1;
            s_axis_data_tlast  <= (addr == 63) ? 1'b1 : 1'b0;  // 最后一个数据的时钟周期设置tlast
            addr <= addr + 1;  // 增加地址计数器
          end
        else begin
            stage <= 4;
            cnt<=cnt+1;
        end
        end
        4: begin
            addr<=0;
        end
        default: begin
          stage <= 0;
        end
      endcase

    end
  end

  // Control the simulation stages and restart FFT with IFFT output

  always @(posedge Clk) begin
    if (m_axis_data_tvalid && m_axis_data_tlast) begin
      FrameCnt <= FrameCnt + 1;
      if (FrameCnt == 0) begin
        // FFT stage complete
        $display("FFT Complete. Starting IFFT stage.");
        $fclose(output_file_fft);
      end else if (FrameCnt == 1) begin
        // IFFT stage complete, end simulation
        $display("IFFT Complete. Ending testbench.");
        $fclose(output_file_ifft);
        $finish;
      end

    end
  end


endmodule
