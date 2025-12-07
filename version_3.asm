.data
prompt: .asciiz "Enter password: "
 
correct: .asciiz "Access Granted\n"
wrong: .asciiz "Access Denied\n"

buffer: .space 32

#sotred hash of the password
hash_upper: .word 0x001AE6EC
hash_lower: .word 0x3FF2D0FF

.text
.globl main

main:

	#print prompt
	
	li $v0, 4
	la $a0, prompt
	syscall
	
	#read user input
	li $v0, 8
	la $a0, buffer
	li $a1, 32
	syscall
	
	#strip newline
	
	la $t0, buffer
	
strip_newline: 
	lb $t1, 0($t0)
	beq $t1, $zero, done_strip
	beq $t1, 10, replace_null
	addi $t0, $t0, 1
	j strip_newline
	
replace_null:
	sb $zero, 0($t0)
	j done_strip

done_strip:
	
	#initialized hash = 5381 (standard djb2)
	
	li $t3, 5381   #high bits unused for now
	li $t4, 0    #high part of hash
	
	#setup pointer
	
	la $t0, buffer
	
hash_loop:
	lb $t1, 0($t0)
	beq $t1, $zero, hash_done   #ending of string
	
	
	#hash = hash * 33 + c
	#muliply lower 32 bits by 33
	
	li $t2, 33
	
	multu $t3, $t2
	mflo $t5   #low 32 bits
	mfhi $t6   #high 32 bits
	
	multu $t4, $t2
	mflo $t7  # high * 33 (lower half)
	mfhi $t8  #high * 33 (upper half)
	
	#new_high = high * 33 + overflow (low * 33)
	
	addu $t4, $t7, $t6
	addu $t4, $t4, $t8
	
	move $t3, $t5   #update low bits
	
	addu $t3, $t3, $t1  # add char
	sltu $t5, $t3, $t1  #detect overflow
	addu $t4, $t4, $t5  #carry into high part
	
	
	addi $t0, $t0, 1
	j hash_loop
	
hash_done: 

	#compare high 32 bits
	
	lw $t6, hash_upper
	bne $t4, $t6, fail
	
	#compare low 32 bits
	lw $t7, hash_lower
	bne $t3, $t7, fail
	
success:
	li $v0, 4
	la $a0, correct
	syscall
	j exit
	
fail:
	li $v0, 4
	la $a0, wrong
	syscall
	
exit:
	li $v0, 10
	syscall