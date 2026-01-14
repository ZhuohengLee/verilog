# 1. Define file name variables (Updated for Instruction Memory)
SRC = instruction_memory.v
TB  = instruction_memory_tb.v

# Define output file names
OUT = imem_wave.out
# 注意：这里的 VCD 名字必须和 instruction_memory_tb.v 里 $dumpfile("instr_mem.vcd") 保持一致
VCD = instr_mem.vcd

# 2. Default Target
all: compile run

# 3. Compile Target
compile:
	iverilog -o $(OUT) $(TB) $(SRC)

# 4. Run Simulation Target
run:
	vvp -n $(OUT)

# 5. View Waveforms Target
wave:
	gtkwave $(VCD) &

# 6. Clean Target (Windows compatible)
clean:
	if exist $(OUT) del $(OUT)
	if exist $(VCD) del $(VCD)