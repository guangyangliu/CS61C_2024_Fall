.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:       # n x m * m x k
              # a1  a2  a4  a5
    # Error checks
    li t0, 1
    blt a1, t0, error
    blt a2, t0, error
    blt a4, t0, error
    blt a5, t0, error
    bne a2, a4, error
    j no_error
error:
    li a0, 38
    j exit
    # Prologue
no_error:
    addi sp, sp, -40   # save ra and all s_ registers
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    
    mv s4, a0   # pointer to m0
    mv s5, a3   # pointer to m1
    mv s6, a2   # m
    mv s7, a6   # new matrix pointer
    mv s8, a5
    sw ra, 0(sp)
    # outer loop initialize
    li s0, 0       # i
    mv s1, a1      # n rows
outer_loop_start:
    
    # inner loop initialize
    li s2, 0       # j
    mv s3, s8      # k columns
inner_loop_start:
    mul a0, s6, s0
    slli a0, a0, 2 
    add a0, a0, s4 # pointer to row i in m0
    mv a2, s6      # number of elements
    slli a1, s2, 2 
    add a1, a1, s5 # pointer to col j in m1
    li a3, 1       # The stride of the first array
    mv a4, s3      # The stride of the second array
    jal ra, dot    # call dot
    
    mul t0, s0, s3
    add t0, t0, s2
    slli t0, t0, 2
    
    add t0, t0, s7 # position to store
    sw a0, 0(t0)

inner_loop_end:
    addi s2, s2, 1
    blt s2, s3, inner_loop_start

outer_loop_end:
    addi s0, s0, 1
    blt s0, s1, outer_loop_start
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    addi sp, sp, 40
    jr ra
