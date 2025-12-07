.data
prompt: .asciiz "Enter password: "

correct: .asciiz "Access Granted\n"
wrong: .asciiz "Access Denied\n"

 buffer: .space 32     #user input buffer
 password: .asciiz "abcd1234" 
 
 .text
 .globl main
 
 main:
 	#print prompt
 	li $v0, 4
 	la $a0, prompt
 	syscall
 	
 	#string into buffer
 	li $v0, 8
 	la $a0, buffer
 	li $a1, 32
 	syscall
 	
 	#rove trailing newline
 	la $t0, buffer
 	strip_newline:
 		lb $t1, 0($t0)
 		beq $t1, $zero, done_strip  #reached end of string
 		beq $t1, 10, replace_null   # ASCII 10 = '\n'
 		addi $t0, $t0, 1
 		j strip_newline
 	
 	replace_null:
 		sb $zero, 0($t0)
 		j done_strip
 	
 	done_strip:
 	
 	#compare input with correct password
 	la $t0, buffer    #pointer for user input
 	la $t1, password  #pointer for correct password
 	
 compare_loop:
 	lb $t2, 0($t0)    # char from input
 	lb $t3, 0($t1)    # char from correct password
 	
 	bne $t2, $t3, wrong_label   # mismatch
 	beq $t2, $zero, correct_label  # both 0 == correct
 	
 	addi $t0, $t0, 1
 	addi $t1, $t1, 1
 	j compare_loop
 	
 correct_label:
 	li $v0, 4
 	la $a0, correct
 	syscall
 	j exit
 	
 wrong_label:
 	li $v0, 4 
 	la $a0, wrong
 	syscall
 	
 exit:
 	li $v0, 10
 	syscall
