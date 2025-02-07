set prj_set OTFS_prj
#******************************************************************
#设置项目名称和工作目录
set proj_name $prj_set
set work_dir  [pwd]



#  使用样例 可 TCL 中输入 help if
# if {[string equal $prj_set "Prj128Communication"]} {
#       puts "vbl is one" 
#    } else {  
#     puts "vbl is not one"
#    }
# Tracked source files
# if {[string equal [get_filesets -quiet src] ""]} {
#   create_fileset -srcset src
# }
# file mkdir $work_dir/src/design
# file mkdir $work_dir/src/testbench
# file mkdir $work_dir/src/constraints
# file mkdir $work_dir/src/block_design
# # Tracked project-specific IP repository
# if {[string equal [get_filesets -quiet ips] ""]} {
#   create_fileset -srcset ips
# }

#创建工程
#**********************************************************************************************************
create_project -force $proj_name $work_dir/$proj_name -part xczu19eg-ffvc1760-2-i

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}
file mkdir $work_dir/$proj_name/$proj_name.srcs/constrs_1/new
# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
  file mkdir $work_dir/$proj_name/$proj_name.sim/sim_1/testbench
  file mkdir $work_dir/$proj_name/$proj_name.sim/sim_1/behav
  file mkdir $work_dir/$proj_name/$proj_name.sim/sim_1/behav/xsim
}

# Create 'sources_1' fileset (if not found)；file mkdir创建ip、new、bd三个子文件
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1

  # 通用文件
  file mkdir $work_dir/$proj_name/$proj_name.srcs/sources_1/coe

  file mkdir $work_dir/$proj_name/$proj_name.srcs/sources_1/ip
 
}





#************************************************************************************************************
#添加源文件 add_files
  # 通用文件-1:模块文件
