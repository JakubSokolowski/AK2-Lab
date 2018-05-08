.section .data
    SYSEXIT = 60
    EXIT_SUCCESS = 0
.section .text
    .globl _start
_start:
    pushq $2
    call evaluate_stack
    popq %rbx

end:
    movq $SYSEXIT, %rax
    movq $EXIT_SUCCESS, %rdi
    syscall

.type evaluate_stack, @function
evaluate_stack:
    pushq %rbp                    
    movq  %rsp, %rbp

    movq  16(%rbp), %rax # This moves the first argument to %rax
    cmpq  $0, %rax       # If the number is 0, return -2
    je base_case_2
    decq  %rax           # Otherwise, decrease the value
    pushq %rax           # Push the arg for next ca;;
    call  evaluate_stack
    imulq $5, %rax
    add $7, %rax
    jmp end_evaulate_stack
    base_case_2:        # last call to factorial
        mov $-2, %rax
 
    end_evaulate_stack:
        movq %rbp, %rsp  
        popq %rbp
        popq %rbx   # Save the return adress
        push %rax   # Push the return value
        push %rbx   # Push the return adress

        ret