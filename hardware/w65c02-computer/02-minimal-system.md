# Stage 1: Minimal System - Getting the CPU Running

## 🎯 Goal

Build the absolute minimum circuit to prove your W65C02 CPU is alive and executing instructions. By the end of this stage, you'll have:
- A working CPU powered and clocked
- A simple manual clock circuit (push button)
- An LED connected to show CPU activity
- Confidence that your CPU and basic wiring are correct

**Time Required:** 2-3 hours  
**Difficulty:** Beginner

---

## 📋 What You'll Need

From your Bill of Materials:
- [ ] W65C02S CPU chip (DIP-40)
- [ ] Large breadboard (830 tie-points)
- [ ] Breadboard power supply (MB102) OR 5V USB power
- [ ] 1x Red LED (5mm)
- [ ] 1x Green LED (5mm) 
- [ ] 2x 220Ω resistors (red-red-brown)
- [ ] 6x 10kΩ resistors (brown-black-orange)
- [ ] 1x Tactile push button (momentary)
- [ ] 1x 0.1μF ceramic capacitor (104)
- [ ] 40-pin DIP IC socket (recommended)
- [ ] Jumper wires (various lengths)
- [ ] Multimeter

---

## 🧠 Theory: What We're Building

The W65C02 is a microprocessor - it needs several things to operate:
1. **Power** - Stable 5V on VDD pins, 0V on VSS (ground)
2. **Clock** - A timing signal that tells it when to execute instructions
3. **Reset** - A signal to initialize the CPU
4. **Instructions** - Code to execute (we'll wire this manually at first)

In this minimal system, we're going to:
- Provide power and ground
- Use a **push button as a manual clock** (you control speed!)
- Hold the data bus at `$EA` (the NOP instruction - "No Operation")
- Watch an LED blink in sync with the address bus

**Why NOP?** The NOP instruction does nothing except increment the program counter. When you press the clock button, the CPU will:
1. Read $EA from the data bus
2. Execute NOP (do nothing)
3. Increment the address on the address bus
4. Wait for next clock pulse

By watching the address bus LEDs, you'll see the CPU counting through memory addresses!

---

## 🔌 W65C02S Pinout Reference

The W65C02S is a 40-pin DIP package. Here's the pinout (looking at the chip from above, notch at top):

```
           W65C02S
         +---\/---+
    VP  1|        |40  RES (Reset)
  RDY   2|        |39  Φ2O (Clock Out)
  Φ1O   3|        |38  SO (Set Overflow)
  IRQ   4|        |37  Φ2 (Clock In)
   NC   5|        |36  NC
  NMI   6|        |35  NC
 SYNC   7|        |34  R/W (Read/Write)
  VDD   8|        |33  D0 (Data Bus)
   A0   9|        |32  D1
   A1  10|        |31  D2
   A2  11|        |30  D3
   A3  12|        |29  D4
   A4  13|        |28  D5
   A5  14|        |27  D6
   A6  15|        |26  D7
   A7  16|        |25  A15 (Address)
   A8  17|        |24  A14
   A9  18|        |23  A13
  A10  19|        |22  A12
  A11  20|        |21  VSS (Ground)
         +--------+
```

**Key Pins for This Stage:**
- **Pin 8 (VDD)** - +5V power
- **Pin 21 (VSS)** - Ground
- **Pin 37 (Φ2)** - Clock input (our push button)
- **Pin 40 (RES)** - Reset (must be HIGH for normal operation)
- **Pins 9-25 (A0-A15)** - 16-bit address bus
- **Pins 26-33 (D0-D7)** - 8-bit data bus

---

## 🔧 Step-by-Step Build Instructions

### Step 1: Prepare Your Workspace

1. **Clear a large, clean workspace** - You'll need room for breadboards and tools
2. **Organize your components** - Put resistors, LEDs, and wire in easy reach
3. **Test your power supply:**
   - Connect MB102 to breadboard
   - Set jumpers to 5V (both rails)
   - Connect USB or 9V adapter
   - **Use multimeter** - Verify 5V between power rail and ground
   - If not 5V, stop and troubleshoot power supply first

**Why This Matters:** Bad power is the #1 cause of circuit failures. Always verify power before adding ICs!

### Step 2: Install the CPU Socket

If using an IC socket (recommended):

1. **Find the notch** - One end of the socket has a notch or dot (marks pin 1)
2. **Position on breadboard:**
   - Place socket so it **straddles the center gap** of breadboard
   - Orient notch toward the top
   - Use rows 20-39 (leaves room for connections)
3. **Press firmly** - All pins must be fully inserted
4. **Verify:** All 40 pins should be in breadboard holes

**If NOT using a socket:** Be extra careful inserting the CPU. Bend pins gently if needed to align them, never force.

### Step 3: Power Connections

**Critical:** The W65C02S has FOUR power pins (two VDD, two VSS). You MUST connect them all!

1. **Connect VDD (pin 8):**
   ```
   CPU pin 8 → Red wire → +5V power rail (red row on breadboard)
   ```

2. **Connect VSS (pin 21):**
   ```
   CPU pin 21 → Black wire → Ground rail (blue/black row on breadboard)
   ```

3. **Add decoupling capacitor:**
   ```
   0.1μF capacitor: One leg to pin 8, other leg to pin 21
   ```
   Place capacitor as close as possible to the CPU pins!

4. **Verify with multimeter:**
   - Touch red probe to pin 8, black probe to pin 21
   - Should read 5.0V (±0.25V)
   - If wrong, STOP and check your power supply

**ASCII Diagram - Power Connections:**
```
        +5V Rail ────────────────┐
                                │ Red wire
                            [CPU Pin 8 VDD]
                                │
                            [0.1μF Cap]
                                │
                            [CPU Pin 21 VSS]
                                │ Black wire
        GND Rail ────────────────┘
```

---

### Step 4: Reset Circuit

The RESET pin (pin 40) must be:
- Pulled HIGH for normal operation
- Pulled LOW to reset the CPU
- Must be HIGH before first clock pulse

**Wiring:**

1. **Connect pull-up resistor:**
   ```
   10kΩ resistor: Pin 40 (RES) → +5V power rail
   ```

2. **Optional - Add reset button:**
   ```
   Push button: One side to pin 40, other side to ground
   Adds 10kΩ resistor in series with button if you want to be safe
   ```

**Why 10kΩ?** It's strong enough to pull the pin HIGH, but weak enough that pressing the button can pull it LOW without excessive current.

**How Reset Works:**
- Resistor pulls RES to +5V (HIGH) = CPU runs normally
- Pressing button connects RES to ground (LOW) = CPU resets
- Releasing button, RES goes HIGH again = CPU starts from reset vector

**Test:** 
- Measure voltage at pin 40 (should be ~5V)
- Press reset button while measuring (should drop to ~0V)

---

### Step 5: Input Signal Pull-ups

The W65C02 has several input pins that should not be left floating:

**Connect these pins to +5V via 10kΩ resistors:**

| Pin | Signal | Purpose | Connection |
|-----|--------|---------|------------|
| 2 | RDY | Ready | 10kΩ → +5V |
| 4 | IRQ | Interrupt Request | 10kΩ → +5V |
| 6 | NMI | Non-Maskable Interrupt | 10kΩ → +5V |
| 38 | SO | Set Overflow | 10kΩ → +5V |

**Why Pull-ups?**
- These are active-LOW inputs (LOW = active, HIGH = inactive)
- Floating inputs can trigger spurious interrupts
- 10kΩ resistors keep them safely HIGH when not in use

**Wiring Each One:**
```
CPU Pin → 10kΩ resistor → +5V rail
```

---

### Step 6: Data Bus - Feed NOP Instructions

We need to make the CPU think it's reading program memory. We'll wire the data bus to constantly present the NOP instruction ($EA = 11101010 in binary).

**Data Bus Pins (D0-D7):**
- D0 = Pin 33
- D1 = Pin 32
- D2 = Pin 31
- D3 = Pin 30
- D4 = Pin 29
- D5 = Pin 28
- D6 = Pin 27
- D7 = Pin 26

**NOP Instruction = $EA = Binary 11101010**

This means: D7 D6 D5 D4 D3 D2 D1 D0 = 1 1 1 0 1 0 1 0

**Connect each data pin accordingly:**

| Data Pin | Bit Value | Connection |
|----------|-----------|------------|
| D0 (33) | 0 | Connect to Ground |
| D1 (32) | 1 | Connect to +5V via 10kΩ |
| D2 (31) | 0 | Connect to Ground |
| D3 (30) | 1 | Connect to +5V via 10kΩ |
| D4 (29) | 0 | Connect to Ground |
| D5 (28) | 1 | Connect to +5V via 10kΩ |
| D6 (27) | 1 | Connect to +5V via 10kΩ |
| D7 (26) | 1 | Connect to +5V via 10kΩ |

**Quick Version (using resistor network):**
- D1, D3, D5, D6, D7 → 10kΩ each → +5V
- D0, D2, D4 → Direct to Ground

**Why Pull-ups for '1' bits?** This way the CPU sees the data without the data fighting against internal circuits.

---

### Step 7: Manual Clock Circuit

Instead of a complex oscillator, we'll use a push button to manually clock the CPU. Each button press = one clock cycle. This lets you single-step through execution!

**Parts Needed:**
- 1x tactile push button
- 1x 10kΩ resistor
- 1x green LED
- 1x 220Ω resistor

**Wiring the Clock:**

1. **Connect clock pull-down:**
   ```
   Pin 37 (Φ2 Clock) → 10kΩ resistor → Ground
   ```
   This keeps the clock LOW when button not pressed.

2. **Connect clock button:**
   ```
   +5V rail → Push button → Pin 37 (Φ2)
   ```
   When pressed, connects pin 37 to +5V (clock pulse)

3. **Add clock indicator LED:**
   ```
   +5V rail → 220Ω resistor → Green LED (anode) → LED cathode → Ground
   Tap into the wire going to Pin 37 before the button
   ```
   Or simpler: Parallel to clock line after button
   ```
   Pin 37 → 220Ω → Green LED → Ground
   ```

**ASCII Diagram - Clock Circuit:**
```
+5V ────┬──────────────┐
        │              │
    [Button]       [220Ω]
        │              │
        └─────┬────[Green LED]+─── (Cathode)
              │        │
          [Pin 37]     └────── GND
              │
           [10kΩ]
              │
        ──────┴────── GND
```

**How It Works:**
- Resistor holds clock at 0V (LOW)
- Press button → Clock goes to 5V (HIGH) → CPU executes one cycle
- Release button → Clock back to LOW → CPU waits
- LED lights up when clock is HIGH

---

### Step 8: Address Bus LED Monitor

Let's watch the CPU count! We'll attach an LED to one of the address lines.

**Connect LED to A0 (pin 9) - the lowest address bit:**

```
Pin 9 (A0) → 220Ω resistor → Red LED (anode) → LED cathode → Ground
```

**Why A0?** It toggles on every address increment:
- Address $0000 → A0 = 0 (LED off)
- Address $0001 → A0 = 1 (LED on)
- Address $0002 → A0 = 0 (LED off)
- Address $0003 → A0 = 1 (LED on)

So the LED blinks on/off as you clock the CPU!

**Want More Feedback?** Add LEDs to more address lines:
- A0: Blinks every cycle
- A1: Blinks every 2 cycles
- A2: Blinks every 4 cycles
- And so on...

---

### Step 9: Final Circuit Check

Before powering on, verify every connection:

**Power Check:**
- [ ] Pin 8 → +5V
- [ ] Pin 21 → Ground
- [ ] 0.1μF capacitor across pins 8 and 21
- [ ] All power rails connected to supply

**Reset Check:**
- [ ] Pin 40 → 10kΩ → +5V
- [ ] Optional reset button to ground

**Input Pull-ups:**
- [ ] Pin 2 (RDY) → 10kΩ → +5V
- [ ] Pin 4 (IRQ) → 10kΩ → +5V
- [ ] Pin 6 (NMI) → 10kΩ → +5V
- [ ] Pin 38 (SO) → 10kΩ → +5V

**Data Bus ($EA = NOP):**
- [ ] D0 (pin 33) → Ground
- [ ] D1 (pin 32) → 10kΩ → +5V
- [ ] D2 (pin 31) → Ground
- [ ] D3 (pin 30) → 10kΩ → +5V
- [ ] D4 (pin 29) → Ground
- [ ] D5 (pin 28) → 10kΩ → +5V
- [ ] D6 (pin 27) → 10kΩ → +5V
- [ ] D7 (pin 26) → 10kΩ → +5V

**Clock Circuit:**
- [ ] Pin 37 (Φ2) → 10kΩ → Ground
- [ ] Pin 37 → Button → +5V
- [ ] Green LED on clock line

**Address Monitor:**
- [ ] Pin 9 (A0) → 220Ω → Red LED → Ground

---

## ⚡ Power-On and Testing!

### Test Procedure

1. **Triple-check all connections** - Look for shorts or mis-wiring

2. **Insert CPU into socket** (if using socket):
   - Match pin 1 (notch) of CPU to notch on socket
   - Press down GENTLY but firmly
   - Verify all pins inserted correctly

3. **Apply power:**
   - Connect USB or plug in adapter
   - Green power LED on MB102 should light up

4. **Check power at CPU:**
   - Multimeter: Pin 8 to pin 21 should read 5V
   - If not, turn OFF power immediately and troubleshoot

5. **Press reset button** (if you added one):
   - Hold for 1 second, then release
   - This initializes the CPU

6. **Press clock button:**
   - Green LED should light up while pressed
   - Red LED (on A0) should toggle between presses
   - If red LED changes state each press = SUCCESS! 🎉

### What You Should See

**With each clock button press:**
- ✅ Green LED lights (clock is HIGH)
- ✅ Red LED toggles on/off (address incrementing)
- ✅ Pattern: ON, OFF, ON, OFF, ON, OFF...

**If working correctly:**
Your CPU is executing NOP instructions and incrementing through memory addresses! The address bus is counting: $0000, $0001, $0002, $0003...

---

## 🔍 Troubleshooting

### Problem: Nothing happens when pressing clock button

**Check:**
1. **Power first:**
   - Measure voltage at CPU pin 8 → should be 5V
   - Measure voltage at CPU pin 21 → should be 0V
   
2. **Clock signal:**
   - Measure pin 37 with button NOT pressed → should be 0V
   - Measure pin 37 with button PRESSED → should be 5V
   - Check green LED - does it light when button pressed?

3. **Reset:**
   - Measure pin 40 → should be ~5V
   - Try holding reset button for 2 seconds, release, then try clock

### Problem: Red LED doesn't change

**Check:**
1. **LED orientation:**
   - Long leg (anode) toward resistor (connected to pin 9)
   - Short leg (cathode) toward ground
   - Try flipping LED around

2. **LED circuit:**
   - Measure voltage at pin 9 → should toggle between ~0V and ~5V
   - If stuck at one voltage, data bus may be wired wrong

3. **Data bus:**
   - Verify $EA on data bus (see step 6 connections)
   - One wrong bit and CPU may be executing wrong instruction

### Problem: Clock button doesn't work smoothly

**This is normal!** Mechanical buttons "bounce" - they make and break contact rapidly. You might see multiple clock pulses per press.

**Solutions:**
- Press button slowly and deliberately
- Add a debounce circuit (0.1μF capacitor across button)
- We'll fix this with a proper clock in the next stage

### Problem: Red LED stays dim or blinks erratically

**Possible causes:**
1. **Missing decoupling capacitor** - Add 0.1μF across pins 8 and 21
2. **Poor power supply** - Check voltage, should be stable 5V
3. **Floating inputs** - Verify all pull-up resistors are connected
4. **Bad breadboard connections** - Try different breadboard holes

### Problem: CPU gets hot

**This is BAD - turn off power immediately!**

**Likely causes:**
1. **CPU inserted backwards** - Pin 1 must align with socket notch
2. **Short circuit** - Check for wires touching or crossed
3. **Wrong voltage** - Should be 5V, not higher
4. **Damaged CPU** - Might need replacement

---

## 📊 Understanding What's Happening

### The Fetch-Execute Cycle

Your CPU is continuously executing this cycle:

1. **Fetch:** CPU puts address on address bus (A0-A15)
2. **Read:** CPU reads data from data bus (D0-D7)
3. **Decode:** CPU determines instruction ($EA = NOP)
4. **Execute:** CPU performs instruction (NOP = do nothing)
5. **Increment:** Program counter advances to next address
6. **Repeat:** Wait for next clock pulse

**With our circuit:**
- CPU always reads $EA (NOP) from data bus
- Each clock pulse, CPU executes NOP and increments address
- Address bus counts: 0000, 0001, 0002, 0003...
- LED on A0 shows the least significant bit changing

### Why This Proves the CPU Works

If you can see the address bus counting, you've proven:
- ✅ CPU has proper power
- ✅ Clock signal works
- ✅ Reset circuit works
- ✅ CPU is executing instructions
- ✅ Address bus is functioning
- ✅ Data bus is being read correctly

This is a MAJOR milestone! Your CPU is alive and working.

---

## 🎓 Educational Experiments

Now that you have a working CPU, try these experiments:

### Experiment 1: Watch More Address Lines

Add LEDs to A1, A2, A3:
```
Pin 10 (A1) → 220Ω → LED → Ground
Pin 11 (A2) → 220Ω → LED → Ground
Pin 12 (A3) → 220Ω → LED → Ground
```

Clock the CPU and watch the binary counter pattern:
```
Clock  A3 A2 A1 A0
  0    0  0  0  0
  1    0  0  0  1
  2    0  0  1  0
  3    0  0  1  1
  4    0  1  0  0
  5    0  1  0  1
  ...
```

This is binary counting in hardware!

### Experiment 2: Different Instructions

Change the data bus to execute different instructions:

**BRK instruction ($00 = Break):**
- All data pins to Ground
- CPU will try to jump to IRQ vector
- Won't work fully yet (no memory), but different than NOP

**Try:** Wire data bus to $00 and see if behavior changes.

### Experiment 3: Measure Clock Speed

With a stopwatch:
1. Count 100 button presses
2. Measure time in seconds
3. Calculate: Hz = 100 / time

Your "manual clock" is probably 1-2 Hz (presses per second). The CPU can run at several MHz!

---

## 📸 Expected Results - What You Built

**You now have:**
- A W65C02S CPU powered and running
- Manual clock control (push button)
- Visual feedback (LEDs showing activity)
- A test bench for learning CPU operations

**Physical appearance:**
- CPU chip in center of breadboard
- Nest of wires connecting to power rails
- Two LEDs (green for clock, red for address bus)
- Push button for manual clock
- Decoupling capacitor near CPU

**Skills gained:**
- IC power connections and decoupling
- Pull-up and pull-down resistors
- Understanding of CPU signals (clock, reset, data, address)
- Basic troubleshooting with multimeter

---

## ✅ Success Criteria

You've successfully completed Stage 1 if:
- ✅ CPU doesn't get hot (no short circuits)
- ✅ Clock LED lights when button pressed
- ✅ Address LED toggles with each clock press
- ✅ Pattern is consistent and predictable
- ✅ No smoke or burning smells! 😊

---

## 🎯 Next Steps

Your CPU is working, but it's not very useful yet. It's just counting through addresses and executing NOP instructions.

**In Stage 2 (Add Memory), you'll learn to:**
- Add RAM (read/write memory)
- Add ROM (program storage)
- Build an address decoder (select RAM vs ROM)
- Program the ROM with real code
- Run actual assembly programs!

**Before moving on:**
- Take photos of your working circuit
- Document any troubleshooting you did
- Make sure you understand how each connection works
- Celebrate your success! 🎉

**When ready:** Proceed to **03-add-memory.md**

---

## 📝 Quick Reference Card

### Pin Summary
```
Power:          Pin 8 (VDD) → +5V,  Pin 21 (VSS) → GND
Clock:          Pin 37 (Φ2) → Button circuit
Reset:          Pin 40 (RES) → 10kΩ → +5V
Interrupts:     Pins 2,4,6,38 → 10kΩ → +5V
Data Bus:       Pins 26-33 → Wired to $EA (NOP)
Address Bus:    Pin 9 (A0) → LED monitor
```

### Quick Troubleshooting
1. No activity → Check power (should be 5V)
2. LED doesn't toggle → Check data bus ($EA)
3. Erratic behavior → Add/check decoupling capacitor
4. CPU hot → POWER OFF! Check for shorts

---

*Stage 1 Complete! Ready for Stage 2: Add Memory* 🚀
