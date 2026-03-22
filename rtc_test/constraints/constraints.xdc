# Buttons
# BTNL
set_property PACKAGE_PIN W19 [get_ports {btn_hr_i}]
	set_property IOSTANDARD LVCMOS33 [get_ports {btn_hr_i}]
# BTNC
set_property PACKAGE_PIN U18 [get_ports {rst_i}]
	set_property IOSTANDARD LVCMOS33 [get_ports {rst_i}]
# BTNR
set_property PACKAGE_PIN T17 [get_ports {btn_min_i}]
	set_property IOSTANDARD LVCMOS33 [get_ports {btn_min_i}]
# BTNU
set_property PACKAGE_PIN T18 [get_ports {btn_test_i}]
	set_property IOSTANDARD LVCMOS33 [get_ports {btn_test_i}]

# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk_i]
	set_property IOSTANDARD LVCMOS33 [get_ports clk_i]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_i]
# 7-segment display
set_property PACKAGE_PIN W7 [get_ports {led7_seg_o[7]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {led7_seg_o[7]}]
set_property PACKAGE_PIN W6 [get_ports {led7_seg_o[6]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {led7_seg_o[6]}]
set_property PACKAGE_PIN U8 [get_ports {led7_seg_o[5]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {led7_seg_o[5]}]
set_property PACKAGE_PIN V8 [get_ports {led7_seg_o[4]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {led7_seg_o[4]}]
set_property PACKAGE_PIN U5 [get_ports {led7_seg_o[3]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {led7_seg_o[3]}]
set_property PACKAGE_PIN V5 [get_ports {led7_seg_o[2]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {led7_seg_o[2]}]
set_property PACKAGE_PIN U7 [get_ports {led7_seg_o[1]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {led7_seg_o[1]}]
set_property PACKAGE_PIN V7 [get_ports {led7_seg_o[0]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {led7_seg_o[0]}]
set_property PACKAGE_PIN U2 [get_ports {led7_an_o[0]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {led7_an_o[0]}]
set_property PACKAGE_PIN U4 [get_ports {led7_an_o[1]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {led7_an_o[1]}]
set_property PACKAGE_PIN V4 [get_ports {led7_an_o[2]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {led7_an_o[2]}]
set_property PACKAGE_PIN W4 [get_ports {led7_an_o[3]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {led7_an_o[3]}]
## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]