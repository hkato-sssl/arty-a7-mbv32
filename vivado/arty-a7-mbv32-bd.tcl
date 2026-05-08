# Copyright (c) 2026 Hidekazu Kato <hkato.sssl@gmail.com>
# SPDX-License-Identifier: MIT

# Clock
local::create_xip clk_wiz:6.0 system_clock {
    CONFIG.CLKOUT2_JITTER {114.829}
    CONFIG.CLKOUT2_PHASE_ERROR {98.575}
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {200}
    CONFIG.CLKOUT2_USED {true}
    CONFIG.CLKOUT3_JITTER {175.402}
    CONFIG.CLKOUT3_PHASE_ERROR {98.575}
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {25}
    CONFIG.CLKOUT3_USED {true}
    CONFIG.CLKOUT4_JITTER {151.636}
    CONFIG.CLKOUT4_PHASE_ERROR {98.575}
    CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {50}
    CONFIG.CLKOUT4_USED {true}
    CONFIG.MMCM_CLKOUT1_DIVIDE {5}
    CONFIG.MMCM_CLKOUT2_DIVIDE {40}
    CONFIG.MMCM_CLKOUT3_DIVIDE {20}
    CONFIG.NUM_OUT_CLKS {4}
    CONFIG.USE_RESET {false}
}
local::create_xip_cell util_ds_buf:2.2 sys_clock_bufg {
    CONFIG.C_BUF_TYPE   BUFG
}
local::make_pin_external sys_clock_bufg/BUFG_I sys_clock
local::connect_pins sys_clock_bufg/BUFG_O system_clock/clk_in1

# MIG
local::create_xip mig_7series:4.2 mig_7series_0
apply_board_connection -board_interface "ddr3_sdram" -ip_intf "mig_7series_0/mig_ddr_interface" -diagram $BD_DESIGN
delete_bd_objs [get_bd_nets clk_ref_i_1] [get_bd_ports clk_ref_i]
delete_bd_objs [get_bd_nets sys_clk_i_1] [get_bd_ports sys_clk_i]
local::connect_pins mig_7series_0/sys_clk_i sys_clock_bufg/BUFG_O
local::connect_pins mig_7series_0/clk_ref_i system_clock/clk_out2

# MIG UI reset
local::create_inline_hdl ilvector_logic:1.0 inv_ui_reset {
    CONFIG.C_OPERATION  not
    CONFIG.C_SIZE       1
}
local::connect_pins mig_7series_0/ui_clk_sync_rst inv_ui_reset/Op1
local::connect_pins mig_7series_0/aresetn inv_ui_reset/Res

# Memory Interconnect
local::create_xip axi_interconnect:2.1 mem_interconnect {
    CONFIG.NUM_MI   1
    CONFIG.NUM_SI   2
}
local::connect_ifs mem_interconnect/M00_AXI mig_7series_0/S_AXI
local::connect_pins mem_interconnect/M00_ACLK mig_7series_0/ui_clk
local::connect_pins mem_interconnect/M00_ARESETN inv_ui_reset/Res

# MicroBlaze-V
set mbv [local::create_xip microblaze_riscv:1.0 microblaze_riscv_0]
apply_bd_automation -rule xilinx.com:bd_rule:microblaze_riscv -config {
    axi_intc        {1}
    axi_periph      {Enabled}
    debug_module    {Debug Enabled}
    ecc             {None}
    local_mem       {16KB}
    preset          {Real-time}
} $mbv

# Configure the AXI Interrupt Controller
set_property CONFIG.C_HAS_FAST {0} [get_bd_cells microblaze_riscv_0_axi_intc]

# AXI Timer
local::create_xip axi_timer:2.0 axi_timer_0

# AXI UART Lite
local::create_xip axi_uartlite:2.0 axi_uartlite_0 {
    CONFIG.C_BAUDRATE   115200
}
apply_board_connection -board_interface usb_uart -ip_intf axi_uartlite_0/UART -diagram $BD_DESIGN

# Buttons and slide switches via AXI GPIO
local::create_xip axi_gpio:2.0 axi_gpio_inputs {
    CONFIG.C_INTERRUPT_PRESENT  1
}
apply_board_connection -board_interface push_buttons_4bits -ip_intf axi_gpio_inputs/GPIO -diagram $BD_DESIGN
apply_board_connection -board_interface dip_switches_4bits -ip_intf axi_gpio_inputs/GPIO2 -diagram $BD_DESIGN

# LEDs via AXI GPIO
local::create_xip axi_gpio:2.0 axi_gpio_leds {
    CONFIG.C_INTERRUPT_PRESENT  0
}
apply_board_connection -board_interface led_4bits -ip_intf axi_gpio_leds/GPIO -diagram $BD_DESIGN
apply_board_connection -board_interface rgb_led -ip_intf axi_gpio_leds/GPIO2 -diagram $BD_DESIGN

