.section .data
    SYSEXIT = 60
    EXIT_SUCCESS = 0
.section .text
    .globl _start
_start:
    pushq $2
    pushq $3
    
    call mul_stack
    popq %rbx

end:
    movq $SYSEXIT, %rax
    movq $EXIT_SUCCESS, %rdi
    syscall

.type mul_stack, @function
mul_stack:
    pushq %rbp                    
    movq  %rsp, %rbp

    movq  16(%rbp), %rbx # This moves the first argument to %rax
    movq  (%rbp), %rcx

    add %rbx, %rcx    # add numbers
    mov %rcx, %rax    # function resut is in %eax
    imul %rcx, %rax

    mul_stack_end:
        movq  %rbp, %rsp
        popq  %rbp
        ret
