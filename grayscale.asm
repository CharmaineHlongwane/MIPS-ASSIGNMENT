.data
   in_file: .asciiz "C:/Users/Thando/Downloads/architecture - assingment/sample_images/tree_64_in_ascii_lf.ppm"
   out_file: .asciiz "C:/Users/Thando/Downloads/architecture - assingment/greyscale_output_tree.ppm"
   Read_in: .space  100000
   output_wrt: .space 100000
.text
.globl main

main:
		#reading in file
        li $v0, 13    # opening the file
        la $a0, in_file #arguments for the read
        li $a1, 0 
        li $a2,0          
        syscall
        move $s0, $v0  # saving to $s0



    #this is for the output
    li $v0, 13
    la $a0, out_file
    li $a1, 1 # writing back
    li $a2, 0
    syscall
    move $s1, $v0 # Save it to $s1

input_loop:
	## Read data from the input file into the Read_in buffer
     li $v0, 14
    move $a0, $s0
    la $a1, Read_in
    li $a2, 100000
    syscall

	#these are bufferes
	 la $s2, Read_in 
	la $s3, output_wrt
	la $s4, output_wrt
	li $t1, 1 			#counter

#change P3 to p2
li $t2, 80  	#ascii value for P
sb $t2, ($s3)
addi $s2, $s2, 1
addi $s3, $s3, 1
li $t2, 50 		#ascii 2
sb $t2, ($s3)
addi $s2, $s2, 1
addi $s3, $s3, 1

#adding the line
li $t2, 10
sb $t2, ($s3)
addi $s2, $s2, 1
addi $s3, $s3, 1



#add the heading into the write_in buffer
heading_loop:
lb $t2,($s2)
sb $t2,($s3)

addi $s3,$s3,1
addi $s2,$s2,1

# branch
beq $t2,10,match_n
j heading_loop

match_n:
 addi $t1,$t1,1	#no of lines
 beq $t1,4,reading_in_pixel #reading values (PIXELS)

 j heading_loop

 reading_in_pixel:
    li $t4,0 	#line
    li $t1,0 	#number of digits
    li $t3,0 	#i
    li $t5,0 	#sum
    li $t6,0 	#line count

cnvert_str_int:

lb $t2,($s2)

beq $t2,10,line	#check for newline charecter
beq $t2,0,write_in	#null term check

sub $t2,$t2,48	#ASCII to integer
mul $t4,$t4,10
add $t4,$t4,$t2	#acc the digit

addi $s2,$s2,1	#next character


j cnvert_str_int


line:	# Process a new line of pixel data
	addi $s2,$s2,1
	addi $t3,$t3,1
	add $t5,$t5,$t4	#acqr the sum
	li $t4,0		#reset the counter

	beq $t3,3,Average_pix
	j cnvert_str_int

Average_pix:
	addi $t6,$t6,1
	beq $t6,4097,write_in	## Check if 4096 lines have been processed
	
	divu $t5,$t5,3	 # Calculate the average (sum / 3)
	mflo $t4
	blt $t4,100,medium_value	#value is less than 100
	addi $s3,$s3,3 	#output buffer p
	li $t8,10
	sb $t8,($s3)
	j INT_STRING


medium_value:
	blt $t4,10,small_value ## Check if the value is less than 10

	addi $s3,$s3,2
	li $t8,10
	sb $t8,($s3)
	j INT_STRING


small_value:
	addi $s3,$s3,1

	li $t8,10
	sb $t8,($s3)
	j INT_STRING


INT_STRING:
	# # Convert integer to ASCII character and write in to output buffer
    beqz $t4, end    #true, conversion completed
    divu $t4, $t4, 10     
    mfhi $t3             
    addi $t3, $t3, 48	#no to ascii
    sb $t3, -1($s3)       
    addi $s3, $s3, -1      
    addi $t1,$t1,1

    j INT_STRING


end:
	# End of integer to string conversion
	add $s3,$s3,$t1
	addi $s3,$s3,1
	li $t1,0	#reset count
	li $t3,0	#remainder
	li $t5,0	#sum

	j cnvert_str_int

write_in:
	# write processed data to the output file
	sb $t2,($s3)
	sub $s4,$s3,$s4

	li $v0, 15
    move $a0, $s1
    la $a1, output_wrt
    move $a2, $s4
    syscall

close:
	# Close input and output files
    li $v0, 16          # syscall close
    move $a0, $s0       # input
    syscall

    li $v0, 16          
    move $a0, $s1       # output file
    syscall



 Exit:
	#end program
    li $v0, 10          # syscall code for exit
    syscall