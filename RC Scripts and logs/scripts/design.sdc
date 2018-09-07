set sdc_version 1.4

create_clock -period 3.150 -waveform {0 1.575} [get_ports {CLK}]
set_input_delay 0.001 -max -clock "CLK" [get_ports {Xi}]
set_input_delay 0.001 -max -clock "CLK" [get_ports {Yi}]
set_input_delay 0.001 -max -clock "CLK" [get_ports {PREDICT}]
set_attribute lp_insert_clock_gating true
