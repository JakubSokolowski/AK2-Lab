.section .data
    base: .double 1.0
    num: .double 0.0
.section .text
.global exp_approx
.global factorial
.global power
.type exp_approx, @function
exp_approx:
    # %rdi - number of steps
    # %xmmo - value of exponent
    # 1 + x + x^2/2! + x^3/3!
    push %rbp
    mov %rsp, %rbp
    movsd base, %xmm2
    movsd %xmm0, num
    approx_loop:
        cmp $0, %rdi
        je end_approx
        call factorial       # Compute factorial for n, result in %rax
        movsd num, %xmm0   # Compute x ^ n, result in %xmm0
        call power
        cvtsi2sd %rax, %xmm1 # Convert the factorial into double, for division
        divsd %xmm1, %xmm0   # Divide the x ^ n by factorial, store in %xmm2
        addsd %xmm0, %xmm2
        dec %rdi
        jmp approx_loop
    end_approx:
        movsd %xmm2, %xmm0
        leave
ret
# Compute the factorial of number in %rdi and place result in %rax
.type factorial, @function
factorial:
    # %rdi - input number
    # %rax - output value
    push %rbp
    mov %rsp, %rbp
    push %rdi
    mov %rdi, %rax
    factorial_loop:
        cmp $1, %rdi
        je end_factorial
        dec %rdi
        mul %rdi
        jmp factorial_loop
    end_factorial:
        pop %rdi
        leave
ret
# Compute %xmm0 to the power of %rdi, and place result in %xmm0
.type power, @function
power:
    # %rdi - exponent
    # %xmm0 - number
    push %rbp
    mov %rsp, %rbp
    push %rdi
    movsd %xmm0, %xmm1
    power_loop:
        cmp $1, %rdi
        je end_power
        dec %rdi
        mulsd %xmm1, %xmm0
        jmp power_loop
    end_power:
    pop %rdi
    leave
ret
    
    
