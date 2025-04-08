# Memory Interface Controller (MIC) with a Register

What is MIC?  
The Memory Interface Controller (mic) accepts read and write requests on parameterizable number of input ports, allocates the memory resource to these requests according to an arbitration policy, and for a read request, returns the read memory data.

1. Introduction:  
   * the MIC system provides an efficient interface between multiple requestors and a shared memory resource.  
   * It manages memory access requests from multiple sources, arbitrates between competing requests, and ensures proper data flow between requesters and memory.
-------------
2. Overview  
The MIC system is designed to handle multiple memory access requests from different sources (requesters) and coordinate access to a shared memory resource. It uses a round-robin arbitration scheme to ensure fair access and includes buffering to manage request flow.
    * what is Round-Robin arbitration?
If we have multiple requesters asking to use a shared resource (like memory),
The arbiter decides who gets to use the resource. With round-robin arbitration, the arbiter gives each requester a turn, one by one, in order.
If someone doesn’t have a request, the turn skips to the next one.
-------------
3. Architecture:
   
- FIFO: buffers requests from multiple sources (requesters)
  Each requester has its own FIFO that buffers its memory access requests. The FIFO provides status flags (full, empty) that the arbiter uses to determine which requesters have pending requests.
- Arbiter: selects which requester accesses memory  
    When a memory operation completes (signaled by `acknowledge`), the arbiter selects the next requester with valid data in its FIFO. It generates grant signals that the controller uses to initiate memory operations.
- Controller: translates requests into memory operations
  When the arbiter grants access to a requester, the controller examines the request type (read or write) and generates the appropriate memory control signals. 
- Memory: stores and retrieves data
  The memory module stores and retrieves data based on read and write control signals. Write operations occur synchronously with the clock, while read operations return data with registered outputs for stability.
- MUX: picks request data based on arbiter decision
  Based on the arbiter's grant index, the multiplexor selects the corresponding request data from the FIFOs and passes it to the memory interface logic.
- Register: holds read data when valid
  When a read operation completes and read_valid is asserted, the read register captures the memory data and holds it stable for the requester.

---
4. Flow:  
-Requesters push requests into FIFOs  
-Arbiter selects one with valid request  
-Controller triggers memory operation  
-Memory reads/writes data  
-Register captures read data  
-Arbiter moves to the next requester  

---

5. Integration Files
- mic.sv: Core module wiring all components
- mic_top.sv: Top-level wrapper
---

6. Config Parameters 
  NREQS     Number of requesters (default: 4)    
  PSIZE     Partition size (default: 20)  
  MDEPTH    Memory depth (default: NREQS * PSIZE)  
  AWIDTH    Address width (calculated from MDEPTH)
  MWIDTH    Memory width  (default: 32)  
  RWIDTH    Request width (calculated as AWIDTH + MWIDTH + 2)  
  RDEPTH    FIFO depth  (default: 6)  

---

7. Test Cases
- Single requester read/write: Tests basic write and read operations
- Multiple requesters: Tests multiple requesters accessing different memory locations
- Memory boundary access: Tests operations at memory boundary addresses

