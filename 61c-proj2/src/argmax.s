.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    
    addi t0, x0, 1
    bge a1, t0, loop_start
    li a0, 36
    j exit
loop_start:
    li t0, 0
    mv t1, a1
    li t2, 0      # index of largest element
    lw t3, 0(a0)   # current largest value
loop_continue:
    slli t4, t0, 2 # current index
    add t4, t4, a0
    lw t4, 0(t4)    # current value
   
    bge t3, t4, no_update
    mv t3, t4
    mv t2, t0
no_update:
    addi t0, t0, 1
    blt t0, t1, loop_continue
loop_end:
    # Epilogue
    mv a0, t2
    jr ra
