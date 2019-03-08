.data
.text
.global prime_factors
.type square_root @function
# Calculates a square root of number placed in eax
# Places result in %ebx
square_root:
    pushq %rbp
    movq %rsp, %rbp
    mov %eax, %ebx
    cvtsi2sd %eax, %xmm0 # (double)int
    call sqrt
    movq %xmm0, %rax
    cvttsd2si %xmm0, %eax # (float)double
    xchg %eax, %ebx
    end_square_root:
        movq %rbp, %rsp
        popq %rbp
        ret
.type prime_factors @function
prime_factors:
    push %rbp
    mov %rsp, %rbp
   
    mov %rdi, %rbx  # Place first argument (number) in %rbx
    mov %rsi ,%rcx  # Place the second argument (pointer to in array) in %rcx

    mov $0, %r8    # The number of prime factors
    mov $2, %rdi   # The loop index
    mov $0, %rax   # Current number
    mov $0, %rsi   # Index of integer array
    mov $2, %r10   # Divisor

    even_num:
        mov %rbx, %rax
        even_num_loop:      # Keep dividing the number by 2 
            mov %rax, %r11 
            mov $0, %edx
            div %r10          # Check if the number is odd
            cmp $0, %edx
            jne odd_num    
            inc %r8         # Numer is odd, 2 is a divisor, increase the counter
            movq $2, (%rcx, %rsi,4) # Place number into array
            inc %rsi
            jmp even_num_loop
    odd_num:
        # for(int i = 3; i <= sqrt(n); i += 2)
        mov %r11, %rax
        # %rax - n , %rdi , i
        mov $3, %rdi
        odd_num_loop:
            # sqrt of %rax, result in %rbx
            call square_root
            # rdi - rbx
            cmp %rbx, %rdi
            jg check_last
            # while (n%i == 0)
            # add i to factors
            # n = n/i        
            division_loop:
                mov $0, %edx
                mov %rax, %r11
                div %rdi
                cmp $0, %edx
                mov %r11, %rax
                jne next_iter
                inc %r8
                mov %rdi, (%rcx, %rsi, 4)
                inc %rsi
                mov $0, %edx
                div %rdi
                jmp division_loop
            next_iter:
                add $2, %rdi
                jmp odd_num_loop 
    # n is a prime number greater than 2
    check_last:
    cmp $2, %rax
    jle end
    mov %rax, (%rcx, %rsi, 4)
    inc %r8

    end:
    mov %r8, %rax
    mov %rbp, %rsp
    pop %rbp
    ret
