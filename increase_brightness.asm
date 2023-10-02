.data
in_file: .asciiz "C:/Users/Thando/Downloads/architecture - assingment/sample_images/tree_64_in_ascii_lf.ppm"
out_file: .asciiz "C:/Users/Thando/Downloads/architecture - assingment/brightness_output_tree.ppm"
counter_image: .space 80000 	  # Buffer for counting image content lengthNU
input_img: .space 80000       # Buffer to store image content

nline: .asciiz "\n"
output_avg: .asciiz "Original image average pixel value:\n"
bright_avg: .asciiz "New image average pixel value:\n"
string1: .space 4             # Temp string for line reversal
output_string: .space 80000       # Output buffer

error: .asciiz "Error: File could not be read"

.text   

main:
    # Open input and output files
    li $v0, 13
    la $a0, in_file
    li $a1, 0
    li $a2, 0
    syscall
    move $s0, $v0

    li $v0, 13
    la $a0, out_file
    li $a1, 1
    syscall
    move $s1, $v0

    bnez $v0, file_initialized

    li $v0, 4
    la $a0, error
    syscall

    li $v0, 10
    syscall

file_initialized:
    # Initialize counters and indices
    li $t0, 0 # Counter for the number to be incremented
    li $t1, 0 # Position counter for string to int

    # Initialize counters for processing image content
    li $t3, 0
    li $t4, 0

    # Initialize temp string and output string counters
    li $t5, 0
    li $t6, 0

    # Counter to skip the first 3 lines
    li $t7, 0

    # Sum of pixel values before and after increase
    li $t8, 0
    li $t9, 0

    # Output counters and constants
    li $s6, 0
    li $s3, 12292
    li $s2, 4

reading_in_contents:
    # Read file content
    li $v0, 14
    move $a0, $s0
    la $a1, input_img
    la $a2, 80000
    syscall

    # Close the input file
    li $v0, 16
    move $a0, $s0
    syscall

    j skip_initial_header

skip_initial_header:
    # Check if we need to skip the first 3 lines
    beq $t6, 19, Ascii_num_conversion

    # Copy characters to output string and advance counters
    lb $t2, input_img($t1)
    sb $t2, output_string($t6)

    addi $t6, $t6, 1
    addi $t1, $t1, 1
    addi $t7, $t7, 1
    j skip_initial_header

skip_count:
    # Increment counters for skipping lines
    addi $t7, $t7, 1
    addi $t1, $t1, 1
    j skip_initial_header

Ascii_num_conversion:
    #end of the input string
    bge $s2, $s3, out_length

    # Load the current character from input
    lb $t2, input_img($t1)

    # Check if it's a nline character
    beq $t2, 10, incrementing_values

    # Convert ASCII character to integer
    sub $t2, $t2, 48
    mul $t0, $t0, 10
    add $t0, $t0, $t2

    # Move to the next character
    addi $t1, $t1, 1
    j Ascii_num_conversion

incrementing_values:
    # Add the current integer to the sum of pixel values
    add $t8, $t8, $t0

    # Limit the integer to 255
    li $s7, 255
    addi $t0, $t0, 10
    bge $t0, $s7, incr_skip_ten

    # Add the integer to the sum after increase
    add $t9, $t9, $t0
    j no._ascci_conversion

incr_skip_ten:
    # Limit the integer to 255
    li $t0, 255
    add $t9, $t9, $t0
    j no._ascci_conversion

no._ascci_conversion:
    # Divide the integer by 10 to get the unit digit
    div $t0, $t0, 10
    mfhi $t3

    # Convert the unit digit to ASCII
    addi $t3, $t3, 48
    sb $t3, string1($t5)

    # Check if we're done with the integer
    beqz $t0, reverse_con

    # Move to the next position
    addi $t5, $t5, 1
    j no._ascci_conversion

reverse_con:
    # Reverse the string representation of the integer
    lb $t3, string1($t5)
    sb $t3, output_string($t6)

    # Advance counters
    addi $t6, $t6, 1
    addi $t5, $t5, -1

    # Check if we're done reversing
    beq $t5, -1, end_conversion

    j reverse_con

end_conversion:
    # Add a nline character
    li $t3, 10
    sb $t3, output_string($t6)
    addi $t6, $t6, 1

    # Reset counters and move to the next line
    li $t0, 0
    li $t5, 0
    addi $t1, $t1, 1
    addi $s2, $s2, 1
    j Ascii_num_conversion

out_length:
    # Count the length of the output string
    lb $t2, output_string($s6)
    beqz $t2, comp_process

    # Advance output counters
    addi $s6, $s6, 1
    addi $t4, $t4, 1 
    j out_length

comp_process:
    # Reset the byte position in the output
    li $t2, 0
    j write_in

write_in:
    # Open the output file for writing
    li $v0, 13
    la $a0, out_file
    li $a1, 1
    syscall
    move $s1, $v0

    # Write the output string to the file
    li $v0, 15
    move $a0, $s1
    la $a1, output_string
    move $a2, $t4
    syscall 

    # Close the output file
    li $v0, 16
    move $a0, $s7
    syscall

printing_out:
    # Close a file 
    li $v0, 16
    move $a0, $s7
    syscall

    # Calculate average pixel value before increase
    li $s4, 3133440

    # Floating point division for average before increase
    mtc1 $t8, $f0
    mtc1 $s4, $f2
    div.s $f4, $f0, $f2 

    mov.s $f12, $f4

    li $v0, 4
    la $a0, output_avg
    syscall

    li $v0, 2
    syscall

    li $v0, 4
    la $a0, nline
    syscall

    # Calculate average pixel value after increase
    mtc1 $t9, $f0      
    mtc1 $s4, $f2
    div.s $f4, $f0, $f2 

    mov.s $f12, $f4

    li $v0, 4
    la $a0, bright_avg
    syscall

    li $v0, 2
    syscall

# Exit the program
exit:
    li $v0, 10 #syscall for exit
    syscall
