save_bd_design
launch_runs impl_1 -to_step write_bitstream -jobs $JOBS
wait_on_run impl_1
write_hw_platform -fixed -include_bit -force -file $PROJ_DIR/$PROJ_NAME.xsa
