.section .data
    SYSEXIT = 60
    EXIT_SUCCESS = 0
    X0 = 2
.section .bss
.text
.globl _start
_start:
    # simple function that computes (a + b) * (a + b) 
    movq $2, %rbx
    movq $3, %rcx
    call add

  end:
    movq $SYSEXIT, %rax
    movq $EXIT_SUCCESS, %rdi
    syscall

.type add, @function
add:
    pushq %rbp        # save old base pointer
    movq  %rsp, %rbp  # make stack pointer the base pointer
    
    add %rbx, %rcx    # add numbers
    mov %rcx, %rax    # function resut is in %eax
    mul %rcx, %rax

    end_add:
        movq  %rbp, %rsp
        popq  %rbp
        ret
