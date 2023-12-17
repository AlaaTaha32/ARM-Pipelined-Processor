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

<p align="center">
  <img width="460" height="300" src="![image](https://github.com/AlaaTaha32/ARM-Pipelined-Processor/assets/154026967/1f42aa39-d6d2-4368-8e5c-e6fa22fa41a4)
">
</p>



