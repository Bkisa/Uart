set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L13P_T2_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk }];

set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports { rst }]; #IO_L4P_T0_35 Sch=btn[0]

set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { uart_tx_o }]; #IO_L5P_T0_34 Sch=ar[0]
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { uart_rx_i }]; #IO_L18P_T2_13 Sch=ar[2]

#set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { tx_done_o }]; #IO_L3N_T0_DQS_34 Sch=ar[3]
#set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { modem_rx_i }]; #IO_L10P_T1_34 Sch=ar[4]