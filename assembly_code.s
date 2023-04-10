addi x1 x0 3
addi x2 x0 4
addi x3 x0 0

loop:
add x3 x3 x2
addi x1 x1 -1
bne x0 x1 loop

nop
nop
nop

sw x3 0(x0)
lui x4 0x00001

