.section .data
	control_word: .short 0
	state_word: .short 0
.section .text

.global check_mode, set_mode, check_exceptions, set_control_word
.type check_mode, @function
.type set_mode, @function
.type check_exceptions, @function
.type set_control_word, @function

check_mode:
	push    %rbp
	mov     %rsp, %rbp

	mov     $0, %rax
	fstcw   control_word
	mov     control_word, %ax
	# Rounding mode bits 10,10-11
	# 0xC00 - 0000 1100 0000 0000
	and     $0xC00, %ax 
	shr     $10, %ax
  
    # 00 - Nearest, 01 - Down, 10 - Up, 11 - truncate

	mov     %rbp, %rsp
	pop     %rbp
	ret

set_mode:
	push        %rbp
	mov         %rsp, %rbp

	mov         $0, %rax
	fstcw       control_word
	mov         control_word, %ax

	# Reset rounding mode bits (10, 11) to 00 - "nearest mode"
	# 0xF3FF - 1111 0011 1111 1111
	and         $0xF3FF, %ax 

	shl         $10, %rdi
	
	# "glue" together registrs to form result
	xor         %di, %ax

	# save new control word value
	mov         %ax, control_word
	fldcw       control_word
	mov         %rbp, %rsp
	pop         %rbp
	ret


check_exceptions:
	push    %rbp
	mov     %rsp, %rbp

	mov     $0, %rax
	fstsw   state_word
	mov     state_word, %ax
	#		- 0000 0000 0000 0100
	and     $0x4, %ax git 
	shr     $10, %ax

	# fclex


	mov     %rbp, %rsp
	pop     %rbp
	ret
