# deklaracja stałych
.data
STDIN = 0
STDOUT = 1
SYSREAD = 0
SYSWRITE = 1mov $SYSEXIT, %rax
mov $EXIT_SUCCESS, %rdi
syscall
SYSEXIT = 60
EXIT_SUCCESS = 0
BUFLEN = 512
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
mov $0x20, %al

# 0010 0000
# 0x20


# A - 41 - 0100 0001
# @ - 40 - 0100 0001
# print values at address in register
# x/10c $rsi
xor_loop:
    # load the character into the AH register
    movb IN_BUF(, %rdi, 1), %ah
    xorb %al, %ah
    movb %ah, OUT_BUF(, %rdi, 1)
    inc %rdi
    cmp %r8, %rdi
    jl xor_loop
# null terminate the str
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
 
