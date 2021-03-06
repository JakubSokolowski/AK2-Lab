.section .data
    NUMBER = 1263
   	SYSEXIT = 60
    EXIT_SUCCESS = 0
    msg: .ascii "Hello World!!\n\0"
.section .bss
    .lcomm OUT_BUF, 64
.section .text
.globl _start
_start:


    convert_to_base:
        # r8  - size of NUM_ARR
        # r9  - decimal value of number
        # r10 - 8base of system
        # rdi - current position in REV_NUM_ARR
        # r11 - signr
        # rax - divison result
        # rbx - division remainder
        mov $0, %rdi			 # Set curr. position in rev array to 0
        mov $8, %r10
        mov $NUMBER, %rax
        division_loop:
            # Get current digit of number
            mov $0, %edx
            div %r10					# Divide number by the base. Value at position in
                                        # out base is the remainder of division - in rbx (ebx)
            add $0x30, %edx             # Digit at position is at %edx
            mov %dl, OUT_BUF(,%rdi,1)  # Write digit to array
            inc %rdi					   # Increment counter
            cmp %rax, %r10 				   # Check stop condition - result < base
            jle division_loop		 	   # Result is bigger than base, keep looping
            # Stop condition reached, write division result to array
            add $0x30, %eax
            mov %al, OUT_BUF(,%rdi,1)
            mov %rdi, %r8	
    end:
        movq $SYSEXIT, %rax
        movq $EXIT_SUCCESS, %rdi
        syscall
