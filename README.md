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

### 🖥️ Path 1: x86 Assembly (Modern PC Architecture)
Perfect for understanding modern computers, operating systems, and desktop applications.

**[Start Here: x86 Learning Path →](./x86/README.md)**

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
├── x86/                    # x86 Assembly (Modern PC)
│   ├── lessons/            # Step-by-step lessons
│   ├── examples/           # Code examples
│   └── projects/           # Hands-on projects
├── w65c02/                 # W65C02 Assembly (DIY Computer)
│   ├── lessons/            # Step-by-step lessons
│   ├── examples/           # Code examples
│   └── projects/           # Hands-on projects
├── hardware/               # Hardware guides & schematics
│   ├── w65c02-computer/    # Building a W65C02 computer
│   ├── pc-architecture/    # Understanding x86 PCs
│   └── components/         # Component guides
└── resources/              # References, tools, links
```

## 🎯 Recommended Learning Order

### For Complete Beginners:
1. Read [What is Assembly?](./resources/what-is-assembly.md)
2. Choose your path:
   - **Want to build a simple computer?** → Start with W65C02
   - **Want to understand modern PCs?** → Start with x86
3. Follow the lessons in order
4. Try the examples and projects
5. Explore the hardware guides

### If You Want to Build Hardware:
1. Start with W65C02 path (simpler to understand)
2. Read the [W65C02 Computer Building Guide](./hardware/w65c02-computer/README.md)
3. Work through W65C02 lessons alongside building
4. Once comfortable, explore x86 for modern systems

## 🔧 Tools You'll Need

### For x86 Assembly:
- **Linux**: NASM (assembler), ld (linker), gdb (debugger)
- **Windows**: NASM, MASM, or Visual Studio
- **macOS**: NASM with Xcode tools

### For W65C02 Assembly:
- cc65 toolchain (assembler for 6502/65C02)
- Emulator: py65mon or 6502js
- For hardware: W65C02 chip, breadboard, components (see hardware guide)

### Installation Guides:
- [Setting up x86 Development Environment](./x86/setup.md)
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

1. **Pick your path**: W65C02 (for hardware) or x86 (for modern PCs)
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
- [x86 Assembly Path →](./x86/README.md)
- [W65C02 Assembly Path →](./w65c02/README.md)
- [Hardware Building Guide →](./hardware/README.md)

*Remember: Every expert was once a beginner. Let's learn assembly together!* 🚀
