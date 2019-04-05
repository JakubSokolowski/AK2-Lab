.data
.text
.global factorial
.type factorial, @function
factorial:
    pushq %rbp                    
    movq  %rsp, %rbp
    pushq %rdi  
    call factorial_2
    mov %rbp, %rsp
    pop %rbp
    ret 

.type factorial_2, @function
factorial_2:
    pushq %rbp                    
    movq  %rsp, %rbp

    movq  16(%rbp), %rax # This moves the first argument to %rax
    cmpq  $1, %rax       # If the number is 0, return -2
    je base_case
    decq  %rax           # Otherwise, decrease the value
    pushq %rax           # Push the arg for next call
    call  factorial_2
    mov 16(%rbp), %rbx
  	t2:
  	mul %rbx
    
    jmp end_factorial_2
    base_case: 
        mov $1, %rax
 
    end_factorial_2:
        mov %rbp, %rsp
        pop %rbp
        ret 
