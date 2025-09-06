# FPGA Chrome Dino Game

An FPGA implementation of the **Chrome Dino** game in **Verilog**, targeting 640×480 VGA output.  
The design integrates input handling, a game state machine, obstacle motion, collision detection, VGA timing, and a graphics renderer.

## Features
- 640×480 VGA timing with pixel-accurate rendering
- Game FSM: idle, jump/fall, and game-over handling
- Obstacle generation with continuous scrolling
- Simple collision detector for dino vs. obstacles
- Modular RTL, synthesizable for common FPGA boards

## Project Structure
| File | Description |
|------|-------------|
| `top.v` | Top-level integration of all modules. |
| `clock_divider.v` | Generates `vga_clk` and `game_tick`. |
| `input_handler.v` | Debounced jump detection. |
| `game_fsm.v` | Game state machine; outputs `dino_y` and `game_over`. |
| `obstacle_generator.v` | Produces moving obstacle X positions. |
| `collision_detector.v` | Computes collision from dino and obstacle bounds. |
| `vga_controller.v` | 640×480 timing; outputs `hsync`, `vsync`, `pixel_x`, `pixel_y`, `display_area`. |
| `graphics_engine.v` | Draws dino, obstacles, and background to RGB. |

## Architecture Overview
The game follows an **input–update–render** loop synchronized by `game_tick` and `vga_clk`:
1. **Input**: Button sampled/debounced to produce `jump_pressed`.  
2. **Update**:  
   - `obstacle_generator` advances X positions on each `game_tick`.  
   - `game_fsm` updates `dino_y`, transitions states, sets `game_over`.  
   - `collision_detector` flags contact between dino and obstacles.  
3. **Render**:  
   - `vga_controller` provides timing and pixel coordinates.  
   - `graphics_engine` decides RGB for each pixel within `display_area`.

**Pipeline Stages**:
| Stage | Module | Function |
|-------|--------|----------|
| 1 | `input_handler.v` | Debounce and detect jump. |
| 2 | `game_fsm.v` | Update dino Y and game state. |
| 3 | `obstacle_generator.v` | Scroll obstacles across screen. |
| 4 | `collision_detector.v` | Detect overlap/collision. |
| 5 | `vga_controller.v` | Generate VGA sync + pixel coords. |
| 6 | `graphics_engine.v` | Draw sprites and background. |

## Verification
Verification via **directed testbenches and manual waveform inspection**:
- Unit-level sequences (e.g., forced jumps, obstacle wraps) checked on `game_tick`.
- VGA timing verified by observing `hsync`/`vsync` pulse widths and active `display_area`.
- Pixel-level checks on `graphics_engine` via GTKWave at representative frames.

## Testing
To run simulations:
1. Compile RTL files with your Verilog simulator (Icarus Verilog, Verilator, ModelSim).
2. Run top-level or module-level tests and inspect waveforms.

Example:
```bash
iverilog -o sim top.v clock_divider.v input_handler.v game_fsm.v \
obstacle_generator.v collision_detector.v vga_controller.v graphics_engine.v
vvp sim
gtkwave dump.vcd
```

## Author
Favour Anuoluwapo Iwueze
