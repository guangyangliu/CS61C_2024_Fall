.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
j no_error
malloc_fail:
    li a0, 26
    j exit
incorrect_args:
    li a0, 31
    j exit
no_error:
    li t0, 5
    bne a0, t0, incorrect_args
    
    addi sp, sp, -56
    sw ra, 0(sp)
    sw a2, 4(sp)
    sw s0, 8(sp)
    sw s1, 12(sp)
    sw s2, 16(sp)
    sw s3, 20(sp)
    sw s4, 24(sp)
    sw s5, 28(sp)
    sw s6, 32(sp)
    sw s7, 36(sp)
    sw s8, 40(sp)
    sw s9, 44(sp)
    sw s10, 48(sp)
    sw s11, 52(sp)
    mv s1, a1              # points to argv
   
    # Read pretrained m0
   
    li a0, 4
    jal ra, malloc
    beq a0, x0, malloc_fail
    mv s2, a0              # points to row_num of m0
    li a0, 4
    jal ra, malloc
    beq a0, x0, malloc_fail
    mv s3, a0              # points to col_num of m0
    lw a0, 4(s1)        # points to file path of m0
    mv a1, s2
    mv a2, s3
    jal ra, read_matrix
    mv s4, a0              # store m0
    
    # Read pretrained m1
    li a0, 4
    jal ra, malloc
    beq a0, x0, malloc_fail
    mv s7, a0              # points to row_num
    li a0, 4
    jal ra, malloc
    beq a0, x0, malloc_fail
    mv s8, a0              # points to col_num
    lw a0, 8(s1)
    mv a1, s7
    mv a2, s8
    jal ra, read_matrix
    mv s5, a0              # store m1
    
    # Read input matrix
    li a0, 4
    jal ra, malloc
    beq a0, x0, malloc_fail
    mv s9, a0              # points to row_num
    li a0, 4
    jal ra, malloc
    beq a0, x0, malloc_fail
    mv s10, a0              # points to col_num
    lw a0, 12(s1)
    mv a1, s9
    mv a2, s10
    jal ra, read_matrix
    mv s6, a0              # store input
    
    # Compute h = matmul(m0, input)
    lw t1, 0(s2)
    lw t2, 0(s10)
    mul t0, s2, s10        # malloc for h    
    slli a0, t0, 2
    jal ra, malloc
    beq a0, x0, malloc_fail
    mv s11, a0             # points to h
    mv a0, s4              # call matmul
    mv a3, s6
    lw a1, 0(s2)
    lw a2, 0(s3)
    lw a4, 0(s9)
    lw a5, 0(s10)
    mv a6, s11          
    jal ra, matmul
    
    mv a0, s3             # at this point, the col_num of m0 in s3 is useless
    jal ra, free          # so free memory pointed by s3, to get s3 available
                           
    # Compute h = relu(h)
    mv a0, s11
    lw t0, 0(s2)
    lw t1, 0(s10)
    mul a1, t0, t1
    jal ra, relu

    # Compute o = matmul(m1, h)
    lw t1, 0(s7)
    lw t2, 0(s10)
    mul t0, t1, t2        # malloc for o
    slli a0, t0, 2
    jal ra, malloc
    beq a0, x0, malloc_fail
    mv s3, a0              # points to o
    mv a0, s5
    lw a1, 0(s7)
    lw a2, 0(s8)
    mv a3, s11
    lw a4, 0(s2)
    lw a5, 0(s10)
    mv a6, s3    
    jal matmul
    
    # Write output matrix o
    lw a0, 16(s1)
    mv a1, s3
    lw a2, 0(s7)
    lw a3, 0(s10)
    jal write_matrix

    # Compute and return argmax(o)
    mv a0, s3
    lw t0, 0(s7)
    lw t1, 0(s10)
    mul a1, t0, t1
    jal ra, argmax
    mv s0, a0
    lw t1, 4(sp)
    bne t1, x0, silent_mode
    # If enabled, print argmax(o) and newline
    jal ra, print_int
    li a0, '\n'
    jal ra, print_char
    mv a0, s0
silent_mode:
    # free all mallocs
    mv a0, s2
    jal, ra, free
    mv a0, s3
    jal, ra, free
    mv a0, s7
    jal, ra, free
    mv a0, s8
    jal, ra, free
    mv a0, s5
    jal, ra, free
    mv a0, s4
    jal, ra, free
    mv a0, s6
    jal, ra, free
    mv a0, s10
    jal, ra, free
    mv a0, s11
    jal, ra, free
    mv a0, s9
    jal, ra, free
    
    
    mv a0, s0
    lw ra, 0(sp)
    lw a2, 4(sp)
    lw s0, 8(sp)
    lw s1, 12(sp)
    lw s2, 16(sp)
    lw s3, 20(sp)
    lw s4, 24(sp)
    lw s5, 28(sp)
    lw s6, 32(sp)
    lw s7, 36(sp)
    lw s8, 40(sp)
    lw s9, 44(sp)
    lw s10, 48(sp)
    lw s11, 52(sp)
    addi sp, sp, 56
    jr ra
