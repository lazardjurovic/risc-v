# RISC V ISA implementation in VHDL


![](https://riscv.org/wp-content/uploads/2018/09/riscv-logo-1.png)

Project for Microcomputer arhitecture course at Faculty of Techical Sciences in Novi Sad. Main idea is to implement full 5 stage pipelined RV32I.

<figure>
<img src="https://i.ibb.co/tpFXhKB/schematic-top.png" alt="schematic-top" border="0">
<figcaption>Internal connections inside of top module</figcaption>
</figure>

Testbench is stored at RISC-V.srcs/sim_1/new/TOP_RISCV_tb.vhd. It connects CPU to data and instruction memory. First several cycles of every simulation are dedicated to loading program form assembly_code.txt into instruction memory. After that reset is raised to 1 and program can start executing.

<a href="https://github.com/mortbopet/Ripes">RIPES</a> simulator was used for generating machine instructions, and assmebly code can be found in assembly_code.s file. 