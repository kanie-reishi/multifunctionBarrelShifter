# Multifunction Barrel Shifter

A 4-bit barrel shifter implemented in Verilog, targeting the **Digilent Basys 3** FPGA board (Artix-7 XC7A35T). Each button press rotates the stored value by one bit, with the result displayed on the 7-segment LEDs as binary digits.

## Features

- **1-bit circular rotation** (left or right) triggered by button press
- **Stateful output** — result is stored in a register and held between operations
- **Button debouncing** with edge detection (~10 ms)
- **Idle state** — output does not change when no button is pressed
- **4-digit 7-segment display** showing each output bit as `0` or `1`

## I/O Mapping (Basys 3)

| Resource | Function |
|---|---|
| `SW[3:0]` | 4-bit input data |
| `btnC` (center) | Load `SW[3:0]` into output register (reset) |
| `btnL` (left) | Rotate stored value **left** by 1 bit |
| `btnR` (right) | Rotate stored value **right** by 1 bit |
| `AN3–AN0` (7-seg) | Binary output: bit[3] bit[2] bit[1] bit[0] |
| `LD[3:0]` (LEDs) | Echo stored output |

## How It Works

```
  SW[3:0]                     ┌──────────┐
  ──────── btnC(reset) ──────►│ data_reg │──► 7-seg (4 binary digits)
                              │ (4-bit)  │──► LED[3:0]
           btnL(left)  ──────►│          │
           btnR(right) ──────►│          │
                              └────┬─────┘
                                   │ ▲
                                   ▼ │
                            ┌──────────────┐
                            │barrel_shifter│
                            └──────────────┘
```

1. Set switches to desired input, press **btnC** to load
2. Press **btnL** to rotate left or **btnR** to rotate right
3. Result is saved — press again to keep rotating
4. Change switches and press **btnC** to start over

### Example

```
Load 0001 → press btnL → 0010 → press btnL → 0100 → press btnR → 0010
```

## Design Architecture

The left rotation is implemented using the **reverse-rotate-reverse** technique:
> `rotate_left(x) = reverse(rotate_right(reverse(x)))`

This reuses a single right-rotator for both directions.

### Module Hierarchy

```
barrel_shifter_top
├── debouncer         × 3  (btnL, btnR, btnC)
└── barrel_Shifter_LR_reverse
    ├── reverse_with_en       (conditional bit reversal)
    ├── rotating_right_1_bit  (1-bit right rotation)
    └── reverse_with_en       (conditional bit reversal)
```

## Project Structure

```
├── rtl/
│   ├── barrelShifterTop.v        # Top module (sequential, Basys 3)
│   ├── barrelShifterLR.v         # Barrel shifter (mux-based variant)
│   ├── barrelShifterwReverse.v   # Barrel shifter (reverse-based variant) ★ used
│   ├── debouncer.v               # Button debouncer with edge detection
│   ├── mux2to1.v                 # 2-to-1 multiplexer
│   ├── reverse.v                 # Conditional bit reversal
│   ├── rotatingLeft1Bit.v        # 1-bit left rotator
│   └── rotatingRight1Bit.v       # 1-bit right rotator
├── tb/
│   └── tbBarrelShifterLR.v       # Testbench comparing both shifter variants
├── xdc/
│   └── barrelShifter.xdc         # Basys 3 pin constraints
└── README.md
```

## Getting Started

1. Open **Vivado** and create a new project targeting `xc7a35tcpg236-1`
2. Add all files from `rtl/` as design sources
3. Add `xdc/barrelShifter.xdc` as constraints
4. Set `barrel_shifter_top` as the top module
5. Run **Synthesis → Implementation → Generate Bitstream**
6. Program the Basys 3 board

## Tools

- **Xilinx Vivado** (synthesis & implementation)
- **ModelSim / Vivado Simulator** (simulation with `tb/tbBarrelShifterLR.v`)

## License

This project is for educational purposes as part of *FPGA Prototyping by Verilog Examples*.
