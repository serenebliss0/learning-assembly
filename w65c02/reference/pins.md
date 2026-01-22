# W65C02S Pinout Reference

Complete pinout and pin function reference for the W65C02S microprocessor (40-pin DIP).

## Pinout Diagram

```
                    W65C02S
                  ┌───────┐
        VP  ─────┤1    40├───── RES̅
        RDY ─────┤2    39├───── PHI2 (Clock)
        PHI1O ───┤3    38├───── SOB
        IRQ̅ ─────┤4    37├───── PHI2O
        MLB ─────┤5    36├───── NC
        NMI̅ ─────┤6    35├───── NC
        SYNC ────┤7    34├───── R/W̅
        VDD ─────┤8    33├───── D0
        A0 ──────┤9    32├───── D1
        A1 ──────┤10   31├───── D2
        A2 ──────┤11   30├───── D3
        A3 ──────┤12   29├───── D4
        A4 ──────┤13   28├───── D5
        A5 ──────┤14   27├───── D6
        A6 ──────┤15   26├───── D7
        A7 ──────┤16   25├───── A15
        A8 ──────┤17   24├───── A14
        A9 ──────┤18   23├───── A13
        A10 ─────┤19   22├───── A12
        A11 ─────┤20   21├───── VSS
                  └───────┘

Pin 1 (VP) = Top-left when notch/dot is at top
```

---

## Pin Overview Table

| Pin | Name | Type | Function |
|-----|------|------|----------|
| 1 | VP | I | Vector Pull (active low) |
| 2 | RDY | I | Ready (wait state control) |
| 3 | PHI1O | O | Phase 1 Clock Out |
| 4 | IRQ̅ | I | Interrupt Request (active low) |
| 5 | MLB | O | Memory Lock for Bus |
| 6 | NMI̅ | I | Non-Maskable Interrupt (active low) |
| 7 | SYNC | O | Opcode Fetch Sync |
| 8 | VDD | PWR | Power (+5V typical) |
| 9-16 | A0-A7 | O | Address Bus (low byte) |
| 17-20 | A8-A11 | O | Address Bus (mid) |
| 21 | VSS | PWR | Ground (0V) |
| 22-25 | A12-A15 | O | Address Bus (high byte) |
| 26-33 | D7-D0 | I/O | Data Bus (bidirectional) |
| 34 | R/W̅ | O | Read/Write (high=read, low=write) |
| 35-36 | NC | - | No Connect (reserved) |
| 37 | PHI2O | O | Phase 2 Clock Out |
| 38 | SOB | I | Set Overflow Bit |
| 39 | PHI2 | I | Phase 2 Clock In (main clock) |
| 40 | RES̅ | I | Reset (active low) |

**Legend:** I=Input, O=Output, I/O=Bidirectional, PWR=Power

---

## Detailed Pin Descriptions

### Power Pins

#### Pin 8: VDD (Power Supply)
**Type:** Power Input  
**Voltage:** +5V DC (±5%)  
**Typical:** +5.0V  
**Range:** 4.75V - 5.25V (full speed); 2.0V - 5.5V (reduced speed)

**Connection:**
- Connect to +5V power supply
- Add 0.1µF ceramic bypass capacitor close to pin (to VSS)
- Add 10µF electrolytic capacitor nearby for bulk filtering

**Notes:**
- W65C02S can operate at lower voltages with reduced maximum clock speed
- At 2.0V: Max ~1 MHz
- At 5.0V: Max 14 MHz

#### Pin 21: VSS (Ground)
**Type:** Power Ground  
**Voltage:** 0V (Ground reference)

**Connection:**
- Connect to power supply ground
- Connect to ground plane or common ground
- Keep ground connections short and direct

---

### Address Bus (16 bits)

#### Pins 9-16, 17-20, 22-25: A0-A15
**Type:** Output (tri-state capable)  
**Function:** 16-bit address bus for memory and I/O addressing

**Pin Assignment:**
- A0-A7: Pins 9-16 (low byte)
- A8-A11: Pins 17-20
- A12-A15: Pins 22-25 (high byte)

**Address Space:** $0000-$FFFF (64KB)

**Timing:**
- Address valid during PHI2 high
- Tri-stated when BE (bus enable) is low
- Valid before PHI2 rises

**Connection:**
```
A0-A15 → Memory address pins
         ROM address pins
         Address decoder
```

**Electrical:**
- TTL compatible outputs
- Can drive 1 TTL load + capacitance
- Use buffers for large memory systems

---

### Data Bus (8 bits)

