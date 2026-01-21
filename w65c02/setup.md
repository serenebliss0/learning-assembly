# W65C02 Development Environment Setup

This guide will help you set up your environment for W65C02 assembly programming.

## Software Setup (For All Users)

Whether you're building hardware or just learning, start with the software tools!

### Install cc65 Toolchain

cc65 includes assembler (ca65) and linker (ld65) for 6502/65C02.

#### Linux

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install cc65
```

**Fedora/RHEL:**
```bash
sudo dnf install cc65
```

**Arch:**
```bash
sudo pacman -S cc65
```

**From source (if not in repos):**
```bash
git clone https://github.com/cc65/cc65.git
cd cc65
make
sudo make install
```

#### macOS

```bash
brew install cc65
```

#### Windows

**Option 1: WSL (Recommended)**
1. Install WSL (Windows Subsystem for Linux)
2. Install Ubuntu from Microsoft Store
3. Follow Linux instructions above

**Option 2: Native Windows**
1. Download from: https://github.com/cc65/cc65/releases
2. Extract to `C:\cc65`
3. Add `C:\cc65\bin` to PATH

### Verify Installation

```bash
ca65 --version     # Should show ca65 V2.x
ld65 --version     # Should show ld65 V2.x
```

---

## Emulator Setup

Test your code before running on hardware!

### Option 1: py65mon (Recommended)

Simple and easy to use.

**Install:**
```bash
pip install py65
```

**Or with Python 3:**
```bash
pip3 install py65
```

**Test:**
```bash
py65mon
```

You should see a prompt like:
```
Py65 Monitor
py65>
```

Type `quit` to exit.

### Option 2: 6502js (Web-based)

No installation needed!

Visit: https://6502js.com

Great for quick tests and learning.

### Option 3: Other Emulators

- **sim65**: Comes with cc65 (command-line)
- **Easy6502**: https://skilldrick.github.io/easy6502/
- **Visual 6502**: http://visual6502.org (see transistors!)

---

## Test Your Setup

### Create Test Program

Create file `hello.s`:

```asm
; Hello World for 6502 emulator
; This writes to memory location $6000 which py65mon can display

.segment "CODE"
.org $8000

reset:
    LDX #$00            ; Initialize X register to 0
loop:
    LDA message,X       ; Load character from message
    BEQ done           ; If zero (end of string), we're done
    STA $6000          ; Store to output location
    INX                ; Increment X
    JMP loop           ; Continue loop

done:
    JMP done           ; Loop forever when done

message:
    .byte "Hello, World!", $00

; Reset vector
.segment "VECTORS"
.org $FFFC
.word reset            ; Reset vector points to start
.word $0000            ; NMI vector (not used)
```

### Assemble the Program

```bash
ca65 hello.s -o hello.o
ld65 -t none -o hello.bin hello.o
```

### Run in Emulator

**Using py65mon:**
```bash
py65mon -m 65c02 -r hello.bin
```

Then at the prompt:
```
py65> goto 8000
py65> step
py65> mem 6000
```

You should see the characters being written!

---

## Hardware Setup (Optional)

Want to build the actual computer? You'll need components and tools.

### Essential Components

**Microprocessor:**
- W65C02S (CMOS version recommended)
- Can buy from: Mouser, Digi-Key, or WDC direct

**Memory:**
- RAM: 62256 (32KB SRAM) or similar
- ROM: AT28C256 (32KB EEPROM) for storing programs

**Support Chips:**
- 74HC00 (NAND gates for address decoding)
- 74HC139 (decoder)
- Crystal oscillator (1-8 MHz)
- Various capacitors and resistors

**See detailed list:** [Bill of Materials](../hardware/w65c02-computer/01-bom.md)

### Tools Needed

**Essential:**
- Breadboards (several)
- Jumper wire kit
- Wire strippers
- Multimeter

**Recommended:**
- TL866 programmer (for EEPROM)
- Logic probe or LED indicators
- Decent power supply (5V, regulated)

**Advanced:**
- Oscilloscope
- Logic analyzer
- Soldering iron (for final build)

**Budget:** $100-300 depending on tools

### Getting Started with Hardware

1. **Learn the software first** - Work through lessons in emulator
2. **Read hardware guide** - [W65C02 Computer Guide](../hardware/w65c02-computer/README.md)
3. **Start minimal** - Just CPU, clock, and power
4. **Add gradually** - ROM, RAM, then peripherals
5. **Test each stage** - Don't build it all at once!

---

## Editor Setup

### VS Code (Recommended)

1. Install VS Code
2. Install extensions:
   - "6502 Assembly" by tlgkccampbell
   - "ca65 Macro Assembler" by tlgkccampbell

### Vim

Add to `~/.vimrc`:
```vim
au BufRead,BufNewFile *.s set filetype=asm6502
```

### Other Options

- Sublime Text with 6502 plugin
- Atom with language-65asm

---

## Directory Structure

Organize your projects like this:

```
my-6502-project/
├── src/
│   └── main.s          # Your assembly code
├── build/
│   ├── main.o          # Object file
│   └── program.bin     # Final binary
├── Makefile            # Build automation
└── README.md           # Project notes
```

### Simple Makefile

Create `Makefile`:

```makefile
# Makefile for W65C02 projects

