# Copyright (c) 2026 Hidekazu Kato <hkato.sssl@gmail.com>
# SPDX-License-Identifier: MIT

set_property PACKAGE_PIN E3 [get_ports {sys_clock[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sys_clock[0]}]
set_property PACKAGE_PIN G18 [get_ports ETH_REF_CLK]
set_property IOSTANDARD LVCMOS33 [get_ports ETH_REF_CLK]
