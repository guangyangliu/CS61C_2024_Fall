addi x5, x0, 10
addi x6, x5, 5
addi x7, x5, -5
addi x8, x5, 0
addi x9, x6, -15
xori x6, x5, 170
addi x5, x0, 204
andi x6, x5, 170
andi x7, x5, 0
andi x8, x5, -1

addi x5, x0, 51
ori x6, x5, 85
ori x7, x5, 0
ori x8, x5, -1

addi x5, x0, 240

xori x7, x5, 0
xori x8, x5, -1

addi x5, x0, 1
slli x6, x5, 3
slli x7, x5, 0
addi x8, x0, -1
slli x9, x8, 4

addi x5, x0, 32
srli x6, x5, 2
addi x7, x0, -1
srli x8, x7, 4

addi x5, x0, -16
srai x6, x5, 2
addi x7, x0, -1
srai x8, x7, 1

addi x5, x0, 5
slti x6, x5, 10
slti x7, x5, 5
slti x8, x5, -1
addi x9, x0, -10
slti x5, x9, 0
slti x6, x9, -20