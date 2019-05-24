.section .data
    SYSEXIT = 60
    EXIT_SUCCESS = 0
.section .text
    .globl _start
_start:
    pushq $21
    call factorial
    popq %rbx

end:
    movq $SYSEXIT, %rax
    movq $EXIT_SUCCESS, %rdi
    syscall

.type factorial, @function
factorial:
    pushq %rbp                    
    movq  %rsp, %rbp

    movq  16(%rbp), %rax # This moves the first argument to %rax
    cmpq  $1, %rax       # If the number is 0, return -2
    je base_case
    decq  %rax           # Otherwise, decrease the value
    pushq %rax           # Push the arg for next call
    call  factorial
    mov 16(%rbp), %rbx
  	t2:
  	mul %rbx
    
    jmp end_factorial
    base_case: 
        mov $1, %rax
 
    end_factorial:
        mov %rbp, %rsp
        pop %rbp
        ret 
