# MicroBlaze V Vivado Block Design for Arty A7-100T

## Overview

This repository provides scripts for creating a Vivado Block Design based on MicroBlaze V.  
The generated Block Design is intended for running an RTOS.

<img title="" src="images/BD-1.avif">

## Related Repository

The Zephyr RTOS environment designed for this Block Design is available in the following repository:

- https://github.com/hkato-sssl/arty-a7-mbv32-zephyr.git

## Environment

- Ubuntu Desktop 24.04
- Vivado 2025.1

## Included Devices

- MicroBlaze V
- DDR RAM 256MiB
- Local Memory 16KiB
- AXI Interrupt Controller
- AXI Timer
- AXI UART Lite
  - Serial console
- AXI GPIO x2
  - Push-button and slide-switch input
  - LED control
- AXI Quad SPI
  - Used for onboard Flash memory control
  - Standard SPI mode
- AXI Ethernet Lite

## Prerequisites

This script creates the project under `$HOME/ws/vivado/arty-a7-mbv32`.  
If you want to change the path, modify `PROJ_NAME` and `PROJ_DIR` in `arty-a7-mbv32.tcl`.

This script assumes that Vivado is installed at `/tools/Xilinx/2025.1`.

## Procedure

### Create Block Design

First, obtain the script and create the Block Design in Vivado. If the board information for the Arty A7-100T is not installed in Vivado, it may take some time to download and install the board files.

```
source /tools/Xilinx/2025.1/Vivado/settings64.sh
git clone https://github.com/hkato-sssl/arty-a7-mbv32.git
cd arty-a7-mbv32/vivado
vivado -source arty-a7-mbv32.tcl
```

Executing the script will launch Vivado and create the Block Design. At this point, the generated Block Design is not ready for bitstream generation yet.

### MIG Configuration

Immediately after running the script, bitstream generation is not yet possible. You need to change the MIG settings.

Double-click **mig_7series_0** in the upper right corner of the Block Design to display the Memory Interface Generator window.

<img title="" src="images/MIG-1.avif">

Once the window appears, click **Next** button seven times.

<img title="" src="images/MIG-2.avif">

When FPGA Options appears, change System Clock from `[Single-Ended]` to `[No Buffer]`. After changing, click **Next** button three times.

<img title="" src="images/MIG-3.avif">

When Pin Selection appears, click **Validate** button, then click **OK** button in displayed the DRC Validation window. After that, click **Next** button three times.

<img title="" src="images/MIG-4.avif">

When the Simulation Options window appears, review and accept the License Agreement, check `Accept`, and click **Next** twice.

<img title="" src="images/MIG-5.avif">

When the Design Notes are displayed, click **Generate** button to finish.

<img title="" src="images/MIG-6.avif">

### Generate Bitstream and XSA file

Run the following commands from the TCL Console to generate the bitstream and XSA file.

```
source generate.tcl
```

When the script execution completes, the "Bitstream Generation Completed" window will appear. Please click **Cancel** to close it.

If the commands complete successfully, `arty-a7-mbv32.xsa` will be generated.
