# Запуск в ModelSim: в окне Transcript выполнить  do run.do
vlib work
vlog -sv apb_slave.sv apb_master.sv tb_top.sv
vsim -novopt work.tb_top
add wave -radix hex /tb_top/pclk /tb_top/presetn /tb_top/psel /tb_top/penable /tb_top/pwrite
add wave -radix hex /tb_top/paddr /tb_top/pwdata /tb_top/prdata /tb_top/pready /tb_top/pslverr
add wave -radix hex /tb_top/DUT/apb_st /tb_top/DUT/register_with_some_name /tb_top/DUT/reg_date /tb_top/DUT/reg_surname /tb_top/DUT/reg_name
run -all
wave zoom full