SRC = src/main.s
OBJ = build/main.o
BIN = build/program.bin

all: $(BIN)

$(OBJ): $(SRC)
	mkdir -p build
	ca65 $(SRC) -o $(OBJ)

$(BIN): $(OBJ)
	ld65 -t none -o $(BIN) $(OBJ)

clean:
	rm -rf build

run: $(BIN)
	py65mon -m 65c02 -r $(BIN)

.PHONY: all clean run
```

Usage:
```bash
make        # Build
make run    # Build and run in emulator
make clean  # Clean build files
```

---

## Common Issues

### "ca65: command not found"

cc65 not installed or not in PATH.

**Fix:**
```bash
which ca65           # Check if installed
# If not found, install cc65
```

### "py65mon: command not found"

py65 not installed.

**Fix:**
```bash
pip3 install py65
# or
python3 -m pip install py65
```

### Emulator won't load binary

Check file size and format:
```bash
ls -lh program.bin
hexdump -C program.bin | head
```

Binary should be valid 6502 code.

### Assembler errors

Common issues:
- Missing `.segment` directives
- Wrong syntax (ca65 uses different syntax than some 6502 assemblers)
- Check line numbers in error messages

---

## Learning Resources

### Datasheets

- [W65C02S Datasheet](http://www.westerndesigncenter.com/wdc/documentation/w65c02s.pdf) (If link breaks, search "W65C02S datasheet")
- [65C22 VIA Datasheet](http://www.westerndesigncenter.com/wdc/documentation/w65c22.pdf) (If link breaks, search "65C22 datasheet")

### Tutorials

- Ben Eater's 6502 series: https://eater.net/6502
- 6502.org tutorials
- Easy 6502: https://skilldrick.github.io/easy6502/

### References

- Programming the 65816 (book)
- 6502 instruction reference: http://www.6502.org/tutorials/6502opcodes.html

---

## Next Steps

✅ Setup complete? Great! Now:

1. **Test with example program** above
2. **Start learning**: [Lesson 01 - Hello World](./lessons/01-hello-world/)
3. **Experiment in emulator** before building hardware
4. **Read datasheets** - Understanding the chip is important

---

## Quick Command Reference

```bash
# Assemble
ca65 program.s -o program.o

# Link
ld65 -t none -o program.bin program.o

# Run in emulator
py65mon -m 65c02 -r program.bin

# Disassemble (if da65 available)
da65 program.bin

# Hex dump
hexdump -C program.bin
```

---

Need help? Check [Debugging Tips](../resources/debugging-tips.md) or open an issue!
