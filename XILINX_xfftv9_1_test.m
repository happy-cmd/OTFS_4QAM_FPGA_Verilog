
%-------------------------------------------------------------------
%
% Example code for FFT v8.0 MEX function
%  针对  xfft_0_4QAM ipcore 计算 FFT/IFFT 对比 量化数据
%-------------------------------------------------------------------
% clear all;clc;close all;
generics.C_NFFT_MAX=6;% 64点IFFT
generics.C_ARCH=2;% Architecture
generics.C_HAS_NFFT=0;% No Run time configurable transform length
generics.C_USE_FLT_PT=0;% Fixed-Point
generics.C_INPUT_WIDTH=12; %Input data width (bits)
generics.C_TWIDDLE_WIDTH=12; % Phase factor width (bits)
generics.C_HAS_SCALING=0;  % Scaling option: unscaled
generics.C_HAS_BFP=0; % Scaling option: Applicable if C_HAS_SCALING=1
generics.C_HAS_ROUNDING=0; % Rounding:0 = truncation


channels = 1;

samples = 2^generics.C_NFFT_MAX;


L = 16;
LFSR = ones(L,1);
Pol = zeros(L,1);
Pol(11) = 1;
Pol(13) = 1;
Pol(14) = 1;
Pol(16) = 1;

