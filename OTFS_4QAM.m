%%
clear;
clc;
close all;

%% LSFR 生成 伪随机序列
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
% %% 随机序列生成-辅助验证
% Pol_comm=[1 Pol']
% pnseq1 = comm.PNSequence('Polynomial',Pol_comm, ...
%     'InitialConditions',[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1],...
%     'Mask',16,...
%     'SamplesPerFrame',2^L);
% out_1 = pnseq1();
% isequal(out_1,x)

M = 4; %4QAM调制
N = 64;
M_OTFS = 64;
L = 4096*log2(M);
x = x(1:L);
% % 验证
verilog_x=readmatrix('FPGA/sim_result/RandomBit_Gene_4QAM.txt');

if isequal(verilog_x,x)
    disp('信息比特正确');
end

%% QAM调制


y = qammod(x, M,'gray', 'InputType', 'bit','UnitAveragePower',true,'PlotConstellation', true);
% 量化操作
y=fix_round(y,0,11);

fid=fopen('FPGA\sim_result\QAMModDataOutRe_4QAM.txt','r');
[verilog_qam_y_Re,~]=fscanf(fid,'%d');
fclose(fid);
fid=fopen('FPGA\sim_result\QAMModDataOutIm_4QAM.txt','r');
[verilog_qam_y_Im,~]=fscanf(fid,'%d');
fclose(fid);
verilog_qam_y=(verilog_qam_y_Re+1i*verilog_qam_y_Im);
if isequal(verilog_qam_y,y*2^11)
    disp('QAM调制正确');
end

%% OTFS调制
X = reshape(y,N,M_OTFS);

s = OTFS_modulation(N,M_OTFS,X);

% OTFSDataLogFile = ImportOTFSData('OTFSDataLogFile.txt');
OTFSDataLogFile1= readmatrix('FPGA\sim_result\OTFSModResult_4QAM.txt');
OTFS_VHDL = complex(OTFSDataLogFile1(:,1), OTFSDataLogFile1(:,2));

fix_s=fix_floor(s,7,11)*2^11;
abs_max_imag=max(abs(imag(OTFS_VHDL) - imag(fix_s)));
abs_max_real=max(abs(real(OTFS_VHDL) - real(fix_s)));
    disp("发端量化误差值");
    disp(['最大 实部差值：  ',num2str(abs_max_real)]);
    disp(['最大 虚部差值：  ',num2str(abs_max_imag)]);
%% OTFS解调
% OTFS Demodulation
%r = s;% matlab中的数据
%  {s,7,8} OTFS_VHDL
r =OTFS_VHDL/2^8; % OTFS-FPGA 输出
% 截位处理---{s,12,6}的数据输入入 FFT ip core
% max(abs(real(r))) = 22.5508    max(abs(imag(r))) = 24.8008

doutB_r=fix_floor(r,5,6);
doutB_recevieMatrix=reshape(doutB_r,64,64);
doutB_r_row_lianghua=reshape(doutB_recevieMatrix.',4096,1)*2^6;

FPGA_doutB_r= readmatrix('FPGA\sim_result\OTFSDemod_xfft_data_in_4QAM.txt');
FPGA_doutB_r_data = complex(FPGA_doutB_r(:,1), FPGA_doutB_r(:,2));

if isequal(FPGA_doutB_r_data,doutB_r_row_lianghua)
    temp=FPGA_doutB_r_data-doutB_r_row_lianghua;
    disp('OTFS解调模块中，送入 xfft核的数据正确');
end

yr = OTFS_demodulation(N,M_OTFS,doutB_r);

fix_yr=yr(:)*2^6*2^3;
OTFSDemodResult = ImportOTFSData('FPGA\sim_result\OTFSDemodResult_4QAM.txt');
OTFS_DEMOD_VHDL = complex(OTFSDemodResult(:,1), OTFSDemodResult(:,2));


abs_max_imag_recv=max(abs(imag(OTFS_DEMOD_VHDL) - imag(fix_yr)));
abs_max_real_recv=max(abs(real(OTFS_DEMOD_VHDL) - real(fix_yr)));

    disp("收端量化误差值");
    disp(['最大 实部差值：  ',num2str(abs_max_real_recv)]);
    disp(['最大 虚部差值：  ',num2str(abs_max_imag_recv)]);
figure;
grid on;
plot(real(fix_yr) - real(OTFS_DEMOD_VHDL))
title('Matlab-VHDL Difference Of the Real Parts of OTFS DeModulation')

figure;
grid on;
plot(imag(fix_yr) - imag(OTFS_DEMOD_VHDL))
title('Matlab-VHDL Difference Of the Imag Parts of OTFS DeModulation')

figure;
hold on;
grid on;
scatter(real(OTFS_DEMOD_VHDL), imag(OTFS_DEMOD_VHDL))
title('Constellation of the OTFS Demodulated Signal')


%%

% Step 1: Read data from the text file
filename = 'FPGA\sim_result\QAMDeModDataOut_4QAM.txt';  % Replace with your actual file name
data = load(filename);  % This reads the data into an array

% Step 2: Convert each number to binary
bit_vector = [];  % Initialize an empty array to store the binary data

for i = 1:length(data)
    % Convert each number to an 8-bit binary string (assuming the numbers are between 0 and 255)
    binary_str = dec2bin(data(i), 2);  % Convert to 8-bit binary
    bit_vector = [bit_vector, binary_str];  % Append the binary string
end

% Step 3: Convert the binary string into a numeric bit vector
bit_vector = bit_vector - '0';  % Convertthe binary string into numeric values (0s and 1s)

% Display the resulting bit vector
%disp(bit_vector);

if isequal(bit_vector',x)
    disp('调制解调数据一致')
end


% %%
% M = 4;
% y = qammod((0:M-1), M, 'UnitAveragePower', true, 'PlotConstellation',true);
% y = y.';
% X = real(y);
% Y = imag(y);
% X_Int = round(X * 2^11);
% Y_Int = round(Y * 2^11);
% figure;
% scatter(X_Int, Y_Int)