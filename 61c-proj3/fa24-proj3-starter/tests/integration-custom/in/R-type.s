addi x5, x0, 10
addi x6, x0, 20
add x7, x5, x6
sub x8, x6, x5
and x9, x5, x6
or x5, x5, x6
xor x6, x5, x6

addi x7, x0, 1
sll x8, x6, x7
srl x9, x6, x7
sra x5, x6, x7

addi x6, x0, -5
addi x7, x0, 4
slt x8, x6, x7
slt x9, x7, x6
slt x5, x6, x6

addi x5, x0, 3
addi x6, x0, 4
mul x7, x5, x6
mulh x8, x5, x6
mulhu x9, x5, x6

addi x5, x0, -3
addi x6, x0, -4
mul x7, x5, x6
mulh x8, x5, x6
mulhu x9, x5, x6

addi x5, x0, 0xFFFFFFFF
addi x6, x0, 2
mul x7, x5, x6
mulh x8, x5, x6
mulhu x9, x5, x6