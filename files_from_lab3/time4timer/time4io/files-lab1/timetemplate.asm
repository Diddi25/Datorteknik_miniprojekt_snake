  # timetemplate.asm
  # Written 2015 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

.macro	PUSH (%reg)
	addi	$sp,$sp,-4
	sw	%reg,0($sp)
.end_macro

.macro	POP (%reg)
	lw	%reg,0($sp)
	addi	$sp,$sp,4
.end_macro

	.data
	.align 2
mytime:	.word 0x5957
timstr:	.ascii "text more text lots of text\0"
	.text
main:
	# print timstr
	la	$a0,timstr
	li	$v0,4
	syscall
	nop
	# wait a little
	li	$a0, 1000
	jal	delay
	nop
	# call tick
	la	$a0,mytime
	jal	tick
	nop
	# call your function time2string
	la	$a0,timstr
	la	$t0,mytime
	lw	$a1,0($t0)
	jal	time2string
	nop
	# print a newline
	li	$a0,10
	li	$v0,11
	syscall
	nop
	# go back and do it all again
	j	main
	nop
# tick: update time pointed to by $a0
tick:	lw	$t0,0($a0)	# get time
	addiu	$t0,$t0,1	# increase
	andi	$t1,$t0,0xf	# check lowest digit
	sltiu	$t2,$t1,0xa	# if digit < 10, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x6	# adjust lowest digit
	andi	$t1,$t0,0xf0	# check next digit
	sltiu	$t2,$t1,0x60	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa0	# adjust digit
	andi	$t1,$t0,0xf00	# check minute digit
	sltiu	$t2,$t1,0xa00	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x600	# adjust digit
	andi	$t1,$t0,0xf000	# check last digit
	sltiu	$t2,$t1,0x6000	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa000	# adjust last digit
tiend:	sw	$t0,0($a0)	# save updated result
	jr	$ra		# return
	nop

  # you can write your code for subroutine "hexasc" below this line
  #
hexasc:
	andi	$t0, $a1, 0xf	
	ble	$t0, 9, letterAsciis
 	#slti	$t0, $a1, 0x3a
 	#bne	$t0, $0, letterAsciis
 	addi	$t1, $t0, 0x37
	jr  	$ra

letterAsciis:
	addi	$t1, $t0, 0x30
	jr	$ra

setX:
	
	
	
time2string:
	PUSH ($a1)
	PUSH ($ra)
	addi $t0, $0, 0x00 # ASCII NUL t0 = mytime

	sb $t0, 5($a0) # stores byte #t0 = mytime, a0 = timestr
	
	add	$t4, $t4, $0
	beq	$t4, $t0, setX
	
setX:
	
	
	jal  hexasc #manipulate 1:st
	nop
	#andi $t0,$a1,0xf # check lowest digit
	#addi $t1, $t0, 0x30 # add 0x30 for ASCII
	sb $t1, 4($a0) # stores byte

	#andi $t0,$a1,0xf0 # check next digit
	srl $a1, $a1, 4 # shifts hex-digit right by 4 bits
	jal hexasc #manipulate 2:nd
	nop
	#addi $t1, $t0, 0x30 # add 0x30 for ASCII
	sb $t1, 3($a0) # stores byte
	
	addi $t0, $0, 0x3a # ASCII :
	sb $t0, 2($a0) # stores byte
			
	srl $a1, $a1, 4 # shifts hex-digit right by 4 bits
	jal hexasc #manipulate 3:rd
	nop
	sb $t1, 1($a0) # stores byte

	#andi $t0,$a1,0xf00 # check minute digit
	#srl $t0, $t0, 8 # shifts hex-digit right by 8 bits 5958
	#addi $t1, $t0, 0x30 # add 0x30 for ASCII
	srl $a1, $a1, 4 # shifts hex-digit right by 4 bits
	jal hexasc #manipulate 4:th
	nop
	sb $t1, 0($a0) # stores byte
	
	#andi $t0,$a1,0xf000 # check last digit
	#srl $t0, $t0, 12 # shifts hex-digit right by 12 bits
	#addi $t1, $t0, 0x30 # add 0x30 for ASCII
	#sb $t1, 0($a0) # stores byte
	
	POP ($ra)
	POP ($a1)

	jr $ra
	nop
	
time2string3:
	#PUSH ($s0) # saves register $s0 for reset
	#PUSH ($s1) # saves register $s1 for reset
	#lw $s0, 0($a0) # loads the first word from the adress of 0($a0) onto $s0
	#lw $s1, 4($a0) # loads the second word from the adress of 4($a0) onto $s1
	#PUSH ($a0) # saves register $a0 for reset
	PUSH ($ra) # saves register $ra for reset
	jal hexasc
	nop
	#syscall 
	POP ($ra) # resetting register $ra
	#POP ($a0) # resetting register $a0
	#sw $s0, 0($a0) # stores the word from $s0 onto the adress of 0($a0)
	#sw $s1, 4($a0) # stores the word from $s1 onto the adress of 4($a0)
	#POP ($s1) # resetting register $s1
	#POP ($s0) # resetting register $s0
	jr $ra
	nop

delay: 
	PUSH ($ra)
	add $t0, $a0, $0 #kopierar till t0
	jal while
	nop
	POP ($ra)
	jr $ra
	nop
while:
	sle $t1, $t0, $0 #om t0 (a0) är =< 0 blir t1 1 (set less or equal to zero)
	bnez $t1, back	 #om det ovan är 1 tillbaka
	nop
	addi $t0, $t0, -1
	addi $t2, $0, 0
loop:
	slti $t3, $t2, 750 #t2=0 ska inkrementeras till 750 och annars blir t3 0
	beq $t3, $0, while
	nop
	addi $t2, $t2, 1
	j loop
	nop
back: 
	jr $ra
	nop

time2string2:
	sll	$s0, $a1, 0x16
	PUSH	($s0)
	jal	hexasc
	POP	($s0)
	sb	$a0, 0($v0)
	addi	$a0, $a0, 0x3a
	sll	$s1, $a1, 0x2
	PUSH	($s1)
	jal	hexasc
	POP	($s1)
	sb	$a0, 0($v0)
	addi	$a0, $a0, 0x3a
	
