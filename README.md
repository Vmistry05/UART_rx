# UART Communication Controller

A robust, full-duplex UART (Universal Asynchronous Receiver-Transmitter) core implemented in Verilog. This project features a high-speed receiver with 16x oversampling logic and a 4-state Finite State Machine (FSM) to ensure reliable data synchronization and error detection.

## 🚀 Key Features
* **4-State FSM Design:** Robust state transitions (IDLE, START, DATA, STOP) for asynchronous signal capture.
* **Configurable Baud Rate:** Parameterized clock division allows the core to support standard rates (9600, 115200) or custom high-speed baud rates.
* **Oversampling & Mid-bit Sampling:** Samples data at the center of the bit period to maximize noise immunity and timing margin.
* **Integrity Checks:** Includes logic for parity bit checking and frame error detection.

---

## 🌊 Functional Waveform Analysis

The following simulation waveform (`uart_rx.png`) demonstrates the receiver capturing the hex value `0x41` (ASCII 'A').

![UART RX Waveform](uart.rx.png)

### Transaction Breakdown:
1.  **Start Bit Detection:** The FSM transitions from **IDLE (0)** to **START (1)** when a falling edge is detected on the `rx_serial` line.
2.  **Bit Sampling:** The `clk_count` increments to ensure the receiver samples in the middle of each bit duration. You can observe the `bit_index` incrementing from `0` to `7`.
3.  **Data Assembly:** The serial bits are shifted into the `rx_byte` register. As seen in the waveform, the value updates to `41` once the final bit is latched.
4.  **Completion:** Upon receiving the **STOP (3)** bit, the `rx_done` flag pulses high for one clock cycle, signaling the host system that the data is valid.

---

## 🛠 Hardware Architecture

### Port Map
| Signal | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | Input | 1 | System Clock |
| `reset` | Input | 1 | Asynchronous Reset (Active High) |
| `rx_serial`| Input | 1 | Asynchronous Serial Input Line |
| `rx_byte` | Output | 8 | Received Parallel Data Byte |
| `rx_done` | Output | 1 | Data Valid Strobe |
| `parity_err`| Output | 1 | High if Parity Check fails |

### Finite State Machine (FSM)
The receiver utilizes a Moore-type FSM to handle the asynchronous nature of UART:
* **IDLE:** Waiting for a falling edge on the RX line.
* **START:** Validating the start bit by sampling at `0.5` bit duration.
* **DATA:** Capturing 8 bits of data sequentially.
* **STOP:** Validating the stop bit and pulsing the completion flag.

---
