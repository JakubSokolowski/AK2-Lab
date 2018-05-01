.section .data
    SYSEXIT = 60
    SYSREAD = 0
    SYSWRITE = 1
    STDIN = 0
    STDOUT = 1

    BUFFOR_SIZE = 512
    EXIT_SUCCESS = 0
    NEWLINE = 0xA
    ZERO_CHAR = 0x30
    X0 = -2
.section .bss
    .lcomm IN_BUF,  512       # Input buffer
.text
    .globl _start
_start:
    movq $SYSREAD,     %rax    # %rax - 0 (code for read)
    movq $STDIN,       %rdi    # %rdi - file descriptor
    movq $IN_BUF,      %rsi    # %rsi - buffer start
    movq $BUFFOR_SIZE, %rdx    # %rdx - buffer size
    syscall
    
    mov $IN_BUF, %rbx
    pushq %rbx             # push first argument - pointer to buf
    call  zero_str         # call the function
  end:
    movq $SYSEXIT, %rax
    movq $EXIT_SUCCESS, %rdi
    syscall

.type zero_str, @function
zero_str:
    pushq %rbp              # save old base pointer
    movq  %rsp, %rbp        # make stack pointer the base pointer
    subq  $8, %rsp          # get room for our local storage

    movq  16(%rbp), %rbx    # put first argument in %rbx
    movq  $-1, %r10         # Store current result

    # Start looping through buffer
    mov $0, %rdi
    mov $0, %rax
    mov $0, %rcx
    mov $-1, %r10
    find_zero_loop:
        mov (%rbx, %rdi, 1), %al
        inc %rdi
        cmp $ZERO_CHAR, %al    # check if char is 0
        je count_zeros
        cmp $NEWLINE, %al      # check if char is newline
        je end_zero_str
        jmp find_zero_loop     # char is not zero or newline, go next
        count_zeros:
            # found first zero
            inc %rcx
            count_loop:
                mov (%rbx, %rdi, 1), %al
                inc %rdi
                cmp $ZERO_CHAR, %al
                je count_zeros
                # char is no longer 0
                cmp %r8, %rcx
                jg new_record
                mov $0, %rcx
                dec %rdi
                jmp find_zero_loop
            new_record:
                mov %rcx, %r8
                mov $0, %rcx
                dec %rdi
                mov %rdi, %r10
                sub %r8, %r10
                jmp find_zero_loop
    end_zero_str:
    movq %r10,  %rax
    movq %rbp, %rsp
    popq %rbp
    ret 