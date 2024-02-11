  # analyze.asm
  # This file written 2015 by F Lundevall
  # Copyright abandoned - this file is in the public domain.

	.text
main:
	li	$s0,0x30	#30 = 48, corresponds to ascii code 0
loop:
	move	$a0,$s0		# copy from s0 to a0
	
	li	$v0,11		# syscall with v0 = 11, which is the system call number to print out ascii characters,
	syscall			# one byte from a0 to the Run I/O window
				# 1 byte = 8 b

	addi	$s0,$s0,0x3	# what happens if the constant is changed?
	
	li	$t0,0x5d	#5b = 91, corresponds to ascii code Z
	bne	$s0,$t0,loop
	nop			# delay slot filler (just in case)

stop:	j	stop		# loop forever here
	nop			# delay slot filler (just in case)

