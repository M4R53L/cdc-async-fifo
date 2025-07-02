
# Async FIFO + CDC Synchronization Bridge

This project implements an asynchronous FIFO and a synchronization bridge between two distinct clock domains (80 MHz and 50 MHz), making it possible to burst data transfer with full CDC protection. Designed for an advanced digital logic lab, it features proper use of Gray-coded pointers, dual flip-flop synchronizers, and handshake-based control paths.

---

## 📦 Features

- **Async FIFO**:
  - Dual-clock domain support (write: 80 MHz, read: 50 MHz)
  - Gray-coded read/write pointers with bin2gray and gray2bin modules
  - Full/Empty logic based on pointer synchronization
  - FIFO depth: 16 words × 8-bit
- **Synchronization Bridge**:
  - CDC-safe request/acknowledge mechanism
  - Pulse synchronizer from clkb → clka
  - Dual flip-flop reset synchronizer
- **Testbench**:
  - Dual-agent driver simulates burst sender/receiver
  - Monitor and checker modules verify integrity of all 20-byte bursts
  - Uses SystemVerilog queue for dynamic verification

---

## 📁 Directory Structure

```
async-fifo-sync-bridge/
├── rtl/                 # RTL files: async_fifo.sv, sync_bridge.sv, gray_coding.sv
├── sim/                 # Testbench and validation waveforms
├── docs/                # Diagrams, waveform screenshots, timing results
└── README.md
```

---

## 📊 FIFO Depth Calculation

- Write clock (clka): 80 MHz → Tclka = 12.5 ns
- Read clock (clkb): 50 MHz → Tclkb = 20 ns
- Time to write 20 bytes ≈ 500 ns
- Read time (3 idle cycles): ≈ 80 ns
- Read during write ratio ≈ 6.25 → FIFO depth = 16 (next power of 2)

---

## ⛓️ Modules

- `async_fifo.sv` – Dual-clock FIFO with synchronized pointers
- `gray2bin.sv` / `bin2gray.sv` – Pointer encoders
- `pulse_sync1-3.sv` – Pulse synchronizers for various clock relationships
- `sync_bridge.sv` – Top-level synchronization bridge integrating all above
- `sync_bridge_tb.sv` – Testbench including burst simulation, monitors, and checker

---

## 💡 Simulation Details

- Fully randomized 20-byte burst from clka domain
- Single-cycle `data_req` signal from clkb domain
- Data integrity confirmed on receiver side with checker
- Waveform validation via ModelSim (see `sim/`)