add_files -fileset sources_1    -force -quiet [glob -nocomplain $work_dir/src/code/*.v]
add_files -fileset sources_1    -force -quiet [glob -nocomplain $work_dir/src/code/*.vhd]
  # 通用文件-2: 仿真测试文件
add_files -fileset sim_1        -force -quiet [glob -nocomplain $work_dir/src/tb/*.v]
add_files -fileset sim_1        -force -quiet [glob -nocomplain $work_dir/src/tb/*.vhd]
  # 通用文件-3: 约束文件
  # 添加 设计模块代码

  # 添加模块内置 coe文件



####### 添加IP的.xci文件
# 0.系统内置ip

##################################################################
# CHECK VIVADO VERSION
# 项目中运行：write_ip_tcl -force  [get_ips] /OTFS_prj_IP_configs.tcl 导出
##################################################################

set scripts_vivado_version 2018.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
  catch {common::send_msg_id "IPS_TCL-100" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_ip_tcl to create an updated script."}
  return 1
}

##################################################################
# START
##################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source OTFS_prj_IP_configs.tcl
# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./OTFS2_prj/OTFS2_prj.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
  create_project OTFS2_prj OTFS2_prj -part xczu19eg-ffvc1760-2-i
  set_property target_language Verilog [current_project]
  set_property simulator_language Mixed [current_project]
}

##################################################################
# CHECK IPs
##################################################################

set bCheckIPs 1
set bCheckIPsPassed 1
if { $bCheckIPs == 1 } {
  set list_check_ips { xilinx.com:ip:blk_mem_gen:8.4 xilinx.com:ip:fifo_generator:13.2 xilinx.com:ip:xfft:9.1 }
  set list_ips_missing ""
  common::send_msg_id "IPS_TCL-1001" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

  foreach ip_vlnv $list_check_ips {
  set ip_obj [get_ipdefs -all $ip_vlnv]
  if { $ip_obj eq "" } {
    lappend list_ips_missing $ip_vlnv
    }
  }

  if { $list_ips_missing ne "" } {
    catch {common::send_msg_id "IPS_TCL-105" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
    set bCheckIPsPassed 0
  }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "IPS_TCL-102" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 1
}

##################################################################
# CREATE IP DualRAM_OTFSDemod
##################################################################

set blk_mem_gen DualRAM_OTFSDemod
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name $blk_mem_gen

set_property -dict { 
  CONFIG.Memory_Type {Simple_Dual_Port_RAM}
  CONFIG.Assume_Synchronous_Clk {true}
  CONFIG.Write_Width_A {32}
  CONFIG.Write_Depth_A {4096}
  CONFIG.Read_Width_A {32}
  CONFIG.Operating_Mode_A {NO_CHANGE}
  CONFIG.Enable_A {Always_Enabled}
  CONFIG.Write_Width_B {32}
  CONFIG.Read_Width_B {32}
  CONFIG.Operating_Mode_B {READ_FIRST}
  CONFIG.Enable_B {Always_Enabled}
  CONFIG.Register_PortA_Output_of_Memory_Primitives {false}
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false}
  CONFIG.Fill_Remaining_Memory_Locations {true}
  CONFIG.Port_B_Clock {100}
  CONFIG.Port_B_Enable_Rate {100}
} [get_ips $blk_mem_gen]

generate_target {instantiation_template} [get_ips $blk_mem_gen]

##################################################################

##################################################################
# ROM_32QAM_ReIm FILES
##################################################################

proc write_blk_mem_gen_QAM32 { blk_mem_gen_QAM32_filepath } {
  set blk_mem_gen_QAM32 [open $blk_mem_gen_QAM32_filepath  w+]

  puts $blk_mem_gen_QAM32 {memory_initialization_radix=10;}
  puts $blk_mem_gen_QAM32 {memory_initialization_vector= }
  puts $blk_mem_gen_QAM32 {-687,}
  puts $blk_mem_gen_QAM32 {-229,}
  puts $blk_mem_gen_QAM32 {-687,}
  puts $blk_mem_gen_QAM32 {-229,}
  puts $blk_mem_gen_QAM32 {-1145,}
  puts $blk_mem_gen_QAM32 {-1145,}
  puts $blk_mem_gen_QAM32 {-1145,}
  puts $blk_mem_gen_QAM32 {-1145,}
  puts $blk_mem_gen_QAM32 {-229,}
  puts $blk_mem_gen_QAM32 {-229,}
  puts $blk_mem_gen_QAM32 {-229,}
  puts $blk_mem_gen_QAM32 {-229,}
  puts $blk_mem_gen_QAM32 {-687,}
  puts $blk_mem_gen_QAM32 {-687,}
  puts $blk_mem_gen_QAM32 {-687,}
  puts $blk_mem_gen_QAM32 {-687,}
  puts $blk_mem_gen_QAM32 {687, }
  puts $blk_mem_gen_QAM32 {229, }
  puts $blk_mem_gen_QAM32 {687, }
  puts $blk_mem_gen_QAM32 {229, }
  puts $blk_mem_gen_QAM32 {1145,}
  puts $blk_mem_gen_QAM32 {1145,}
  puts $blk_mem_gen_QAM32 {1145,}
  puts $blk_mem_gen_QAM32 {1145,}
  puts $blk_mem_gen_QAM32 {229, }
  puts $blk_mem_gen_QAM32 {229, }
  puts $blk_mem_gen_QAM32 {229, }
  puts $blk_mem_gen_QAM32 {229, }
  puts $blk_mem_gen_QAM32 {687, }
  puts $blk_mem_gen_QAM32 {687, }
  puts $blk_mem_gen_QAM32 {687, }
  puts $blk_mem_gen_QAM32 {687, }
  puts $blk_mem_gen_QAM32 {1145,}
  puts $blk_mem_gen_QAM32 {1145,}
  puts $blk_mem_gen_QAM32 {-1145,}
  puts $blk_mem_gen_QAM32 {-1145,}
  puts $blk_mem_gen_QAM32 {687, }
  puts $blk_mem_gen_QAM32 {229, }
  puts $blk_mem_gen_QAM32 {-687,}
  puts $blk_mem_gen_QAM32 {-229,}
  puts $blk_mem_gen_QAM32 {687, }
  puts $blk_mem_gen_QAM32 {229, }
  puts $blk_mem_gen_QAM32 {-687,}
  puts $blk_mem_gen_QAM32 {-229,}
  puts $blk_mem_gen_QAM32 {687, }
  puts $blk_mem_gen_QAM32 {229, }
  puts $blk_mem_gen_QAM32 {-687,}
  puts $blk_mem_gen_QAM32 {-229,}
  puts $blk_mem_gen_QAM32 {1145,}
  puts $blk_mem_gen_QAM32 {1145,}
  puts $blk_mem_gen_QAM32 {-1145,}
  puts $blk_mem_gen_QAM32 {-1145,}
  puts $blk_mem_gen_QAM32 {687, }
  puts $blk_mem_gen_QAM32 {229, }
  puts $blk_mem_gen_QAM32 {-687,}
  puts $blk_mem_gen_QAM32 {-229,}
  puts $blk_mem_gen_QAM32 {687, }
  puts $blk_mem_gen_QAM32 {229, }
  puts $blk_mem_gen_QAM32 {-687,}
  puts $blk_mem_gen_QAM32 {-229,}
  puts $blk_mem_gen_QAM32 {687, }
  puts $blk_mem_gen_QAM32 {229, }
  puts $blk_mem_gen_QAM32 {-687,}
  puts $blk_mem_gen_QAM32 {-229}

  flush $blk_mem_gen_QAM32
  close $blk_mem_gen_QAM32
}

##################################################################
# CREATE IP ROM_32QAM_ReIm
##################################################################

set blk_mem_gen ROM_32QAM_ReIm
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name $blk_mem_gen

write_blk_mem_gen_QAM32  [file join [get_property IP_DIR [get_ips $blk_mem_gen]] QAM32.coe]
set_property -dict { 
  CONFIG.Memory_Type {Dual_Port_ROM}
  CONFIG.Write_Width_A {12}
  CONFIG.Write_Depth_A {64}
  CONFIG.Read_Width_A {12}
  CONFIG.Enable_A {Always_Enabled}
  CONFIG.Write_Width_B {12}
  CONFIG.Read_Width_B {12}
  CONFIG.Enable_B {Always_Enabled}
  CONFIG.Register_PortA_Output_of_Memory_Primitives {false}
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false}
  CONFIG.Load_Init_File {true}
  CONFIG.Coe_File {QAM32.coe}
  CONFIG.Port_A_Write_Rate {0}
  CONFIG.Port_B_Clock {100}
  CONFIG.Port_B_Enable_Rate {100}
} [get_ips $blk_mem_gen]

generate_target {instantiation_template} [get_ips $blk_mem_gen]

##################################################################

##################################################################
# CREATE IP blk_mem_gen_0
##################################################################

set blk_mem_gen blk_mem_gen_0
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name $blk_mem_gen

set_property -dict { 
  CONFIG.Memory_Type {Simple_Dual_Port_RAM}
  CONFIG.Assume_Synchronous_Clk {true}
  CONFIG.Write_Width_A {32}
  CONFIG.Write_Depth_A {4096}
  CONFIG.Read_Width_A {32}
  CONFIG.Operating_Mode_A {NO_CHANGE}
  CONFIG.Enable_A {Always_Enabled}
  CONFIG.Write_Width_B {32}
  CONFIG.Read_Width_B {32}
  CONFIG.Operating_Mode_B {READ_FIRST}
  CONFIG.Enable_B {Always_Enabled}
  CONFIG.Register_PortA_Output_of_Memory_Primitives {false}
  CONFIG.Register_PortB_Output_of_Memory_Primitives {true}
  CONFIG.Fill_Remaining_Memory_Locations {true}
  CONFIG.Port_B_Clock {100}
  CONFIG.Port_B_Enable_Rate {100}
} [get_ips $blk_mem_gen]

generate_target {instantiation_template} [get_ips $blk_mem_gen]

##################################################################

##################################################################
# CREATE IP blk_mem_gen_0_1
##################################################################

set blk_mem_gen blk_mem_gen_0_1
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name $blk_mem_gen

set_property -dict { 
  CONFIG.Memory_Type {Simple_Dual_Port_RAM}
  CONFIG.Assume_Synchronous_Clk {true}
  CONFIG.Write_Width_A {32}
  CONFIG.Write_Depth_A {4096}
  CONFIG.Read_Width_A {32}
  CONFIG.Operating_Mode_A {NO_CHANGE}
  CONFIG.Enable_A {Always_Enabled}
  CONFIG.Write_Width_B {32}
  CONFIG.Read_Width_B {32}
  CONFIG.Operating_Mode_B {READ_FIRST}
  CONFIG.Enable_B {Always_Enabled}
  CONFIG.Register_PortA_Output_of_Memory_Primitives {false}
  CONFIG.Register_PortB_Output_of_Memory_Primitives {true}
  CONFIG.Fill_Remaining_Memory_Locations {true}
  CONFIG.Port_B_Clock {100}
  CONFIG.Port_B_Enable_Rate {100}
} [get_ips $blk_mem_gen]

generate_target {instantiation_template} [get_ips $blk_mem_gen]

##################################################################

##################################################################
# CREATE IP fifo_generator_0
##################################################################

set fifo_generator fifo_generator_0
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name $fifo_generator

set_property -dict { 
  CONFIG.Performance_Options {First_Word_Fall_Through}
  CONFIG.Input_Data_Width {2}
  CONFIG.Input_Depth {4096}
  CONFIG.Output_Data_Width {2}
  CONFIG.Output_Depth {4096}
  CONFIG.Use_Embedded_Registers {false}
  CONFIG.Valid_Flag {true}
  CONFIG.Underflow_Flag {true}
  CONFIG.Write_Acknowledge_Flag {true}
  CONFIG.Overflow_Flag {true}
  CONFIG.Data_Count_Width {12}
  CONFIG.Write_Data_Count_Width {12}
  CONFIG.Read_Data_Count_Width {12}
  CONFIG.Full_Threshold_Assert_Value {4095}
  CONFIG.Full_Threshold_Negate_Value {4094}
  CONFIG.Empty_Threshold_Assert_Value {4}
  CONFIG.Empty_Threshold_Negate_Value {5}
} [get_ips $fifo_generator]

generate_target {instantiation_template} [get_ips $fifo_generator]

##################################################################

##################################################################
# CREATE IP xfft_0
##################################################################

set xfft xfft_0
create_ip -name xfft -vendor xilinx.com -library ip -version 9.1 -module_name $xfft

set_property -dict { 
  CONFIG.transform_length {64}
  CONFIG.target_clock_frequency {100}
  CONFIG.implementation_options {automatically_select}
  CONFIG.target_data_throughput {100}
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

# 仿真的相对路径 *******************************************************************************************
# 参考链接：https://blog.csdn.net/weixin_45075177/article/details/126739144
#add_files -fileset sources_1  -copy_to $work_dir/$proj_name/$proj_name.sim/sim_1/behav/xsim -force -quiet [glob -nocomplain $work_dir/sim_data_compare_matlab/source_data/*.txt]

#  添加 coe 文件


#******************************************************************************************
#生成Block Design
#source $work_dir/vivado_project/$proj_name.srcs/sources_1/bd/my_bd/my_bd.tcl
#*************************************************************************************************************
# # 综合
# launch_runs synth_1 -jobs 5
# wait_on_run synth_1
# # 设置顶层文件属性
# #set_property top_auto_detect true [current_project]
# set_property top_file "/$work_dir/$proj_name/$proj_name.srcs/sources_1/new/led.v" [current_fileset]
# #运行综合、实现和生成比特流
# #synth_design -to_current_top
# #指定综合顶层模块为“led”
# synth_design -top led
# #执行逻辑综合优化，主要是优化逻辑电路的面积、时钟频率、功耗等指标
# opt_design
# #执行布局，将逻辑元素映射到物理位置，并考虑时序约束
# place_design
# #执行布线，将物理电路中的逻辑元素通过信号线连接在一起
# route_design
# #将比特流写入到指定的文件中，即生成.bit文件。-force参数用于强制覆盖已有的文件
# write_bitstream -force $work_dir/$proj_name.bit
# #生成用于调试的信号探针，将信号探针写入到指定的文件中，即生成.ltx文件
# write_debug_probes -file $work_dir/$proj_name.ltx