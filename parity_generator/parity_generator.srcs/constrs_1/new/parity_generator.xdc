######################################################################################### 
# Virtual DIP SW (Remote Lab):
set_property -dict { PACKAGE_PIN H14 IOSTANDARD LVCMOS33 } [get_ports  sw_i[0] ]
set_property -dict { PACKAGE_PIN G16 IOSTANDARD LVCMOS33 } [get_ports  sw_i[1] ]
set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 } [get_ports  sw_i[2] ] 
set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS33 } [get_ports  sw_i[3] ] 
set_property -dict { PACKAGE_PIN G18 IOSTANDARD LVCMOS33 } [get_ports  sw_i[4] ] 
set_property -dict { PACKAGE_PIN F18 IOSTANDARD LVCMOS33 } [get_ports  sw_i[5] ] 
set_property -dict { PACKAGE_PIN E17 IOSTANDARD LVCMOS33 } [get_ports  sw_i[6] ] 
set_property -dict { PACKAGE_PIN D17 IOSTANDARD LVCMOS33 } [get_ports  sw_i[7] ] 
######################################################################################### 
#7-SEG LED: 
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports  an_o[0]] 
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports  an_o[1]] 
set_property -dict { PACKAGE_PIN T9 IOSTANDARD LVCMOS33 } [get_ports  an_o[2]] 
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports  an_o[3]] 
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports  an_o[4]] 
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports  an_o[5]] 
set_property -dict { PACKAGE_PIN K2 IOSTANDARD LVCMOS33 } [get_ports  an_o[6]] 
set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS33 } [get_ports  an_o[7]] 
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports  seg_o[7]] 
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports  seg_o[6]] 
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports  seg_o[5]] 
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports  seg_o[4]] 
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports  seg_o[3]] 
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports  seg_o[2]] 
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports  seg_o[1]] 
set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS33 } [get_ports  seg_o[0]] 
#########################################################################################