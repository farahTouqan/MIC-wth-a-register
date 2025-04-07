# 🧠 Memory Interface Controller (MIC) with Register

### 1. Overview
The MIC connects multiple requesters to shared memory
handling read/write requests using FIFO buffers and a round-robin arbiter for fair access.
It supports configurable parameters and captures read data in a register.


-------------
## 2. Key Features
- Handles multiple requesters
- Fair access via round-robin arbitration
- FIFO request buffering
- Supports both read and write operations
- Parameterized design
- Read data captured in a register

----------------------------------

## 3. Architecture

###  Main Components

- **FIFO**: Buffers requests from each requester
- **Arbiter**: Selects which requester accesses memory
- **Controller**: Translates requests into memory operations
- **Memory**: Stores and retrieves data
- **MUX**: Picks request data based on arbiter decision
- **Register**: Holds read data when valid

---

## 4. Request Format & Flow

**Request Format**: `{data, addr, read_bit, write_bit}`

**Flow:**
1. Requesters push requests into FIFOs
2. Arbiter selects one with valid request
3. Controller triggers memory operation
4. Memory reads/writes data
5. Register captures read data
6. Arbiter moves to the next requester

---

## 5. Integration Files

- `mic.sv`: Core module wiring all components
- `mic_top.sv`: Top-level wrapper
- `mic_dut.sv`: Testbench wrapper

---

## 6. Config Parameters (from `mic_pkg.sv`)

| Name      | Description              | Default            |
|-----------|--------------------------|--------------------|
| `NREQS`   | Number of requesters     | 4                  |
| `PSIZE`   | Partition size           | 20                 |
| `MDEPTH`  | Memory depth             | NREQS × PSIZE      |
| `MWIDTH`  | Memory width             | 32                 |
| `RDEPTH`  | FIFO depth               | 6                  |

---

## 7. Testing

### ✅ Test Cases

- Single requester read/write
- Multiple requesters
- Memory boundary access

### 🛠 Makefile Targets

- `compile` – Compile all files
- `elaborate` – Elaborate design
- `simulate` – Run testbench
- `clean` – Remove output files

---

## 8. Summary

MIC provides a modular and fair memory interface for multiple requesters. It works well for sequential access, and future improvements can enhance concurrency support.

