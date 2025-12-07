.data 
prompt: .asciiz "Enter Password: "

correct: .asciiz "Access Granted\n"
wrong: .asciiz "Access Denied\n"

buffer: .space 32
enc_pass: .asciiz "vpbu6543"
key: .word 7    #XOR key

.text
.globl main

main:

	#print prompt out
	
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
	
	#compare password with input
	
	la $t0, buffer
	la $t1, enc_pass
	lw $t7, key
	
compare_loop:
	lb $t2, 0($t1)     #encrypted char
	beq $t2, $zero, success
	
	xor $t3, $t2, $t7    #decrpt - original = encrypted XOR key
	lb $t4, 0($t0)    #input char
	
	bne $t3, $t4, fail
	
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j compare_loop
	
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