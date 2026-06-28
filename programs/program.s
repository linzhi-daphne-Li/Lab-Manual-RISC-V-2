addi x1, x0, 5
addi x2, x0, 10
add  x3, x1, x2
sw   x3, 0(x0)
lw   x13, 0(x0)
lui  x14, 0x12345
beq  x3, x13, label
addi x15, x0, 99
label:
jal  x16, end
addi x17, x0, 77
end:
addi x18, x0, 42