#### Pins 26-33: D0-D7
**Type:** Bidirectional (tri-state)  
**Function:** 8-bit data bus for data transfer

**Pin Assignment:**
- D0: Pin 33 (LSB)
- D1: Pin 32
- D2: Pin 31
- D3: Pin 30
- D4: Pin 29
- D5: Pin 28
- D6: Pin 27
- D7: Pin 26 (MSB)

**Operation:**
- Input during read cycles (R/W̅ = 1)
- Output during write cycles (R/W̅ = 0)
- Valid during PHI2 high

**Connection:**
```
D0-D7 ↔ Memory data pins (bidirectional)
        ROM data pins (read only)
        I/O device data pins
```

**Electrical:**
- Tri-state capable (high impedance when not driven)
- TTL compatible
- Pull-ups sometimes needed for reliable operation

---

### Control Pins

#### Pin 34: R/W̅ (Read/Write)
**Type:** Output  
**Logic:** Active Low Write  
**Function:** Indicates bus cycle direction

**States:**
- **High (1):** Read cycle - CPU reads from memory/I/O
- **Low (0):** Write cycle - CPU writes to memory/I/O

**Timing:**
- Valid for entire PHI2 high period
- Changes during PHI1 (PHI2 low)

**Connection:**
```
R/W̅ → RAM R/W̅ pin
     → ROM CE/OE̅ (inverted)
     → I/O device R/W̅
     → Address decoder logic
```

**Usage:**
```
Memory Write: A0-A15 = address, D0-D7 = data out, R/W̅ = 0
Memory Read:  A0-A15 = address, D0-D7 = data in,  R/W̅ = 1
```

#### Pin 39: PHI2 (Phase 2 Clock Input)
**Type:** Input  
**Function:** Main system clock

**Specifications:**
- Frequency: DC to 14 MHz (W65C02S-14)
- Duty cycle: 40%-60% (50% typical)
- Rise/fall time: < 5ns

**Clock Timing:**
```
        ┌───┐       ┌───┐       ┌───┐
PHI2    │   │       │   │       │   │
    ────┘   └───────┘   └───────┘   └────
        
        ← T →
        
T = Clock period (1/frequency)
High period = 0.5T (50% duty cycle)
```

**Connection:**
- Connect to crystal oscillator or clock generator
- Use stable clock source
- Clock can be stopped with PHI2 low for static operation
- Can be single-stepped for debugging

**Common Clock Frequencies:**
- 1 MHz: Classic 6502 speed
- 2 MHz: Fast vintage systems
- 4 MHz: Common modern homebrew
- 8 MHz: High-speed systems
- 14 MHz: Maximum rated speed (W65C02S-14)

#### Pin 37: PHI2O (Phase 2 Clock Output)
**Type:** Output  
**Function:** Buffered PHI2 for peripheral timing

**Characteristics:**
- Mirrors PHI2 input
- Can drive peripheral devices
- Slightly delayed from PHI2 input
- Not intended to drive large capacitive loads

**Connection:**
```
PHI2O → Peripheral device clocks (VIA, ACIA, etc.)
      → Logic that needs synchronized clock
```

**Note:** Use external buffers if driving multiple devices.

#### Pin 3: PHI1O (Phase 1 Clock Output)
**Type:** Output  
**Function:** Inverse of PHI2 (for compatibility)

**Characteristics:**
- Inverse of PHI2
- Provided for 6502 compatibility
- Rarely used in modern designs

**Timing:**
```
PHI2    ┌───┐   ┌───┐   ┌───┐
    ────┘   └───┘   └───┘   └────
    
PHI1O   ───┐   ┌───┐   ┌───┐
    ───────┘   └───┘   └───┘
```

#### Pin 40: RES̅ (Reset)
**Type:** Input (active low)  
**Function:** System reset

**Operation:**
- **Low:** Hold CPU in reset state
- **High:** CPU runs normally

**Reset Sequence:**
1. Pull RES̅ low
2. CPU immediately stops
3. Hold low for at least 2 clock cycles
4. Release RES̅ to high
5. CPU loads PC from $FFFC-$FFFD
6. Execution starts at reset vector address

**Power-On Reset:**
- Must hold low for at least 2 cycles after VDD stable (≥4.75V typical)
- Typical: 100ms delay with RC circuit to ensure VDD stabilization

**Reset Circuit:**
```
VDD (5V)
   │
   ┴ 10K
   │
   ├─────→ RES̅ (Pin 40)
   │
  ═╪═ 1µF
   │
  GND

Creates ~10ms delay on power-up
```

