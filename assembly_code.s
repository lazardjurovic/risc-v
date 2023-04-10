addi x1 x0 3
addi x2 x0 4
xor x3  x3 x3

loop:
add x3 x3 x2
addi x1 x1 -1
beq x1 x0 end
beq x0 x0 loop

end:
sw x3 0(x0)
lui x4 0x00001
