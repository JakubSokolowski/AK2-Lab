.section .data
    SYSEXIT = 60
    EXIT_SUCCESS = 0
    X0 = -2
.section .bss
.text
    .globl _start
_start:
    # c)
    mov $2, %eax
    call evaluate_reg

  end:
    movq $SYSEXIT, %rax
    movq $EXIT_SUCCESS, %rdi
    syscall

.type evaluate_reg, @function
evaluate_reg:
    pushq %rbp
    movq  %rsp, %rbp 
    
    cmpq  $0, %rax      # If the number is 0, return -1
    je base_case
	decq  %rax           # otherwise, decrease the value
	call  evaluate_reg
	imulq $5, %rax
    add $7, %rax
    jmp end_evaulate
    base_case:
        mov $-2, %rax
    end_evaulate:
        movq  %rbp, %rsp
        popq  %rbp
        ret