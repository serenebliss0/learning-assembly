# Makefile for RISC-V projects

AS = riscv64-unknown-elf-as
LD = riscv64-unknown-elf-ld
OBJDUMP = riscv64-unknown-elf-objdump

ASFLAGS = -march=rv32i -mabi=ilp32
LDFLAGS = 

SRC = registers.s
OBJ = registers.o
BIN = program

all: $(BIN)

$(OBJ): $(SRC)
	$(AS) $(ASFLAGS) $(SRC) -o $(OBJ)

$(BIN): $(OBJ)
	$(LD) -m elf32lriscv $(OBJ) -o $(BIN)

run: $(BIN)
	qemu-riscv32 ./$(BIN)

disasm: $(BIN)
	$(OBJDUMP) -d $(BIN)

clean:
	rm -f $(OBJ) $(BIN)

.PHONY: all run disasm clean