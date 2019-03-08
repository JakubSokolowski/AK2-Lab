# deklaracja stałych
.data
STDIN = 0
STDOUT = 1
SYSREAD = 0
SYSWRITE = 1
SYSEXIT = 60
EXIT_SUCCESS = 0
BUFLEN = 512
SHIFT = 4
UPPERCASE_UPPER_BOUND = 0x5A
LOWERCASE_UPPER_BOUND = 0x7A

# allocate memory for input and outut buffers
.bss
.comm IN_BUF, 512
.comm OUT_BUF, 512
 
.text
.globl _start
 
_start:
# load the char sequence from stdin
mov $SYSREAD, %rax
mov $STDIN,   %rdi
mov $IN_BUF,  %rsi
mov $BUFLEN,  %rdx
syscall
 
# Store the length of input sequence in R8 and reset the RDI counter register
mov %rax, %r8
mov $0,   %rdi
mov $0,   %rsi

# A - 41 - 0100 0001
# @ - 40 - 0100 0001
# print values at address in register
# x/10c $rsi
xor_loop:
    # load the character into the AH register
    movb IN_BUF(, %rdi, 1), %ah
    # Two cases for going out of range: 
    # Uppercase letters and lowercase letters
    mov %ah, %al
    cmp $0x20, %al
    je skip_space
    # Apply the shift to value
    ADD $SHIFT, %ah
    cmpb $0x5A, %al
    jle uppercase 
    lowercase:
    # The value is lowercase, check if after adding
    # it exceeds the upper_bound, if so subtract 
    cmpb $0x7A, %ah
    jl end_loop
    sub $26, %ah
    jmp end_loop   
    uppercase:
    # The value is uppercase, check if after adding
    # it exceeds the upper_bound, if so subtract
    cmpb $0x5A, %ah
    jl end_upper
    sub $26, %ah
    end_upper:
    xorb $0x20, %ah 
    end_loop:
    movb %ah, OUT_BUF(, %rsi, 1)
    inc %rsi
    skip_space:
    inc %rdi
    cmp %r8, %rdi
    jl xor_loop

dec %rdi
movb $0xA, IN_BUF(, %rdi, 1)
# display the output buffer
mov $SYSWRITE, %rax
mov $STDOUT, %rdi
mov $OUT_BUF, %rsi
mov %r8, %rdx
syscall

mov $SYSEXIT, %rax
mov $EXIT_SUCCESS, %rdi
syscall
