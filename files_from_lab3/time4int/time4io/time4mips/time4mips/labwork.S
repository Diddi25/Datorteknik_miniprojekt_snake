  # labwork.S
  # Written 2015-2017 by F Lundevall
  # Skeleton file for IS1200/IS1500 lab 1.
  # The macros PUSH and POP are in the public domain.
  # Please add your own code at the end of the file.

  #
  # Please keep the two macros PUSH and POP unchanged
  #
  .global hexasc
  .global time2string
  .global delay
  .global enable_interrupt
  
.macro	PUSH reg
	addi	$sp,$sp,-4
	sw	\reg,0($sp)
.endm

.macro	POP reg
	lw	\reg,0($sp)
	addi	$sp,$sp,4
.endm
  #
  # Please add your own code below this line
  #
  .data
	.align 2
mytime:	.word 0x5957
timstr:	.ascii "text more text lots of text\0"
  .text

hexasc:
	addi $t0, $0, 0x00 # ASCII NUL t0 = mytime
	sb $t0, 5($a0) # stores byte #t0 = mytime, a0 = timestr

	andi $t0,$a1,0xf # check lowest digit
	addi $t1, $t0, 0x30 # add 0x30 for ASCII
	sb $t1, 4($a0) # stores byte

	andi $t0,$a1,0xf0 # check next digit
	srl $t0, $t0, 4 # shifts hex-digit right by 4 bits
	addi $t1, $t0, 0x30 # add 0x30 for ASCII
	sb $t1, 3($a0) # stores byte

	addi $t0, $0, 0x3a # ASCII :
	sb $t0, 2($a0) # stores byte

	andi $t0,$a1,0xf00 # check minute digit
	srl $t0, $t0, 8 # shifts hex-digit right by 8 bits 5958
	addi $t1, $t0, 0x30 # add 0x30 for ASCII
	sb $t1, 1($a0) # stores byte

	andi $t0,$a1,0xf000 # check last digit
	srl $t0, $t0, 12 # shifts hex-digit right by 12 bits
	addi $t1, $t0, 0x30 # add 0x30 for ASCII
	sb $t1, 0($a0) # stores byte

	jr $ra
	nop

delay: 
	PUSH $ra
	add $t0, $a0, $0
	jal while
	nop
	POP $ra
	jr $ra
	nop
while:
	sle $t1, $t0, $0 #om t0 (a0) �r =< 0 blir t3 1
	bnez $t1, back	 #om det ovan �r 1 tillbaka
	nop
	addi $t0, $t0, -1
	addi $t2, $0, 0
loop:
	slti $t3, $t2, 750
	beq $t3, $0, while
	nop
	addi $t2, $t2, 1
	j loop
	nop
back: 
	jr $ra
	nop

time2string:
	#PUSH ($s0) # saves register $s0 for reset
	#PUSH ($s1) # saves register $s1 for reset
	#lw $s0, 0($a0) # loads the first word from the adress of 0($a0) onto $s0
	#lw $s1, 4($a0) # loads the second word from the adress of 4($a0) onto $s1
	#PUSH ($a0) # saves register $a0 for reset
	PUSH $ra # saves register $ra for reset
	jal hexasc
	nop
	#syscall 
	POP $ra # resetting register $ra
	#POP ($a0) # resetting register $a0
	#sw $s0, 0($a0) # stores the word from $s0 onto the adress of 0($a0)
	#sw $s1, 4($a0) # stores the word from $s1 onto the adress of 4($a0)
	#POP ($s1) # resetting register $s1
	#POP ($s0) # resetting register $s0
	jr $ra
	nop
	
enable_interrupt:
	ei
	jr $ra
	nop
