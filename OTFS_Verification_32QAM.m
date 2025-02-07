%% 说明
% 根据原始工程:https://github.com/drexelwireless/OTFS_Modulation_FPGA，配合Verilog 代码
% 分析  PN序列生成 + 32QAM调制 + OTFS调制 +OTFS解调 + 32QAM解调

%%
clear;
clc;
close all;

%% LSFR 生成器
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
%% 随机序列生成-辅助
% Pol_comm=[1 Pol']
% pnseq1 = comm.PNSequence('Polynomial',Pol_comm, ...
%     'InitialConditions',[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1],...
%     'Mask',16,...
%     'SamplesPerFrame',2^L);
% out_1 = pnseq1();
% isequal(out_1,x)



%% QAM调制
M = 32;
N = 64;
M_OTFS = 64;
L = 4096*log2(M);
x = x(1:L);

% 验证
verilog_x=readmatrix('FPGA/sim_result/RandomBit_Gene_32QAM.txt');

if isequal(verilog_x,x)
    disp('信息比特正确');
end

y = qammod(x, M,'gray', 'InputType', 'bit','UnitAveragePower', true);
% 量化操作
y=fix_round(y,1,10);

fid=fopen('FPGA\sim_result\QAMModDataOutRe_32QAM.txt','r');
[verilog_qam_y_Re,~]=fscanf(fid,'%d');
fclose(fid);
fid=fopen('FPGA\sim_result\QAMModDataOutIm_32QAM.txt','r');
[verilog_qam_y_Im,~]=fscanf(fid,'%d');
fclose(fid);
verilog_qam_y=(verilog_qam_y_Re+1i*verilog_qam_y_Im);
if isequal(verilog_qam_y,y*2^10)
    disp('QAM调制正确');
end
%% 32QAM gray 调制星座示意图 - 辅助分析
% M = 32;
% d = [0:M-1];
% xxx=qammod(d,M,'PlotConstellation',true);

%% OTFS调制
X = reshape(y,N,M_OTFS);

s = OTFS_modulation(N,M_OTFS,X);

% OTFSDataLogFile = ImportOTFSData('OTFSDataLogFile.txt');
OTFSDataLogFile1= readmatrix('FPGA\sim_result\OTFSModResult_32QAM.txt');
OTFS_VHDL = complex(OTFSDataLogFile1(:,1), OTFSDataLogFile1(:,2));

fix_s=fix_floor(s,8,10)*2^10;
abs_max_imag=max(abs(imag(OTFS_VHDL) - imag(fix_s)));
abs_max_real=max(abs(real(OTFS_VHDL) - real(fix_s)));
disp("发端量化误差值");
disp(['最大 实部差值：  ',num2str(abs_max_real)]);
disp(['最大 虚部差值：  ',num2str(abs_max_imag)]);
% figure;
% hold all;
% grid on;
% plot(real(fix_s))
% plot(real(OTFS_VHDL))
% plot(real(fix_s)-real(OTFS_VHDL))
% title('Real Part Of the OTFS Modulation')
% legend('Matlab','VHDL','diff');
%
% figure;
% hold all;
% grid on;
% plot(imag(fix_s))
% plot(imag(OTFS_VHDL))
% plot(imag(fix_s)-imag(OTFS_VHDL))
% title('Imag Part Of the OTFS Modulation')
% legend('Matlab','VHDL','diff');
%
% figure;
% grid on;
% stem(real(fix_s)-real(OTFS_VHDL))
% title('Matlab-VHDL Difference Of the Real Parts of OTFS Modulation')
%
%
% figure;
% grid on;
% stem(imag(OTFS_VHDL) - imag(fix_s))
% title('Matlab-VHDL Difference Of the Imag Parts of OTFS Modulation')
%% OTFS解调  直接比较FPGA端输出结果，并未和matlab数据进行比较
% OTFS Demodulation
%r = s;% matlab中的数据
r =OTFS_VHDL/2^10; % OTFS-FPGA 输出
yr = OTFS_demodulation(N,M_OTFS,r);
OTFSDemodResult = ImportOTFSData('FPGA\sim_result\OTFSDemodResult_32QAM.txt');
OTFS_DEMOD_VHDL = complex(OTFSDemodResult(:,1), OTFSDemodResult(:,2));
fix_yr=yr(:)*2^11;
figure;
hold all;
grid on;
stem(real(fix_yr))
stem(real(OTFS_DEMOD_VHDL))
plot(real(OTFS_DEMOD_VHDL)-real(fix_yr))
title('Real Part Of the OTFS DeModulation')
legend('Matlab','VHDL','diff');

figure;
hold all;
grid on;
plot(imag(fix_yr))
plot(imag(OTFS_DEMOD_VHDL))
plot(imag(OTFS_DEMOD_VHDL)-imag(fix_yr))
title('Imag Part Of the OTFS DeModulation')
legend('Matlab','VHDL','diff');

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
filename = 'FPGA\sim_result\QAMDeModDataOut_32QAM.txt';  % Replace with your actual file name
data = load(filename);  % This reads the data into an array

% Step 2: Convert each number to binary
bit_vector = [];  % Initialize an empty array to store the binary data

for i = 1:length(data)
    % Convert each number to an 8-bit binary string (assuming the numbers are between 0 and 255)
    binary_str = dec2bin(data(i), 5);  % Convert to 8-bit binary
    bit_vector = [bit_vector, binary_str];  % Append the binary string
end

% Step 3: Convert the binary string into a numeric bit vector
bit_vector = bit_vector - '0';  % Convert the binary string into numeric values (0s and 1s)

% Display the resulting bit vector
%disp(bit_vector);

if isequal(bit_vector',x)
    disp('调制解调数据一致')
end


%%
M = 32;
y = qammod((0:M-1), M, 'UnitAveragePower', true, 'PlotConstellation',true);
y = y.';
X = real(y);
Y = imag(y);
X_Int = round(X * 2^11);
Y_Int = round(Y * 2^11);
figure;
scatter(X_Int, Y_Int)