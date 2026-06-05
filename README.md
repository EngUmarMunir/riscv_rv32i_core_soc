# RISC-V RV32I Core SoC

A lightweight SystemVerilog implementation of a RISC-V RV32I single-cycle System-on-Chip (SoC). The design separates the processor core from instruction and data memories, following a clean and modular architecture suitable for learning, verification, and future SoC development.

## Features

* RV32I Base Integer ISA Support
* Single-Cycle Processor Core
* Separate Instruction and Data Memories
* Modular RTL Design
* Load, Store, Branch, Jump, and Arithmetic Instructions
* FPGA and Simulation Friendly
* Easy Integration of Future Peripherals and Caches

## Repository Structure

```text
core.sv               # SoC top-level wrapper
riscv_top.sv          # RV32I processor core
program_counter.sv
reg_file.sv
main_ctrl.sv
alu_ctrl.sv
alu.sv
imm_gen.sv
branch.sv
load_store_unit.sv
inst_mem.sv
data_mem.sv
*fib_im.mem                 # Program memory files
```

## Simulation

Supported simulators:

* Vivado XSim
* Cadence Xcelium
* Verilator
* Spike# riscv_rv32i_core_soc
# riscv_rv32i_core_soc
