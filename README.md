# Computer Architecture Course

> **Hanyang University ERICA Campus | Department of Robotics**  
> **Computer Architecture Course**  
> **Instructor: Prof. Bumjin Jang**

A 13-week project-based learning course: Build a 5-stage pipelined MIPS CPU and use it to control a virtual motor via PWM.

## 📋 Course Syllabus

| Week | Topic | Key Concepts |
|------|-------|--------------|
| 01 | ALU Design | ADD, SUB, AND, OR, SLT |
| 02 | Register File | Dual-read, Single-write |
| 03 | Memory & PC | Instruction/Data Memory, PC+4 |
| 04 | Single-Cycle Datapath | IF/ID/EX/MEM/WB Integration |
| 05 | Control Unit | Main Decoder, ALU Decoder |
| 06 | Pipeline Structure | Pipeline Registers |
| 07 | Pipeline Integration | Signal Propagation |
| 08 | Data Forwarding | Forwarding Unit |
| 09 | Stall & Flush | Hazard Detection Unit |
| 10 | Jump Instructions | j, jal, jr Support |
| 11 | MMIO & PWM Controller | 10kHz PWM Generator |
| 12 | Motor Control Simulation | Accel/Decel Algorithm |
| 13 | Final PBL Demo | Waveform Presentation |

## 🏗️ Architecture

```
Week 01-05: Single-Cycle MIPS CPU
     ↓
Week 06-09: 5-Stage Pipelined CPU
     ↓
Week 10-11: Jump + PWM I/O
     ↓
Week 12-13: Motor Control Application
```

## 🚀 Getting Started

### Prerequisites
- [Icarus Verilog](https://bleyer.org/icarus/)
- [GTKWave](http://gtkwave.sourceforge.net/) (for waveforms)

### Quick Start
```bash
cd class_01
make        # Compile and run
make wave   # View waveform
```

## 📁 Structure

```
verilog/
├── class_01/    # ALU
├── class_02/    # Register File
├── class_03/    # Memory + PC
├── class_04/    # Single-cycle Datapath
├── class_05/    # Control Unit
├── class_06/    # Pipeline Structure
├── class_07/    # Pipeline Integration
├── class_08/    # Forwarding
├── class_09/    # Hazard Unit
├── class_10/    # Jump Instructions
├── class_11/    # PWM Controller
├── class_12/    # Motor Control
└── class_13/    # Final Demo
```

## 📝 License

Educational use only.
