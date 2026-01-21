# RISC-V Development Environment Setup

This guide will help you set up your environment for RISC-V assembly programming.

## Choose Your Operating System

- [Linux Setup](#linux-setup) (Recommended - easiest)
- [Windows Setup](#windows-setup)
- [macOS Setup](#macos-setup)

---

## Linux Setup

Linux is the easiest platform for learning RISC-V assembly!

### Install RISC-V GNU Toolchain

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install gcc-riscv64-unknown-elf gdb-multiarch qemu-system-misc
```

**Fedora/RHEL:**
```bash
sudo dnf install gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu qemu-system-riscv
```

**Arch:**
```bash
sudo pacman -S riscv64-linux-gnu-gcc riscv64-linux-gnu-binutils qemu-system-riscv
```

**Build from Source (any distro):**
```bash
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32
make
# Add /opt/riscv/bin to PATH
```

### Verify Installation

```bash
riscv64-unknown-elf-as --version    # Assembler
riscv64-unknown-elf-ld --version    # Linker
riscv64-unknown-elf-gcc --version   # Compiler
qemu-system-riscv32 --version       # Emulator
```

### Test Your Setup

Create a test file `hello.s`:

```asm
.section .data
msg:
    .string "Hello, RISC-V!\n"

.section .text
.globl _start

_start:
    # Write system call
    li a0, 1           # file descriptor (stdout)
    la a1, msg         # message address
    li a2, 15          # message length
    li a7, 64          # syscall number for write
    ecall

    # Exit system call
    li a0, 0           # exit code
    li a7, 93          # syscall number for exit
    ecall
```

Assemble and link:
```bash
riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 hello.s -o hello.o
riscv64-unknown-elf-ld hello.o -o hello
```

Run in QEMU:
```bash
qemu-riscv32 ./hello
```

Should print: `Hello, RISC-V!`

✅ **If this works, you're all set!**

---

## Windows Setup

### Option 1: WSL (Windows Subsystem for Linux) - Recommended

1. **Enable WSL:**
   - Open PowerShell as Administrator
   - Run: `wsl --install`
   - Restart computer
   - Install Ubuntu from Microsoft Store

2. **Follow Linux setup above** in your WSL terminal

### Option 2: Native Windows with MSYS2

1. **Download and Install MSYS2:**
   - Visit: https://www.msys2.org/
   - Download and run installer
   - Follow installation instructions

2. **Install RISC-V Toolchain:**
   ```bash
   # In MSYS2 terminal
   pacman -Syu
   pacman -S mingw-w64-x86_64-riscv64-unknown-elf-gcc
   pacman -S mingw-w64-x86_64-qemu
   ```

3. **Add to PATH** (in MSYS2 environment)

### Option 3: Pre-built Toolchain

1. **Download from SiFive:**
   - Visit: https://www.sifive.com/software
   - Download RISC-V GNU Toolchain for Windows
   - Extract to `C:\riscv`
   - Add `C:\riscv\bin` to PATH

2. **Install QEMU:**
   - Download from: https://www.qemu.org/download/#windows
   - Install and add to PATH

---

## macOS Setup

### Install Homebrew (if not already installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Install RISC-V Toolchain

```bash
brew tap riscv-software-src/riscv
brew install riscv-tools
brew install qemu
```

### Alternative: Build from Source

```bash
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32
make
# Add /opt/riscv/bin to PATH
```

### Verify Installation

```bash
riscv64-unknown-elf-gcc --version
qemu-system-riscv32 --version
```

---

## Editor Setup

Choose a text editor with syntax highlighting:

### VS Code (Recommended)

1. Install VS Code: https://code.visualstudio.com/
2. Install extensions:
   - "RISC-V Support" by zhwu95
   - "ASM Code Lens" by maziac

### Vim

Add to `~/.vimrc`:
```vim
syntax on
filetype plugin indent on
au BufRead,BufNewFile *.s set filetype=riscvasm
```

### Other Options

- Sublime Text with assembly plugin
- Atom with language-riscv
- Notepad++ with custom syntax

---

## Using QEMU Emulator

QEMU can emulate RISC-V systems.

### User Mode (Simple Programs)

```bash
# For RV32
qemu-riscv32 ./program

# For RV64
qemu-riscv64 ./program
```

### System Mode (Full System)

```bash
# Boot Linux on RISC-V
qemu-system-riscv32 -machine virt -bios none -kernel kernel.elf
```

### With GDB Debugging

```bash
# Terminal 1: Start QEMU with GDB server
qemu-riscv32 -g 1234 ./program

# Terminal 2: Connect GDB
riscv64-unknown-elf-gdb program
(gdb) target remote localhost:1234
(gdb) break _start
(gdb) continue
```

---

## Alternative: Online Simulators

No installation needed!

### RISC-V Online Simulator
- Visit: https://riscvasm.lucasteske.dev/
- Write, assemble, and run code in browser
- Great for quick experiments

### RISC-V Interpreter
- Visit: https://www.cs.cornell.edu/courses/cs3410/2019sp/riscv/interpreter/
- Educational RISC-V interpreter
- Visualize instruction execution

---

## Development Workflow

### Simple Makefile

Create `Makefile`:

```makefile
# Makefile for RISC-V projects

AS = riscv64-unknown-elf-as
LD = riscv64-unknown-elf-ld
OBJDUMP = riscv64-unknown-elf-objdump

ASFLAGS = -march=rv32i -mabi=ilp32
LDFLAGS = 

SRC = program.s
OBJ = program.o
BIN = program

all: $(BIN)

$(OBJ): $(SRC)
	$(AS) $(ASFLAGS) $(SRC) -o $(OBJ)

$(BIN): $(OBJ)
	$(LD) $(LDFLAGS) $(OBJ) -o $(BIN)

run: $(BIN)
	qemu-riscv32 ./$(BIN)

disasm: $(BIN)
	$(OBJDUMP) -d $(BIN)

clean:
	rm -f $(OBJ) $(BIN)

.PHONY: all run disasm clean
```

Usage:
```bash
make        # Build
make run    # Build and run
make disasm # Disassemble
make clean  # Clean up
```

---

## Common Issues

### "command not found" errors

**Linux:** Toolchain not installed or not in PATH
```bash
which riscv64-unknown-elf-as    # Check if installed
# If not found, install toolchain
```

**Windows:** Add toolchain to PATH environment variable

**macOS:** 
```bash
brew install riscv-tools
```

### QEMU not working

Make sure QEMU is installed and supports RISC-V:
```bash
qemu-system-riscv32 --version
qemu-riscv32 --version
```

### Wrong ABI or architecture

Make sure to specify:
- `-march=rv32i` for 32-bit base
- `-march=rv64i` for 64-bit base
- Add extensions: `rv32im`, `rv32imc`, etc.
- `-mabi=ilp32` for 32-bit integer ABI
- `-mabi=lp64` for 64-bit integer ABI

### "Illegal instruction" errors

Check that your instructions match the `-march` setting. For example, multiplication requires M extension (`rv32im`).

---

## Understanding RISC-V Variants

### Base ISA

- **RV32I**: 32-bit base integer
- **RV64I**: 64-bit base integer
- **RV128I**: 128-bit (rarely used)

### Extensions

- **M**: Integer multiplication and division
- **A**: Atomic operations
- **F**: Single-precision floating point
- **D**: Double-precision floating point
- **C**: Compressed (16-bit) instructions

### Common Combinations

- **RV32I**: Minimal base (what we start with)
- **RV32IM**: Base + multiplication
- **RV32IMC**: Base + mul + compressed
- **RV32GC**: General purpose (IMAFD + C)
- **RV64GC**: 64-bit general purpose

Start with **RV32I** to learn the basics!

---

## Additional Tools (Optional)

### Spike (ISA Simulator)

```bash
# Build from source
git clone https://github.com/riscv/riscv-isa-sim
cd riscv-isa-sim
mkdir build && cd build
../configure --prefix=/opt/riscv
make
sudo make install
```

### RISC-V Proxy Kernel

```bash
git clone https://github.com/riscv/riscv-pk
cd riscv-pk
mkdir build && cd build
../configure --prefix=/opt/riscv --host=riscv64-unknown-elf
make
sudo make install
```

### GDB with RISC-V Support

Most distributions include `gdb-multiarch`:
```bash
sudo apt install gdb-multiarch
```

Or build from source with RISC-V support.

---

## Next Steps

✅ Setup complete? Great! Now:

1. **Verify everything works** with the test program
2. **Start learning**: [Lesson 01 - Hello World](./lessons/01-hello-world/)
3. **Experiment** with the online simulator
4. **Read the spec**: [RISC-V ISA Spec](https://riscv.org/technical/specifications/)

---

## Quick Command Reference

```bash
# Assemble
riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 program.s -o program.o

# Link
riscv64-unknown-elf-ld program.o -o program

# Run
qemu-riscv32 ./program

# Disassemble
riscv64-unknown-elf-objdump -d program

# Debug
qemu-riscv32 -g 1234 ./program
# In another terminal:
riscv64-unknown-elf-gdb program
```

---

Need help? Check [Debugging Tips](../resources/debugging-tips.md) or open an issue!