**Manual Reset Button:**
```
VDD (5V)
   │
   ┴ 10K (pull-up)
   │
   ├─────→ RES̅ (Pin 40)
   │
   │ S1 (pushbutton)
   │
  GND
```

**What Gets Reset:**
- PC loaded from $FFFC-$FFFD
- I flag set (interrupts disabled)
- D flag cleared (binary mode)
- Interrupt sequences aborted
- Registers (A, X, Y, SP) not affected!

**Best Practices:**
- Always initialize registers in reset handler
- Set stack pointer: `LDX #$FF; TXS`
- Clear decimal mode: `CLD`
- Initialize I/O devices

---

### Interrupt Pins

#### Pin 4: IRQ̅ (Interrupt Request)
**Type:** Input (active low, level sensitive)  
**Function:** Maskable interrupt request

**Operation:**
- Pull low to request interrupt
- CPU responds after current instruction completes
- Only if I flag = 0 (interrupts enabled)
- CPU jumps to vector at $FFFE-$FFFF

**Timing:**
- Level sensitive (must hold low until serviced)
- Sampled during PHI2 high
- Can be tied high if unused

**Multiple IRQ Sources:**
```
Device 1 IRQ ───┐
Device 2 IRQ ───┼─── IRQ̅ (Pin 4)
Device 3 IRQ ───┘
                 │
               ┴ 10K pull-up
```

**IRQ Handler:**
```asm
irq_handler:
    PHA             ; Save A
    TXA
    PHA             ; Save X
    TYA
    PHA             ; Save Y
    
    ; Check which device interrupted
    LDA VIA_IFR     ; Read interrupt flag register
    ; Handle interrupt
    
    PLA             ; Restore Y
    TAY
    PLA             ; Restore X
    TAX
    PLA             ; Restore A
    RTI             ; Return from interrupt
```

**Connection:**
```
IRQ̅ → Pull-up resistor (3.3K-10K) to VDD
    → IRQ̅ outputs from peripherals (open drain/collector)
```

#### Pin 6: NMI̅ (Non-Maskable Interrupt)
**Type:** Input (active low, edge sensitive)  
**Function:** Non-maskable interrupt (highest priority)

**Operation:**
- High-to-low transition triggers interrupt
- Cannot be disabled (non-maskable)
- CPU jumps to vector at $FFFA-$FFFB
- Takes priority over IRQ

**Characteristics:**
- Edge triggered (responds to falling edge)
- Should be low for at least 2 cycles
- Not affected by I flag
- Used for critical events

**Typical Uses:**
- Power failure detection
- Watchdog timer
- Critical error conditions
- Single-step debugging

**Connection:**
```
NMI̅ → Pull-up resistor (10K) to VDD
    → Critical interrupt source (power fail, etc.)
```

**Power Fail NMI:**
```
AC Power ──[Detector]──→ NMI̅
                         (triggers on power loss)
```

**NMI Handler:**
```asm
nmi_handler:
    PHA             ; Save critical state
    ; Handle critical event
    ; Save important data to non-volatile memory
    ; Wait for power to stabilize or fail
    PLA
    RTI
```

**Note:** If unused, tie high through 10K resistor.

---

### Timing and Synchronization Pins

#### Pin 2: RDY (Ready)
**Type:** Input (active low)  
**Function:** CPU wait state control

**Operation:**
- **High (1):** Normal operation
- **Low (0):** CPU waits (extends clock cycle)

**Use Cases:**
- Slow memory devices
- DMA operations
- Single-step debugging
- Clock stretching

**Timing:**
- Sampled during PHI2 high
- CPU inserts wait states while RDY low
- Only affects read cycles (writes complete regardless)

**DMA Example:**
```
DMA needs bus → Pull RDY low
CPU stops     → Perform DMA transfer
DMA done      → Release RDY high
CPU continues
```

**Connection:**
```
RDY → Pull-up resistor (3.3K) to VDD
    → DMA controller output
    → Slow device ready signal
```

**Single-Step Circuit:**
```
        S1 (Step button)
VDD ─────┤
        │
        ├────→ RDY (Pin 2)
        │
       ═╪═ Debounce
        │
       GND
```

#### Pin 7: SYNC (Synchronization)
**Type:** Output  
**Function:** Indicates opcode fetch cycle

**Operation:**
- **High:** CPU is fetching an opcode (first byte of instruction)
- **Low:** CPU is fetching data or operands

**Use Cases:**
- Single-step control
- Instruction trace/debugging
- Cycle-accurate emulation
- Performance monitoring

