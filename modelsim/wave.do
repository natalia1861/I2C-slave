onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_top/dut/MASTER/nRst
add wave -noupdate /test_top/dut/MASTER/clk
add wave -noupdate -group MASTER /test_top/dut/MASTER/MSB_1st
add wave -noupdate -group MASTER /test_top/dut/MASTER/mode_3_4_h
add wave -noupdate -group MASTER /test_top/dut/MASTER/str_sgl_ins
add wave -noupdate -group MASTER /test_top/dut/MASTER/start
add wave -noupdate -group MASTER /test_top/dut/MASTER/no_bytes
add wave -noupdate -group MASTER /test_top/dut/MASTER/dato_in
add wave -noupdate -group MASTER /test_top/dut/MASTER/dato_rd
add wave -noupdate -group MASTER /test_top/dut/MASTER/ena_rd
add wave -noupdate -group MASTER /test_top/dut/MASTER/rdy
add wave -noupdate -group MASTER /test_top/dut/MASTER/nCS
add wave -noupdate -group MASTER /test_top/dut/MASTER/SPC
add wave -noupdate -group MASTER /test_top/dut/MASTER/SDI
add wave -noupdate -group MASTER /test_top/dut/MASTER/SDIO
add wave -noupdate -group MASTER /test_top/dut/MASTER/cnt_SPC
add wave -noupdate -group MASTER /test_top/dut/MASTER/fdc_cnt_SPC
add wave -noupdate -group MASTER /test_top/dut/MASTER/SPC_posedge
add wave -noupdate -group MASTER /test_top/dut/MASTER/SPC_negedge
add wave -noupdate -group MASTER /test_top/dut/MASTER/cnt_bits_SPC
add wave -noupdate -group MASTER /test_top/dut/MASTER/SDI_syn
add wave -noupdate -group MASTER /test_top/dut/MASTER/SDI_meta
add wave -noupdate -group MASTER /test_top/dut/MASTER/SDIO_syn
add wave -noupdate -group MASTER /test_top/dut/MASTER/SDIO_meta
add wave -noupdate -group MASTER /test_top/dut/MASTER/reg_SPI
add wave -noupdate -group MASTER /test_top/dut/MASTER/nWR_RD
add wave -noupdate -group MASTER /test_top/dut/MASTER/n_ctrl_SDIO
add wave -noupdate -group MASTER /test_top/dut/MASTER/n_ctrl_SDIO_dly1
add wave -noupdate -group MASTER /test_top/dut/MASTER/n_ctrl_SDIO_dly2
add wave -noupdate -group MASTER /test_top/dut/MASTER/SDIO_o
add wave -noupdate -group MASTER /test_top/dut/MASTER/fin
add wave -noupdate -group MASTER /test_top/dut/MASTER/no_bytes_r
add wave -noupdate -group MASTER /test_top/dut/MASTER/SPC_LH
add wave -noupdate -group MASTER /test_top/dut/SLAVE/REG_IN/clk
add wave -noupdate -group MASTER /test_top/dut/SLAVE/REG_IN/nRst
add wave -noupdate -group REG_IN /test_top/dut/SLAVE/REG_IN/SDIO
add wave -noupdate -group REG_IN /test_top/dut/SLAVE/REG_IN/SPC_posedge
add wave -noupdate -group REG_IN /test_top/dut/SLAVE/REG_IN/SPC_negedge
add wave -noupdate -group REG_IN /test_top/dut/SLAVE/REG_IN/leer_dir
add wave -noupdate -group REG_IN /test_top/dut/SLAVE/REG_IN/leer_dato_reg
add wave -noupdate -group REG_IN /test_top/dut/SLAVE/REG_IN/reset_regs_SDIO
add wave -noupdate -group REG_IN /test_top/dut/SLAVE/REG_IN/MSB_LSB
add wave -noupdate -group REG_IN -radix hexadecimal /test_top/dut/SLAVE/REG_IN/dato_reg
add wave -noupdate -group REG_IN -radix hexadecimal /test_top/dut/SLAVE/REG_IN/instruccion
add wave -noupdate -group REG_IN /test_top/dut/SLAVE/REG_IN/SDIO_syn
add wave -noupdate -group REG_IN /test_top/dut/SLAVE/REG_IN/SDIO_meta
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/nCS
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/SPC
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/MSB_LSB
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/leer_dir
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/leer_dato_reg
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/escribir_dato_reg
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/reset_regs_SDIO
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/dato_out
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/load
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/SPC_posedge
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/SPC_negedge
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/registros_s
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/estado
add wave -noupdate -group CONTROL -radix unsigned /test_top/dut/SLAVE/CONTROL_SLAVE/cnt_pulsos
add wave -noupdate -group CONTROL -radix hexadecimal /test_top/dut/SLAVE/CONTROL_SLAVE/dato_reg
add wave -noupdate -group CONTROL -radix hexadecimal /test_top/dut/SLAVE/CONTROL_SLAVE/instruccion
add wave -noupdate -group CONTROL -radix hexadecimal /test_top/dut/SLAVE/CONTROL_SLAVE/dir_reg
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/op_nWR
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/REG_OUT/desplaza_bit
add wave -noupdate -group CONTROL -radix unsigned /test_top/dut/SLAVE/CONTROL_SLAVE/cnt_neg
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/SPC_t1
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/add_up
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/mode_3_4_h
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/str_sgl_ins
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/fin_rd
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/WE
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/dato_wr
add wave -noupdate -group CONTROL -radix hexadecimal /test_top/dut/SLAVE/CONTROL_SLAVE/reg0
add wave -noupdate -group CONTROL -radix hexadecimal /test_top/dut/SLAVE/CONTROL_SLAVE/reg1
add wave -noupdate -group CONTROL -radix hexadecimal /test_top/dut/SLAVE/CONTROL_SLAVE/reg16
add wave -noupdate -group CONTROL -radix hexadecimal /test_top/dut/SLAVE/CONTROL_SLAVE/reg17
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/add_size
add wave -noupdate -group CONTROL /test_top/dut/SLAVE/CONTROL_SLAVE/data_size
add wave -noupdate -expand -group REG_OUT /test_top/dut/SLAVE/REG_OUT/SPC_posedge
add wave -noupdate -expand -group REG_OUT /test_top/dut/SLAVE/REG_OUT/SPC_negedge
add wave -noupdate -expand -group REG_OUT /test_top/dut/SLAVE/REG_OUT/escribir_dato_reg
add wave -noupdate -expand -group REG_OUT -radix hexadecimal /test_top/dut/SLAVE/REG_OUT/dato_in
add wave -noupdate -expand -group REG_OUT /test_top/dut/SLAVE/REG_OUT/MSB_LSB
add wave -noupdate -expand -group REG_OUT /test_top/dut/SLAVE/REG_OUT/ctrl
add wave -noupdate -expand -group REG_OUT /test_top/dut/SLAVE/REG_OUT/load
add wave -noupdate -expand -group REG_OUT /test_top/dut/SLAVE/REG_OUT/SDO
add wave -noupdate -expand -group REG_OUT /test_top/dut/SLAVE/REG_OUT/SDIO
add wave -noupdate -expand -group REG_OUT -radix binary /test_top/dut/SLAVE/REG_OUT/dato_out
add wave -noupdate -expand -group TEST /test_top/dut/SLAVE/clk
add wave -noupdate -expand -group TEST /test_top/dut/SLAVE/SDO
add wave -noupdate -expand -group TEST /test_top/dut/MASTER/SDIO
add wave -noupdate -expand -group TEST /test_top/dut/MASTER/SPC_posedge
add wave -noupdate -expand -group TEST /test_top/dut/MASTER/SPC_negedge
add wave -noupdate -expand -group TEST /test_top/dut/SLAVE/CONTROL_SLAVE/ctrl
add wave -noupdate -expand -group TEST /test_top/dut/SLAVE/CONTROL_SLAVE/load
add wave -noupdate -expand -group TEST /test_top/dut/SLAVE/CONTROL_SLAVE/desplaza_bit
add wave -noupdate -expand -group TEST /test_top/dut/SLAVE/CONTROL_SLAVE/estado
add wave -noupdate -expand -group TEST -radix unsigned /test_top/dut/SLAVE/CONTROL_SLAVE/cnt_pulsos
add wave -noupdate -expand -group TEST -radix unsigned /test_top/dut/SLAVE/CONTROL_SLAVE/cnt_neg
add wave -noupdate -expand -group TEST -radix hexadecimal /test_top/dut/SLAVE/CONTROL_SLAVE/dir_reg
add wave -noupdate -expand -group TEST -radix hexadecimal /test_top/dut/SLAVE/CONTROL_SLAVE/reg0
add wave -noupdate -expand -group TEST -radix hexadecimal /test_top/dut/SLAVE/CONTROL_SLAVE/reg1
add wave -noupdate -expand -group TEST -radix hexadecimal /test_top/dut/SLAVE/CONTROL_SLAVE/reg16
add wave -noupdate -expand -group TEST -radix hexadecimal /test_top/dut/SLAVE/CONTROL_SLAVE/reg17
add wave -noupdate -expand -group TEST -radix hexadecimal /test_top/dut/reg_tx
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {11261027 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {7013580 ps} {13693193 ps}
