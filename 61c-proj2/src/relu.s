.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    addi t0, x0, 1
    bge a1, t0, loop_start
    li a0, 36
    j exit
loop_start:
    li t0, 0      # i
    mv t1, a1     # length
loop_continue:
    slli t2, t0, 2   # index
    add t2, t2, a0
    lw t3, 0(t2)
    bge t3, x0, greater_than_0
    sw x0, 0(t2)
greater_than_0:
    addi t0, t0, 1
    blt t0, t1, loop_continue
loop_end:
    jr ra
