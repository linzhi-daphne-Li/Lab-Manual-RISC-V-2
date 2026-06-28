addi x1, x0, 5
addi x2, x0, 10
add x3, x1, x2
sw x3, 0(x0)
lw x13, 0(x0)
lui x14, 0x12345
beq x3, x13, label
label:
jal x16, end
end:
addi x18, x0, 42
