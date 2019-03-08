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
	# Wydobycie bitów trybu zaokrąglania - 10,11
	and     $0xC00, %ax # 0000 1100 0000 0000
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

	# Wyzerowanie zaokrąglania 10, 11
	# (00 - początkowo nearest)
	and         $0xF3FF, %ax # 1111 0011 1111 1111

	# Przesunięcie %rdi, tak aby "wpasował" się w
  # miejsce z zerami
	shl         $10, %rdi
	
	# Sklejenie rejestrów, wynik w %ax
	xor         %di, %ax

	# Zapis zmienionej wartości do rejestru CW
	mov         %ax, control_word
	fldcw       control_word
xor
	mov         %rbp, %rsp
	pop         %rbp
	ret
