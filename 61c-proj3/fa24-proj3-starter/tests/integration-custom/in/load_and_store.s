addi t0, x0, 0x3E8
lb t1, 0(t0)
lb t2, 1(t0)
lb t2, 2(t0)

addi t0, x0, 0x3E8
lh t1, 0(t0)
lh t2, 2(t0)

addi t0, x0, 0x3E8
lw t1, 0(t0)
lw t2, 4(t0)

addi t0, x0, 0x3E8
addi t1, x0, 0xFF
sb t1, 0(t0)

addi t2, x0, 0x12
sb t2, 1(t0)

addi t0, x0, 0x3E8
addi t1, x0, 0x2CD
sh t1, 0(t0)

addi t0, x0, 0x3E8
addi t1, x0, 0x765
sw t1, 0(t0)
