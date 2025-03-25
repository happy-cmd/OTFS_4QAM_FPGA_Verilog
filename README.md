# OTFS_4QAM_FPGA_Verilog

## Language/语言

- [English](#english)
- [中文](#中文)

---

### English

#### 01. Acknowledgements

Based on the code sharing of [OTFS_Modulation_FPGA](https://github.com/drexelwireless/OTFS_Modulation_FPGA) and the paper Isik, Murat, et al. ["FPGA Implementation of OTFS Modulation for 6G Communication Systems." *2023 IEEE Future Networks World Forum (FNWF)*. IEEE, 2023](https://ieeexplore.ieee.org/abstract/document/10520425),

Based on the analysis of the source program (VHDL) code, I supplemented the Verilog version of the code, wrote a TCL script, and reproduced the program under Vivado 2018.2. By exchanging data in a certain number of txt files, the functions of matlab code and Verilog simulation results are compared (OTFS-4QAM).

> Thanks to [OTFS_Modulation_FPGA](https://github.com/drexelwireless/OTFS_Modulation_FPGA) for sharing the code, which undoubtedly greatly accelerated my personal learning speed. I also hope that my sharing can help others~😊😊😊

#### 02.Procedure Description

The root directory is the MATLAB program directory, and its subdirectory FPGA is the directory where Verilog files are stored, which should also be the Vivado project directory (**please keep it like this, otherwise the relative path of the data interaction txt between MATLAB and VIVADO may not be satisfied**).

```
├── create_ip_table.m
├── fix_floor.m
├── fix_round.m
├── FPGA
|  ├── main.tcl
|  ├── OTFS_prj
|  ├── sim_result
|  └── src
├── ImportOTFSData.m
├── libgmp.dll
├── libIp_xfft_v9_1_bitacc_cmodel.dll
├── OTFS_4QAM.m
├── OTFS_demodulation.m
├── OTFS_modulation.m
├── OTFS_Verification_32QAM.m
├── pg109-xfft.pdf
├── README.md
├── Sim_data
|  └── input_data_xfft_tb.txt
├── testScript.m
├── xfft_v9_1_bitacc_mex.mexw64
└── XILINX_xfftv9_1_test.m
```

- **In the VivadoTCL console, adjust the current directory to /FPGA and execute the TCL script to create the corresponding project OTFS_prj**

```tcl
source ./main.tcl
```

- **Comparison of results**

	- Matlab program - OTFS_4QAM.m corresponds to the simulation test program - TopModuleTb.v

	- Matlab program - OTFS_Verification_32QAM corresponding simulation test program - TopModuleTb_32.v

	- XILINX_xfftv9_1_test.m corresponds to the simulation test program -fft_tb.v

	PS: I originally wanted to use the matlab MEX program corresponding to the Xilinx FFT ip core (see pg109-xfft.pdf for details) to complete precise fixed-point number processing. 

	However, due to the limitation that the Matlab MEX program only allows numerical inputs less than 1, it was not completed). Here, only the fixed-point number processing verification for FFT/IFFT is implemented.

#### 03. Some thoughts

- After my analysis of the code, I think the code follows the processing mode of Zak-OTFS in FPGA implementation.

- Directly using the FFT-ip core will inevitably result in quantization errors between the MATLAB program and the frequency domain processed data. I originally wanted to use the MEX program to implement a completely accurate quantization version of the MATLAB program to achieve consistency with the Verilog simulation data, but due to the limitations of the MEX program itself and limited personal time, I put it on hold.

> Perhaps a manual implementation of the FFT based on the CORDIC algorithm could essentially solve this problem, but further consideration is needed to determine whether this is worthwhile.
>
> I personally like consistency, but a small quantization error is enough.

- For the initial VHDL code, I used X-HDL as a code conversion tool, and then processed it manually. The main changes in the program were in the FFT core.

---

### 中文

#### 01. 致谢

在[OTFS_Modulation_FPGA](https://github.com/drexelwireless/OTFS_Modulation_FPGA)的代码分享和论文 Isik, Murat, et al. ["FPGA Implementation of OTFS Modulation for 6G Communication Systems." *2023 IEEE Future Networks World Forum (FNWF)*. IEEE, 2023](https://ieeexplore.ieee.org/abstract/document/10520425) 的基础上，

本人在分析了源程序（VHDL)代码的基础上，补充了Verilog版本的代码，撰写了TCL脚本，在Vivado 2018.2 下复现了程序。通过一定数量的txt文件交互数据，比对matlab代码和Verilog仿真结果的功能（OTFS-4QAM)。

> 感谢[OTFS_Modulation_FPGA](https://github.com/drexelwireless/OTFS_Modulation_FPGA)分享的代码，无疑极大地加快了我个人的上手速度，也希望我的分享，可以有助于其他人~

#### 02.程序说明

根目录是MATLAB程序目录，其子目录FPGA是verilog文件存放目录，也应该是Vivado工程目录（请保持如此，否则 MATLAB和VIVADO之间的 数据交互 txt的相对路径可能不满足）。

```
├── create_ip_table.m
├── fix_floor.m
├── fix_round.m
├── FPGA
|  ├── main.tcl
|  ├── OTFS_prj
|  ├── sim_result
|  └── src
├── ImportOTFSData.m
├── libgmp.dll
├── libIp_xfft_v9_1_bitacc_cmodel.dll
├── OTFS_4QAM.m
├── OTFS_demodulation.m
├── OTFS_modulation.m
├── OTFS_Verification_32QAM.m
├── pg109-xfft.pdf
├── README.md
├── Sim_data
|  └── input_data_xfft_tb.txt
├── testScript.m
├── xfft_v9_1_bitacc_mex.mexw64
└── XILINX_xfftv9_1_test.m
```

- **在VivadoTCL控制台中， 调整当前目录到 /FPGA，执行TCL脚本，即可建立对应工程 OTFS_prj**

```tcl
source ./main.tcl
```

- **结果比对**

	- matlab程序-OTFS_4QAM.m  对应 仿真测试程序-TopModuleTb.v

	- matlab程序-OTFS_Verification_32QAM  对应 仿真测试程序-TopModuleTb_32.v

	- XILINX_xfftv9_1_test.m 对应  仿真测试程序-fft_tb.v

		PS：这里我原本是想要使用 Xilinx FFT ip core 对应的matlab MEX程序（具体可见pg109-xfft.pdf）完成精确的定点数处理，然而受限于 Matlab MEX程序仅允许小于1的数值输入，并未完成），这里仅实现了对于FFT/IFFT的定点数处理验证。

#### 03. 一些想法

- 经过我对于代码的分析，我认为在FPGA实现中，代码遵循了Zak-OTFS的处理模式。

- 直接使用FFT-ip核，必然存在和matlab程序间的量化处理误差，同时频域处理的数据并不直观，我原本想利用 MEX程序实现完全准确的 matlab程序量化版本，实现同verilog仿真的数据一致，但限于如上MEX自身程序的限制和个人时间有限，故而搁置。

	> 也许基于CORDIC算法的FFT的手动实现，可以从本质上解决这个问题，但需要进一步考虑有无价值。
	>
	> 我个人喜欢一致性，但是量化误差处于很小的范围，便足够啦~

- 对于最开始的VHDL代码，我使用了 X-HDL 作为代码转换工具进行了处理，然后进行了手动处理，程序中主要的改动在于FFT核。

	```
	##################################################################
	# CREATE IP xfft_0_4QAM
	##################################################################
	
	set xfft xfft_0_4QAM
	create_ip -name xfft -vendor xilinx.com -library ip -version 9.1 -module_name $xfft
	
	set_property -dict { 
	  CONFIG.transform_length {64}
	  CONFIG.target_clock_frequency {100}
	  CONFIG.implementation_options {radix_2_burst_io}
	  CONFIG.input_width {12}
	  CONFIG.phase_factor_width {12}
	  CONFIG.scaling_options {unscaled}
	  CONFIG.output_ordering {natural_order}
	  CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {0}
	  CONFIG.complex_mult_type {use_mults_performance}
	  CONFIG.butterfly_type {use_xtremedsp_slices}
	} [get_ips $xfft]
	
	generate_target {instantiation_template} [get_ips $xfft]
	
	##################################################################
	```
