# ARM Pipelined Processor
32-bits ARM pipelined processor is implemented using System-Verilog. The 5 stages of the pipelined processor are:

• Fetch Stage

• Decode Stage

• Execute Stage

• Memory Stage

• Writeback stage


The processor supports the following instructions:

• Data processing instructions where the second source can be either an immediate value or a source register, with no shifts (ADD, SUB, AND, ORR, BIC, EOR).

• The LDR and STR instructions with positive immediate offset (offset mode).

• Branch instruction.

Also, it can handle the following hazards:

• Read After Write (RAW) Hazard

• LDR Hazard

• Control Hazards due to Branch or PC write

# Processor Main Components

1- Control Unit

2- Datapath

3- Hazard Unit

4- Instruction Memory

5- Data Memory

6- Register File

7- Arithemtic Logic Unit (ALU)

![image](https://github.com/AlaaTaha32/ARM-Pipelined-Processor/assets/154026967/16fc8710-309f-4c28-9552-6d26b58c6fa8)

# Resources
[1] S. Harris, “Chapter 7: Microarchitecture,” in Digital Design and Computer Architecture ARM® Edition, 2nd ed, D. Harris, Ed. 2013, pp. 386–456 