**Timing:**
- Goes high at start of each instruction fetch
- Remains high for one clock cycle

**Single-Step Using SYNC:**
```
SYNC → Latch → Disable clock after each instruction
             → Single-step control
```

**Instruction Tracer:**
```
When SYNC high:
    Record address bus → This is the instruction opcode location
    Record data bus → This is the opcode
```

#### Pin 38: SOB (Set Overflow Bit)
**Type:** Input (active low, edge sensitive)  
**Function:** Sets V flag in processor status register

**Operation:**
- High-to-low edge sets V flag to 1
- Used for external overflow detection
- Can trigger BVS branch

**Use Cases:**
- Hardware arithmetic overflow
- External condition signaling
- Real-time event detection

**Connection:**
```
SOB → Pull-up resistor (10K) to VDD
    → Hardware comparator/detector
```

**Note:** Rarely used in modern designs. Tie high if unused.

#### Pin 1: VP (Vector Pull)
**Type:** Input (active low)  
**Function:** Indicates vector fetch during interrupt

**Operation:**
- Pull low to indicate external vector pull
- Allows external hardware to provide interrupt vectors
- Advanced feature, rarely used

**Connection:**
- Tie high through 10K resistor if unused
- Connect to vector control logic if implementing external vectors

---

### Reserved/Unused Pins

#### Pins 35-36: NC (No Connect)
**Type:** Reserved  
**Function:** Reserved for future use

**Connection:**
- Leave unconnected (do not connect to anything)
- Or tie to VDD through 10K resistor (safe practice)

#### Pin 5: MLB (Memory Lock for Bus)
**Type:** Output  
**Function:** Memory lock indication (for multiprocessor systems)

**Operation:**
- Used with RMW (Read-Modify-Write) instructions
- Indicates atomic operation in progress
- For preventing bus conflicts in multiprocessor systems

**Instructions that assert MLB:**
- ASL, LSR, ROL, ROR (memory)
- INC, DEC (memory)
- TRB, TSB

**Connection:**
- Can be left unconnected in single-processor systems
- Connect to bus arbitration logic in multi-processor systems

---

## Electrical Characteristics

### Absolute Maximum Ratings
- **VDD:** -0.3V to +7.0V
- **Input voltage:** -0.3V to VDD + 0.3V
- **Operating temperature:** 0°C to +70°C (commercial)
- **Storage temperature:** -65°C to +150°C

### DC Characteristics (VDD = 5V ±5%, 25°C)

| Parameter | Symbol | Min | Typ | Max | Unit |
|-----------|--------|-----|-----|-----|------|
| Input High Voltage | VIH | 2.0 | - | VDD | V |
| Input Low Voltage | VIL | 0 | - | 0.8 | V |
| Output High Voltage | VOH | 2.4 | - | VDD | V |
| Output Low Voltage | VOL | 0 | - | 0.4 | V |
| Input Leakage | IIN | - | - | ±10 | µA |
| Supply Current | IDD | - | 1 | 10 | mA |

### AC Characteristics

**At 14 MHz (71.4ns cycle):**
- Clock high time: 28ns min
- Clock low time: 28ns min
- Address setup: 30ns before PHI2 rise
- Data setup (read): 10ns before PHI2 fall
- Data hold (read): 10ns after PHI2 fall
- Data valid (write): 50ns after PHI2 rise

---

## Breadboard Connection Guide

### Minimal Working Circuit

```
Power:
Pin 8 (VDD) ── +5V (with 0.1µF bypass to GND)
Pin 21 (VSS) ── GND

Clock:
Pin 39 (PHI2) ── 1 MHz oscillator

Reset:
Pin 40 (RES̅) ── 10K to +5V
              └─ 1µF to GND
              └─ Reset button to GND

Control (pull-ups):
Pin 2 (RDY) ── 10K to +5V
Pin 4 (IRQ̅) ── 10K to +5V
Pin 6 (NMI̅) ── 10K to +5V
Pin 38 (SOB) ── 10K to +5V
Pin 1 (VP) ── 10K to +5V

Address Bus:
Pins 9-16, 17-20, 22-25 (A0-A15) ── Memory/ROM/RAM

Data Bus:
Pins 26-33 (D0-D7) ── Memory/ROM/RAM (with pull-ups)

Control Signals:
Pin 34 (R/W̅) ── Memory control logic

Not Used (optional):
Pin 3 (PHI1O) ── Can leave unconnected
Pin 37 (PHI2O) ── Can leave unconnected
Pin 7 (SYNC) ── Can leave unconnected
Pin 5 (MLB) ── Can leave unconnected
Pins 35-36 (NC) ── Leave unconnected
```

