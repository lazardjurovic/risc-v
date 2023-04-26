addi x1 x0 3
addi x2 x0 4
xor x3  x3 x3

loop:
add x3 x3 x2
addi x1 x1 -1
bgt x1 x0 loop

sw x3 0(x0)
lui x4 0x00001
auipc x5 0x00001
