.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:

    # Prologue
    li t0, 1
    blt a2, t0, ele_num_less_than_1
    blt a3, t0, stride_less_than_1
    blt a4, t0, stride_less_than_1
    j loop_start
stride_less_than_1:
    li a0, 37
    j exit
ele_num_less_than_1:
    li a0, 36
    j exit
    
loop_start:
    li t0, 0   # i
    mv t1, a2   # ele_num
    li t3, 0   # dot product
    
    li t4, 0
    li t5, 0
loop_continue:
    slli a5, t4, 2
    slli a6, t5, 2
    add a5, a5, a0
    add a6, a6, a1
    lw a5, 0(a5)
    lw a6, 0(a6)
    mul a5, a5, a6
    add t3, t3, a5

    addi t0, t0, 1
    add t4, t4, a3
    add t5, t5, a4
    blt t0, t1, loop_continue
loop_end:
    mv a0, t3
    jr ra
