.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
    j no_error
fopen_error:
    li a0, 27
    j exit
fread_error:
    li a0, 29
    j exit
malloc_error:
    li a0, 26
    j exit
fclose_error:
    li a0, 28
    j exit
    
no_error:
    # Prologue
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s0, 16(sp)
    sw s4, 20(sp)
    
    mv s1, a1         # pointer to row_num
    mv s2, a2         # pointer to col_num
    
    # open file
    li a1, 0
    jal ra, fopen
    li t0, -1
    beq a0, t0, fopen_error
    mv s0, a0
    
    # read row num
    mv a1, s1 
    li a2, 4
    jal ra, fread
    li t0, 4
    bne a0, t0, fread_error
    
    # read col num
    mv a0, s0
    mv a1, s2
    li a2, 4
    jal ra, fread
    li t0, 4
    bne a0, t0, fread_error
    
    # malloc space
    lw t0, 0(s1)
    lw t1, 0(s2)
    mul s3, t0, t1     # ele_num of matrix
    slli s3, s3, 2
    mv a0, s3
    jal ra, malloc
    beq a0, x0, malloc_error             
    
    # write bytes
    mv s4, a0              # pointer to stored matrix in memory
    mv a1, s4          
    mv a0, s0
    mv a2, s3
    jal ra, fread
    bne a0, s3, fread_error
   
    mv a0, s0
    jal ra, fclose
    bne a0, x0, fclose_error

    # Epilogue
    mv a0, s4
    lw ra, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s0, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24

    jr ra
