# MIPS CPU Design Course - Verilog Teaching Materials

> **Hanyang University ERICA Campus | Department of Robotics**  
> **Computer Architecture Course**  
> **Instructor: Prof. Bumjin Jang**

A progressive 15-week MIPS CPU design course, teaching students how to build a complete pipelined processor from scratch using Verilog HDL.

## 📋 Course Overview

| Week | Topic | Key Concepts |
|------|-------|--------------|
| 01 | Basic Components | Shift Registers, Sequential Logic |
| 02 | ALU Design | ADD, SUB, SLT Operations |
| 03 | Memory Units | Register File, Instruction Memory |
| 04 | IF Stage | Program Counter, Instruction Fetch |
| 05 | Single-Cycle Datapath | Complete Data Path Integration |
| 06 | Control Unit | Main Decoder, ALU Decoder |
| 07 | Complete Single-Cycle | Full MIPS CPU (R/I-type, lw/sw, beq) |
| 08 | 5-Stage Pipeline | IF/ID/EX/MEM/WB Registers |
| 09 | Forwarding Unit | Data Hazard Resolution |
| 10 | Hazard Unit | Load-Use Stalls, Pipeline Control |
| 11 | Branch Optimization | Early Branch Resolution in ID Stage |
| 12 | Memory-Mapped I/O | Switches Input, LED Output |
| 13 | Jump Instructions | j, jal, jr Support |
| 14 | Performance Analysis | Cycle Counting, Pipeline Efficiency |
| 15 | Final Demo | Interactive LED Counter Project |

## 🏗️ Architecture Evolution

```
Week 01-04: Individual Components
     ↓
Week 05-07: Single-Cycle MIPS CPU
     ↓
Week 08-11: Pipelined MIPS CPU
     ↓
Week 12-15: I/O & Advanced Features
```

## 🚀 Getting Started

### Prerequisites
- [Icarus Verilog](http://iverilog.icarus.com/) (iverilog)
- [GTKWave](http://gtkwave.sourceforge.net/) (optional, for waveform viewing)

### Using Makefiles
Each class includes a Makefile for convenience:

```bash
cd class_06
make        # Compile and run
make wave   # Open GTKWave
make clean  # Clean generated files
```

## 🎯 Key Features

- **Progressive Learning**: Each week builds on previous concepts
- **Complete Testbenches**: Every module includes simulation testbench
- **Real Hardware Ready**: Final design supports FPGA deployment
- **MMIO Support**: GPIO interface for switches and LEDs

## 📝 License

This project is for educational purposes.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.
