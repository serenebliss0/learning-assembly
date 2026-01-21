# 🎓 Learning Assembly - A Complete Hardware + Software Guide

Welcome to your journey into the world of Assembly language and computer hardware! This repository is designed to guide you from complete beginner to building your own computer.

## 🚀 Why Learn Assembly?

Assembly language is the bridge between high-level programming and the raw hardware. By learning assembly, you'll:
- Understand how computers really work at the lowest level
- Write incredibly fast and efficient code
- Debug and reverse engineer software
- Build your own operating systems or embedded systems
- Have the foundation to build your own computer from scratch!

Don't worry if it seems scary - we'll take it step by step, just like we did with Arduino!

## 📚 Learning Paths

This repository covers TWO assembly languages:

### 🖥️ Path 1: RISC-V Assembly (Modern Open Architecture)
Perfect for understanding modern computer architecture with a clean, simple instruction set. RISC-V is open-source and increasingly popular in embedded systems and education.

**[Start Here: RISC-V Learning Path →](./riscv/README.md)**

### 🔧 Path 2: W65C02 Assembly (Simple Computer Building)
Based on the classic 6502 processor - ideal for building your own simple computer from scratch!

**[Start Here: W65C02 Learning Path →](./w65c02/README.md)**

## 🛠️ Hardware Guide

Want to build your own computer? Check out our comprehensive hardware guides!

**[Hardware Guides →](./hardware/README.md)**

Includes:
- Components you need to build a computer
- How CPUs, RAM, and buses work
- Building a W65C02-based computer (Ben Eater style)
- Understanding PC architecture (x86)
- Tools you'll need

## 📖 Repository Structure

```
learning-assembly/
├── riscv/                  # RISC-V Assembly (Modern Open Architecture)
│   ├── lessons/            # Step-by-step lessons
│   ├── examples/           # Code examples
│   └── projects/           # Hands-on projects
├── w65c02/                 # W65C02 Assembly (DIY Computer)
│   ├── lessons/            # Step-by-step lessons
│   ├── examples/           # Code examples
│   └── projects/           # Hands-on projects
├── hardware/               # Hardware guides & schematics
│   ├── w65c02-computer/    # Building a W65C02 computer
│   ├── riscv-boards/       # RISC-V development boards
│   └── components/         # Component guides
└── resources/              # References, tools, links
```

## 🎯 Recommended Learning Order

### For Complete Beginners:
1. Read [What is Assembly?](./resources/what-is-assembly.md)
2. Choose your path:
   - **Want to build a simple computer?** → Start with W65C02
   - **Want modern, clean architecture?** → Start with RISC-V
3. Follow the lessons in order
4. Try the examples and projects
5. Explore the hardware guides

### If You Want to Build Hardware:
1. Start with W65C02 path (simpler to understand)
2. Read the [W65C02 Computer Building Guide](./hardware/w65c02-computer/README.md)
3. Work through W65C02 lessons alongside building
4. Once comfortable, explore RISC-V for modern open-source systems

## 🔧 Tools You'll Need

### For RISC-V Assembly:
- RISC-V GNU toolchain (assembler, linker, debugger)
- QEMU or Spike (RISC-V emulator)
- Optional: RISC-V development board (HiFive1, Sipeed, etc.)

### For W65C02 Assembly:
- cc65 toolchain (assembler for 6502/65C02)
- Emulator: py65mon or 6502js
- For hardware: W65C02 chip, breadboard, components (see hardware guide)

### Installation Guides:
- [Setting up RISC-V Development Environment](./riscv/setup.md)
- [Setting up W65C02 Development Environment](./w65c02/setup.md)

## 📝 How to Use This Repository

Just like your Arduino practice repository, each lesson includes:
1. **📘 Explanation**: What you're learning and why
2. **💻 Code**: Complete, working examples
3. **🔍 Deep Dive**: How it works under the hood
4. **✏️ Exercises**: Hands-on practice problems
5. **🎯 Projects**: Apply what you learned

Work through lessons sequentially - each builds on the previous ones!

## 🌟 Getting Started

1. **Pick your path**: W65C02 (for DIY hardware) or RISC-V (for modern open architecture)
2. **Set up your environment**: Follow the setup guide
3. **Start with Lesson 1**: Follow along, type the code, experiment!
4. **Build projects**: Apply what you learn
5. **Ask questions**: Use GitHub Issues if you get stuck

## 📚 Additional Resources

- [Glossary of Terms](./resources/glossary.md)
- [Debugging Tips](./resources/debugging-tips.md)
- [Common Mistakes](./resources/common-mistakes.md)
- [Further Reading](./resources/further-reading.md)

## 🎓 Learning Philosophy

> "Assembly isn't scary - it's just unfamiliar. Take it one instruction at a time!"

This repository follows a hands-on, guided approach:
- Start simple, build complexity gradually
- Lots of examples and explanations
- Practical projects you can actually run
- Hardware and software together

## 🤝 Contributing

Found a typo? Have a cool example? Suggestions for improvement? Open an issue or PR!

## 📜 License

This repository is for educational purposes. Code examples are free to use and modify.

---

**Ready to start?** Choose your adventure:
- [RISC-V Assembly Path →](./riscv/README.md)
- [W65C02 Assembly Path →](./w65c02/README.md)
- [Hardware Building Guide →](./hardware/README.md)

*Remember: Every expert was once a beginner. Let's learn assembly together!* 🚀
