# Copyright (c) 2026 Hidekazu Kato <hkato.sssl@gmail.com>
# SPDX-License-Identifier: MIT

# parameters
set JOBS 8
set PROJ_NAME arty-a7-mbv32
set PROJ_DIR $env(HOME)/ws/vivado/$PROJ_NAME
set SCRIPT_DIR [file dirname [info script]]
set XDC_FILE $SCRIPT_DIR/$PROJ_NAME.xdc
set BD_FILE $SCRIPT_DIR/${PROJ_NAME}-bd.tcl
set BD_DESIGN design_1

# import the local functions
source $SCRIPT_DIR/local-funcs.tcl

# set the board repository path
set_param board.repoPaths $env(HOME)/.Xilinx/Vivado/2025.1/xhub/board_store

# create the project
if {! [local::is_installed digilentinc.com:arty-a7-100:part0:1.1]} {
    xhub::refresh_catalog [xhub::get_xstores xilinx_board_store]
    xhub::install [xhub::get_xitems digilentinc.com:xilinx_board_store:arty-a7-100:1.1]
}
create_project $PROJ_NAME $PROJ_DIR -part xc7a100tcsg324-1
set_property board_part digilentinc.com:arty-a7-100:part0:1.1 [current_project]

# create the block design
create_bd_design $BD_DESIGN
source $BD_FILE
save_bd_design

# create the wrapper file
make_wrapper -files [get_files $PROJ_DIR/$PROJ_NAME.srcs/sources_1/bd/$BD_DESIGN/$BD_DESIGN.bd] -top
add_files -norecurse $PROJ_DIR/$PROJ_NAME.gen/sources_1/bd/$BD_DESIGN/hdl/${BD_DESIGN}_wrapper.v

# add the constraint file
add_files -fileset constrs_1 -norecurse $XDC_FILE
import_files -fileset constrs_1 $XDC_FILE

# generate the bitstream file
#update_compile_order -fileset sources_1
#launch_runs impl_1 -to_step write_bitstream -jobs $JOBS
#wait_on_run impl_1

# write the XSA file
#write_hw_platform -fixed -include_bit -force -file $PROJ_DIR/$PROJ_NAME.xsa