### Component Checklist

**Essential:**
- W65C02S CPU (40-pin DIP)
- 0.1µF ceramic capacitor (bypass)
- 10µF electrolytic capacitor (power filtering)
- Clock source (1-14 MHz oscillator or crystal)
- 5× 10K resistors (pull-ups)
- 1µF capacitor (reset RC)
- Memory (ROM and/or RAM)

**Optional:**
- LEDs + resistors for status indicators
- Reset button (pushbutton switch)
- DIP socket (40-pin) for easy CPU removal

---

## Connection Examples

### Connecting ROM (27C256 - 32KB)

```
W65C02S          27C256
A0-A14   ──→   A0-A14
VDD      ──→   VCC
VSS      ──→   GND
R/W̅      ──→   (through inverter to OE̅)
PHI2     ──→   CE̅
D0-D7    ←──   D0-D7
```

### Connecting RAM (62256 - 32KB)

```
W65C02S          62256
A0-A14   ──→   A0-A14
VDD      ──→   VCC
VSS      ──→   GND
R/W̅      ──→   WE̅
         ──→   OE̅ (via address decoder)
PHI2     ──→   CE̅ (via address decoder)
D0-D7    ←→   D0-D7
```

### Connecting 6522 VIA (Versatile Interface Adapter)

```
W65C02S          6522 VIA
A0-A3    ──→   RS0-RS3 (register select)
VDD      ──→   VCC
VSS      ──→   GND
R/W̅      ──→   R/W̅
PHI2     ──→   PHI2
CS1      ←──   Address decoder
CS2      ←──   Address decoder (inverted)
D0-D7    ←→   D0-D7
IRQ̅      ←──   IRQ̅
```

---

## Pin Voltages Quick Check

**Power Good:**
- Pin 8 (VDD): 4.75V - 5.25V
- Pin 21 (VSS): 0V

**Normal Operation (no activity):**
- RES̅ (40): High (~5V)
- PHI2 (39): Toggling 0V/5V
- IRQ̅ (4): High (~5V)
- NMI̅ (6): High (~5V)
- RDY (2): High (~5V)
- R/W̅ (34): Toggling
- Address bus: Changing
- Data bus: Changing during PHI2 high

---

## Troubleshooting

### CPU Not Running
1. Check power: VDD = 5V, VSS = 0V
2. Check bypass capacitor close to pins 8 and 21
3. Check clock at pin 39 (must toggle)
4. Check RES̅ at pin 40 (must be high after power-up)
5. Check pull-ups on IRQ̅, NMI̅, RDY

### Erratic Behavior
1. Add pull-up resistors to data bus (3.3K-10K)
2. Check all address lines for connections
3. Verify ROM contents (especially vectors at $FFFA-$FFFF)
4. Check for floating inputs
5. Add better power supply filtering

### Won't Reset
1. Check RES̅ pin 40 goes low then high
2. Hold RES̅ low for at least 2 clock cycles
3. Check clock is running during reset
4. Verify vectors at $FFFC-$FFFD in ROM

---

## Reference Resources

- **WDC W65C02S Datasheet:** https://www.westerndesigncenter.com/
- **6502.org:** http://www.6502.org/ (hardware projects)
- **Visual 6502:** http://www.visual6502.org/ (internal simulation)

---

## Safety Notes

1. **Static Sensitive:** Use anti-static precautions when handling
2. **Power Polarity:** Double-check VDD/VSS before applying power
3. **Hot Swapping:** Do not insert/remove while powered
4. **Bypass Capacitors:** Always use bypass capacitor close to VDD pin
5. **Pin Bending:** Be gentle when inserting into sockets/breadboards

---

## Quick Pin Reference

**Power:** 8 (VDD), 21 (VSS)  
**Clock:** 39 (PHI2 in)  
**Reset:** 40 (RES̅)  
**Interrupts:** 4 (IRQ̅), 6 (NMI̅)  
**Address:** 9-16, 17-20, 22-25 (A0-A15)  
**Data:** 26-33 (D0-D7)  
**Control:** 34 (R/W̅), 2 (RDY)  

**Pull-ups needed:** RES̅, IRQ̅, NMI̅, RDY, SOB, VP  
**Bypass cap:** 0.1µF between pins 8 and 21

---

For detailed electrical specifications and timing diagrams, consult the official WDC W65C02S datasheet.