# AXI Ethernetlite
local::create_xip axi_ethernetlite:3.0 axi_ethernetlite_0
local::make_pin_external system_clock/clk_out3 ETH_REF_CLK
apply_board_connection -board_interface eth_mdio_mdc -ip_intf axi_ethernetlite_0/MDIO -diagram $BD_DESIGN
apply_board_connection -board_interface eth_mii -ip_intf axi_ethernetlite_0/MII -diagram $BD_DESIGN

# AXI Quad SPI (Standard mode)
local::create_xip axi_quad_spi:3.2 axi_quad_spi_0
apply_board_connection -board_interface qspi_flash -ip_intf axi_quad_spi_0/SPI_0 -diagram $BD_DESIGN
local::connect_pins axi_quad_spi_0/ext_spi_clk system_clock/clk_out4
local::set_property axi_quad_spi_0 {
    CONFIG.C_FIFO_DEPTH {256}
    CONFIG.C_SCK_RATIO {2}
    CONFIG.C_SPI_MODE {0}
}

# Connect AXI peripheral interfaces
set_property CONFIG.NUM_MI {7} [get_bd_cells microblaze_riscv_0_axi_periph]
local::connect_ifs microblaze_riscv_0/M_AXI_IC mem_interconnect/S00_AXI
local::connect_ifs microblaze_riscv_0/M_AXI_DC mem_interconnect/S01_AXI
local::connect_ifs microblaze_riscv_0_axi_periph/M01_AXI axi_timer_0/S_AXI
local::connect_ifs microblaze_riscv_0_axi_periph/M02_AXI axi_uartlite_0/S_AXI
local::connect_ifs microblaze_riscv_0_axi_periph/M03_AXI axi_gpio_inputs/S_AXI
local::connect_ifs microblaze_riscv_0_axi_periph/M04_AXI axi_gpio_leds/S_AXI
local::connect_ifs microblaze_riscv_0_axi_periph/M05_AXI axi_ethernetlite_0/S_AXI
local::connect_ifs microblaze_riscv_0_axi_periph/M06_AXI axi_quad_spi_0/AXI_LITE

# Interrupt signals
set_property CONFIG.NUM_PORTS {5} [get_bd_cells microblaze_riscv_0_xlconcat]
local::connect_pins axi_timer_0/interrupt microblaze_riscv_0_xlconcat/In0
local::connect_pins axi_gpio_inputs/ip2intc_irpt microblaze_riscv_0_xlconcat/In1
local::connect_pins axi_uartlite_0/interrupt microblaze_riscv_0_xlconcat/In2
local::connect_pins axi_ethernetlite_0/ip2intc_irpt microblaze_riscv_0_xlconcat/In3
local::connect_pins axi_quad_spi_0/ip2intc_irpt microblaze_riscv_0_xlconcat/In4

# Reset signals
apply_board_connection -board_interface reset -ip_intf rst_system_clock_100M/ext_reset -diagram $BD_DESIGN
local::connect_pins rst_system_clock_100M/peripheral_aresetn {
    mig_7series_0/sys_rst
    mem_interconnect/ARESETN
    mem_interconnect/S00_ARESETN
    mem_interconnect/S01_ARESETN
    microblaze_riscv_0_axi_periph/M01_ARESETN
    microblaze_riscv_0_axi_periph/M02_ARESETN
    microblaze_riscv_0_axi_periph/M03_ARESETN
    microblaze_riscv_0_axi_periph/M04_ARESETN
    microblaze_riscv_0_axi_periph/M05_ARESETN
    microblaze_riscv_0_axi_periph/M06_ARESETN
    axi_timer_0/s_axi_aresetn
    axi_uartlite_0/s_axi_aresetn
    axi_gpio_inputs/s_axi_aresetn
    axi_gpio_leds/s_axi_aresetn
    axi_ethernetlite_0/s_axi_aresetn
    axi_quad_spi_0/s_axi_aresetn
}

# Clock signals
local::connect_pins system_clock/clk_out1 {
    mem_interconnect/ACLK
    mem_interconnect/S00_ACLK
    mem_interconnect/S01_ACLK
    microblaze_riscv_0_axi_periph/M01_ACLK
    microblaze_riscv_0_axi_periph/M02_ACLK
    microblaze_riscv_0_axi_periph/M03_ACLK
    microblaze_riscv_0_axi_periph/M04_ACLK
    microblaze_riscv_0_axi_periph/M05_ACLK
    microblaze_riscv_0_axi_periph/M06_ACLK
    axi_timer_0/s_axi_aclk
    axi_uartlite_0/s_axi_aclk
    axi_gpio_inputs/s_axi_aclk
    axi_gpio_leds/s_axi_aclk
    axi_ethernetlite_0/s_axi_aclk
    axi_quad_spi_0/s_axi_aclk
}

# Epilogue
assign_bd_address
regenerate_bd_layout

