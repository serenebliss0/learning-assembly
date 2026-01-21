# x86 Development Environment Setup

This guide will help you set up your environment for x86 assembly programming.

## Choose Your Operating System

- [Linux Setup](#linux-setup) (Recommended for beginners)
- [Windows Setup](#windows-setup)
- [macOS Setup](#macos-setup)

---

## Linux Setup

Linux is the easiest platform for learning x86 assembly!

### Install Required Tools

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install nasm gdb build-essential
```

**Fedora/RHEL:**
```bash
sudo dnf install nasm gdb gcc
```

**Arch:**
```bash
sudo pacman -S nasm gdb gcc
```

### Verify Installation

```bash
nasm -version      # Should show NASM version
ld --version       # Should show GNU ld version
gdb --version      # Should show GDB version
```

### Test Your Setup

Create a test file `hello.asm`:

```asm
section .data
    msg db 'Hello, World!', 10
    len equ $ - msg

section .text
    global _start

_start:
    ; Write message
    mov rax, 1          ; sys_write (64-bit)
    mov rdi, 1          ; stdout
    mov rsi, msg        ; message
    mov rdx, len        ; length
    syscall

    ; Exit
    mov rax, 60         ; sys_exit (64-bit)
    xor rdi, rdi        ; exit code 0
    syscall
```

Assemble and run:
```bash
nasm -f elf64 hello.asm
ld hello.o -o hello
./hello
```

Should print: `Hello, World!`

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

### Option 2: Native Windows with NASM

1. **Download NASM:**
   - Visit: https://www.nasm.us/
   - Download Windows installer
   - Install to default location
   - Add to PATH

2. **Install Visual Studio:**
   - Download Visual Studio Community (free)
   - Install "Desktop development with C++"
   - This gives you the linker (link.exe)

3. **Test setup:**

Create `hello.asm`:
```asm
section .data
    msg db 'Hello, World!', 13, 10, 0

section .text
    global main
    extern printf
    extern exit

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    lea rcx, [msg]
    call printf

    xor ecx, ecx
    call exit
```

Compile:
```cmd
nasm -f win64 hello.asm
link hello.obj /subsystem:console /entry:main /defaultlib:msvcrt.lib /out:hello.exe
hello.exe
```

### Option 3: MSYS2/MinGW

1. Download MSYS2: https://www.msys2.org/
2. Install and update: `pacman -Syu`
3. Install tools: `pacman -S nasm gcc gdb`
4. Use MSYS2 terminal for assembly work

---

## macOS Setup

### Install Homebrew (if not already installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Install NASM

```bash
brew install nasm
```

### Install Xcode Command Line Tools

```bash
xcode-select --install
```

### Important macOS Note

macOS requires special considerations:
- System calls are different
- Stack must be 16-byte aligned
- No direct syscall - use LibC or macOS syscalls

### Test Setup

Create `hello.asm`:
```asm
global _main
extern _printf

section .data
    msg db "Hello, World!", 10, 0

section .text
_main:
    push rbp
    mov rbp, rsp
    
    lea rdi, [rel msg]
    call _printf
    
    xor rax, rax
    leave
    ret
```

Assemble and run:
```bash
nasm -f macho64 hello.asm
ld hello.o -o hello -lSystem -L /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib
./hello
```

---

## Editor Setup

Choose a text editor with syntax highlighting:

### VS Code (Recommended)

1. Install VS Code: https://code.visualstudio.com/
2. Install extensions:
   - "x86 and x86_64 Assembly" by 13xforever
   - "ASM Code Lens" by maziac

### Vim

Add to `~/.vimrc`:
```vim
syntax on
filetype plugin indent on
au BufRead,BufNewFile *.asm set filetype=nasm
```

### Other Options

- Sublime Text with asm plugin
- Atom with language-x86-64-assembly
- Notepad++ with NASM syntax highlighting

---

## Common Issues

### "nasm: command not found"

**Linux:** NASM not installed or not in PATH
```bash
which nasm    # Check if installed
sudo apt install nasm  # Install if needed
```

**Windows:** Add NASM to PATH environment variable

**macOS:** 
```bash
brew install nasm
```

### "Permission denied" when running

Make file executable:
```bash
chmod +x ./hello
./hello
```

### "Undefined symbol" errors

**Linux:** Check you're using correct syscall numbers for 64-bit
**macOS:** External symbols need underscore prefix (`_printf` not `printf`)

### Linker errors

**Linux:** Check object file format matches system (elf64 for 64-bit)
**Windows:** Make sure Visual Studio is installed for linker
**macOS:** Specify SDK path in ld command

---

## Next Steps

✅ Setup complete? Great! Now:

1. **Verify everything works** with the test program
2. **Start learning**: [Lesson 01 - Hello World](./lessons/01-hello-world/)
3. **Bookmark references**: Keep instruction reference handy
4. **Join community**: Open issues if you get stuck

---

## Additional Tools (Optional)

### Disassembler
```bash
# Linux/macOS
objdump -d -M intel program

# Windows
dumpbin /disasm program.exe
```

### Hex Editor
- Linux: `hexedit`, `bless`
- Windows: HxD
- macOS: Hex Fiend

### Debugger GUI
- GDB with GEF: https://github.com/hugsy/gef
- EDB Debugger (Linux)
- x64dbg (Windows)

---

Need help? Check [Debugging Tips](../resources/debugging-tips.md) or open an issue!