x = zeros(2^L, 1);
% backward LSFR
for k = 1:2^L
    temp = mod(LFSR' * Pol, 2);
    LFSR(2:L) = LFSR(1:L-1);
    LFSR(1) = temp;
    x(k) = LFSR(1);
end

% QAM modulation
yxxx = qammod(x, 4, 'gray', 'InputType', 'bit', 'UnitAveragePower', true);

fix_yxxx=fix_round(yxxx(1:4096),0,11);

% % Quantize the data
data_send = fix_round(yxxx(1:64), 0, 11);  % Quantization
% Write the input data to a text file
% Open the file to write data
fileID = fopen('Sim_data/input_data_xfft_tb.txt', 'w');

% Loop through each complex value in data_send
for i = 1:length(data_send)
    % Get the real and imaginary parts of the complex value
    real_part = real(data_send(i));
    imag_part = imag(data_send(i));

    % Quantize both real and imaginary parts with 11 fractional bits
    quantized_real = round(real_part * 2^11);  % 11 bits for fractional part
    quantized_imag = round(imag_part * 2^11);  % 11 bits for fractional part

    % Clamp to signed 12-bit range (1 bit for sign, 11 bits for fraction)
    quantized_real = max(min(quantized_real, 2^11-1), -2^11);  % [-2048, 2047]
    quantized_imag = max(min(quantized_imag, 2^11-1), -2^11);  % [-2048, 2047]

    % Write real and imaginary parts to the file as signed 12-bit integers
    fprintf(fileID, '%d %d\n', quantized_real, quantized_imag);
end

% Close the file
fclose(fileID);

%% xfft Radix-2 操作
% Handle multichannel FFTs if required
% channel 等于 1


% Create input data frame: constant data
% constant_input = 0.5 + 0.5j;
% input_raw(1:samples) = constant_input;
input_raw(1:samples)=data_send(1:samples);

if generics.C_USE_FLT_PT == 0
    % Set up quantizer for correct twos's complement, fixed-point format: one sign bit, C_INPUT_WIDTH-1 fractional bits
    q = quantizer([generics.C_INPUT_WIDTH, generics.C_INPUT_WIDTH-1], 'fixed', 'convergent', 'saturate');
    % Format data for fixed-point input
    input = quantize(q,input_raw);
else
    % Floating point interface - use data directly
    input = input_raw;
end

% Set point size for this transform
nfft = generics.C_NFFT_MAX;

% Set up scaling schedule: scaling_sch[1] is the scaling for the first stage
% Scaling schedule to 1/N:
%    2 in each stage for Radix-4/Pipelined, Streaming I/O
%    1 in each stage for Radix-2/Radix-2 Lite
if generics.C_ARCH == 1 || generics.C_ARCH == 3
    scaling_sch = ones(1,floor(nfft/2)) * 2;
    if mod(nfft,2) == 1
        scaling_sch = [scaling_sch 1];
    end
else
    scaling_sch = ones(1,nfft);
end



if channels > 1
    fprintf('Running the MEX function for channel %d...\n',channel)
else
    fprintf('Running the MEX function...\n')
end

% Run the MEX function
% Set FFT (1)
[output, blkexp, overflow] = xfft_v9_1_bitacc_mex(generics, nfft, input, scaling_sch, 1);
%or IFFT (0)
[output_ifft, blkexp_ifft, overflow_ifft] = xfft_v9_1_bitacc_mex(generics, nfft, input, scaling_sch, 0);

Xfft_outputdata = ImportOTFSData('FPGA\sim_result\output_data_xfft_tb.txt');
Xfft_Result = complex(Xfft_outputdata(:,1), Xfft_outputdata(:,2));
output_lianghua_fft=  reshape(output*2^11,samples,1);

Xfft_outputdata_ifft = ImportOTFSData('FPGA\sim_result\output_data_IFFT_xfft_tb.txt');
Xfft_Result_ifft= complex(Xfft_outputdata_ifft(:,1), Xfft_outputdata_ifft(:,2));
output_lianghua_ifft= reshape(output_ifft*2^11,samples,1);


% output_ifft(1) = -5.6738 + 1.3989i
% Xfft_Result_ifft(1)= -1.8980e+04 + 1.6800e+04i
% matlab_ifft(1) = -0.0887 + 0.0219i


% xfft_model_fft=output;
% xfft_model_ifft=output_ifft;
% FPGA_fft=Xfft_Result/2^11;
% FPGA_ifft=Xfft_Result_ifft/2^11;
% matlab_fft=fft(input);
% matlab_ifft=64*ifft(input);
% 
% 
% % Assuming the data variables are structured as follows:
% % xfft_model_fft, xfft_model_ifft - Xilinx Model FFT and IFFT results
% % FPGA_fft, FPGA_ifft - FPGA FFT and IFFT results scaled by 2^11
% % matlab_fft, matlab_ifft - MATLAB FFT and IFFT results
% 
% % Separate real and imaginary parts
% real_xfft_model_fft = real(xfft_model_fft);
% imag_xfft_model_fft = imag(xfft_model_fft);
% 
% real_xfft_model_ifft = real(xfft_model_ifft);
% imag_xfft_model_ifft = imag(xfft_model_ifft);
% 
% real_fpga_fft = real(FPGA_fft);
% imag_fpga_fft = imag(FPGA_fft);
% 
% real_fpga_ifft = real(FPGA_ifft);
% imag_fpga_ifft = imag(FPGA_ifft);
% 
% real_matlab_fft = real(matlab_fft);
% imag_matlab_fft = imag(matlab_fft);
% 
% real_matlab_ifft = real(matlab_ifft);
% imag_matlab_ifft = imag(matlab_ifft);
% 
% % Plot Real Part Comparison
% figure;
% subplot(2, 1, 1);
% plot(real_xfft_model_fft, '-o', 'DisplayName', 'Xilinx FFT');
% hold on;
% plot(real_fpga_fft, '-x', 'DisplayName', 'FPGA FFT');
% plot(real_matlab_fft, '-s', 'DisplayName', 'MATLAB FFT');
% title('Real Part Comparison of FFT');
% xlabel('Sample Index');
% ylabel('Real Part Value');
% legend;
% grid on;
% 
% subplot(2, 1, 2);
% plot(real_xfft_model_ifft, '-o', 'DisplayName', 'Xilinx IFFT');
% hold on;
% plot(real_fpga_ifft, '-x', 'DisplayName', 'FPGA IFFT');
% plot(real_matlab_ifft, '-s', 'DisplayName', 'MATLAB IFFT');
% title('Real Part Comparison of IFFT');
% xlabel('Sample Index');
% ylabel('Real Part Value');
% legend;
% grid on;
% 
% % Plot Imaginary Part Comparison
% figure;
% subplot(2, 1, 1);
% plot(imag_xfft_model_fft, '-o', 'DisplayName', 'Xilinx FFT');
% hold on;
% plot(imag_fpga_fft, '-x', 'DisplayName', 'FPGA FFT');
% plot(imag_matlab_fft, '-s', 'DisplayName', 'MATLAB FFT');
% title('Imaginary Part Comparison of FFT');
% xlabel('Sample Index');
% ylabel('Imaginary Part Value');
% legend;
% grid on;
% 
% subplot(2, 1, 2);
% plot(imag_xfft_model_ifft, '-o', 'DisplayName', 'Xilinx IFFT');
% hold on;
% plot(imag_fpga_ifft, '-x', 'DisplayName', 'FPGA IFFT');
% plot(imag_matlab_ifft, '-s', 'DisplayName', 'MATLAB IFFT');
% title('Imaginary Part Comparison of IFFT');
% xlabel('Sample Index');
% ylabel('Imaginary Part Value');
% legend;
% grid on;


if isequal(output_lianghua_fft,Xfft_Result)
    disp("FFT结果一致");
end
if isequal(output_lianghua_ifft,Xfft_Result_ifft)
    disp("IFFT结果一致");
end
