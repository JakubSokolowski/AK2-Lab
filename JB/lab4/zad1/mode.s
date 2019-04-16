.section .data
	control_word: .short 0
.section .text

.global check_mode, set_mode
.type check_mode, @function
.type set_mode, @function

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
