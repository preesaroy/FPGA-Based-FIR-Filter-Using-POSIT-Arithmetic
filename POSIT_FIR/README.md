# POSIT-Based FIR Filter Using SystemVerilog

## Overview

This project implements a Finite Impulse Response (FIR) filter using the POSIT<8,1> number system. The design uses SystemVerilog behavioral models for POSIT addition and multiplication and is intended for functional simulation in ModelSim/Questa.

## Objectives

- Implement a 4-tap FIR filter using POSIT arithmetic.
- Develop behavioral POSIT adder and multiplier modules.
- Simulate the design using a SystemVerilog testbench.
- Examine the filter output and validate arithmetic behavior.

## FIR Filter Equation

The filter uses four coefficients:

- b0 = 1
- b1 = 2
- b2 = 2
- b3 = 1

The output is calculated as:

\[
y[n]=x[n]+2x[n-1]+2x[n-2]+x[n-3]
\]

## POSIT Number Format

This project uses POSIT<8,1>:

- Total width: 8 bits
- Exponent size (es): 1 bit
- Values are stored as POSIT-encoded bit patterns.

Example encodings:

| Decimal value | POSIT encoding |
|---:|---|
| 0 | `8'h00` |
| 1 | `8'h40` |
| 2 | `8'h50` |
| 3 | `8'h58` |
| 4 | `8'h60` |
| 5 | `8'h64` |

## Project Structure

```text
POSIT_FIR/
├── fir_filter_posit.sv
├── fir_tb_posit.sv
├── posit_add_8_es1.sv
├── posit_mult_8_es1.sv
└── README.md
```

## Module Description

| File | Description |
|---|---|
| `fir_filter_posit.sv` | Top-level 4-tap FIR filter |
| `fir_tb_posit.sv` | Testbench providing clock, reset, and input samples |
| `posit_add_8_es1.sv` | Behavioral POSIT adder |
| `posit_mult_8_es1.sv` | Behavioral POSIT multiplier |

## Tools Required

- ModelSim or QuestaSim with SystemVerilog support
- Xilinx ISE may be used for project organization, but its XST synthesis flow is not suitable for the simulation-only arithmetic models.

## Simulation Instructions

Open ModelSim and navigate to the directory containing the source files:

```tcl
cd C:/POSIT_FIR
```

Create the simulation library and compile the source files:

```tcl
vlib work
vlog -sv posit_add_8_es1.sv
vlog -sv posit_mult_8_es1.sv
vlog -sv fir_filter_posit.sv
vlog -sv fir_tb_posit.sv
```

Load the testbench and run the simulation:

```tcl
vsim work.fir_tb_posit
add wave -r /*
run -all
```

Replace the directory path and filenames if your files are stored elsewhere or use different extensions.

## Testbench Input Sequence

The testbench applies the following decimal values encoded in POSIT<8,1>:

`0, 1, 2, 3, 4, 5, 0`

The clock period is 10 ns, and reset is initially asserted.

## Limitations

- The POSIT adder and multiplier are behavioral simulation models using real-valued calculations.
- The models are not synthesizable FPGA hardware.
- The current encoding routine truncates fraction bits rather than implementing fully rounded POSIT arithmetic.
- Arithmetic results should be validated against a trusted POSIT reference implementation before making performance or accuracy claims.

## Future Improvements

- Implement synthesizable POSIT arithmetic circuits.
- Compare POSIT and IEEE 754 floating-point FIR implementations.
- Measure numerical error, latency, and resource utilization.
- Develop a comprehensive testbench with reference-model comparisons.

## License

Add an appropriate license before distributing or reusing this project.

