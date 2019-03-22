# Reads numbers in 8-complement from stdin
# and convert them to 6-complement

.section .data

    SYSEXIT = 60
    SYSREAD = 0
    SYSWRITE = 1
    STDIN = 0
    STDOUT = 1

    BUFFOR_SIZE = 512
    EXIT_SUCCESS = 0

    RADIX = 8

    U8_LOWER_BOUND = 0x30 # ASCII char '0'
    U8_UPPER_BOUND = 0x47 # ASCII char '7'
    ZERO_CHAR = 0x30
    NEWLINE = 0xA

    err_msg: .ascii "Invalid character\n"
    err_msg_size =.-err_msg
    err_radix_msg: .ascii "Invalid raidx\n"
    err_radix_msg_size =.-err_radix_msg
    msg_radix: .ascii "Enter system radix\n"
    msg_radix_size =.-msg_radix
    msg_input: .ascii "Enter number\n"
    msg_input_size =.-msg_input
    prefix: .ascii "(5)"
    prefix_size =.-prefix
    INPUT_SIZE: .long 0
    NUM_ARR:
        .fill 100
    REV_NUM_ARR:
        .fill 100

.section .bss
    .lcomm IN_BUF,  512       # Input buffer
    .lcomm OUT_BUF,  512       # Input buffer

.text
.globl _start

_start:
# movq $SYSWRITE,      %rax   # %rax - 1 (code for # Move the buffor address to rcxwrite)
# movq $STDOUT,        %rdi   # %rdi - file descriptor
# movq $msg_radix,     %rsi   # %rsi - buffer start
# movq $msg_radix_size,%rdx   # %rdx - buffer size
# syscall

# movq $SYSWRITE,      %rax   # %rax - 1 (code for # Move the buffor address to rcxwrite)
# movq $STDOUT,        %rdi   # %rdi - file descriptor
# movq $msg_input,     %rsi   # %rsi - buffer start
# movq $msg_input_size,%rdx   # %rdx - buffer size
# syscall

# call add


  # Load necessary arguments for read SYSCALL
  # to their coresponding registers
    movq $SYSREAD,     %rax    # %rax - 0 (code for read)
    movq $STDIN,       %rdi    # %rdi - file descriptor
    movq $IN_BUF,      %rsi    # %rsi - buffer start
    movq $BUFFOR_SIZE, %rdx    # %rdx - buffer size
    syscall

    movq %rax, %r8             # Save the actual input size
    dec %r8                    # The last char is newline
                               # Don't iterate over it
    movq $0, %rdi              # Reset the counter register

# Loop through chars in buffer, and check if they match
# the system base

validation_loop:
    cmp %r8, %rdi               # Done, if the last but one char is reached
    je conversion
    mov $0, %rax
    mov IN_BUF(, %rdi, 1), %al  # Write single char from buf to %al
    sub $0x30, %al              # Subtract zero char from ASCII value in al to get
                                # it's integer value

    cmp $9, %al                 # Integer value in %al must be between 0 and 7
    jge write_err_msg           # Error, if value is greater than 7
    cmp $0, %al                 # or smaller than 0
    jl write_err_msg
    convert_chars
    # Validation passed, write the number to NUM_ARR, increase counters
    mov %al, NUM_ARR(, %rdi, 4) # Save one int at a time
    inc %rdi
    jmp validation_loop

conversion:
   call convert_to_decimal


write_radix_err_msg:
    movq $SYSWRITE,     %rax   # %rax - 1 (code for # Move the buffor address to rcxwrite)
    movq $STDOUT,       %rdi   # %rdi - file descriptor
    movq $err_radix_msg,      %rsi   # %rsi - buffer start
    movq $err_radix_msg_size, %rdx   # %rdx - buffer size
    syscall

write_err_msg:
    movq $SYSWRITE,     %rax   # %rax - 1 (code for # Move the buffor address to rcxwrite)
    movq $STDOUT,       %rdi   # %rdi - file descriptor
    movq $err_msg,      %rsi   # %rsi - buffer start
    movq $err_msg_size, %rdx   # %rdx - buffer size
    syscall
end:
    movq $SYSEXIT, %rax
    movq $EXIT_SUCCESS, %rdi
    syscall

.type convert_to_decimal, @function
convert_to_decimal:
    # r8 - size of number array
    # 
    pushq %rbp        # save old base pointer
    movq  %rsp, %rbp  # make stack pointer the base pointer

    # Compute the U10 value of number by iterating backwards over NUM_ARR
    mov %r8, %rdi		# Move the size of array to %rdi counter
    dec %rdi
    mov $0, %r9 		# The decimal value of number is in r9
    mov $1, %rsi        # The value of base^exponent in rsi
    mov %rsi, %r10	    # The exponent multiplication counter
    mov $0, %rax		# Reset the rax register
    mov $RADIX, %rbx

    add NUM_ARR(,%rdi, 4), %r9	# At the last digit to result
    dec %rdi
    multiplication_loop:
        cmp $0, %rdi
        jl convert_to_decimal_end
        mov NUM_ARR(,%rdi,4), %eax      # Place next digit into rax
        compute_base_exponent:		    # Compute digit * base ^ exponent
            cmp $0, %r10				# Check if there are any mult. left
            je finished_multiplication
            mul %rbx				    # Multiply by base
            dec %r10					# Decrease the num of mult. by base left
            jmp compute_base_exponent
    finished_multiplication:
            # At this point the value of digit * base ^ exponent for position
            # should be in %rax. Add this to final result
            add %rax, %r9
            inc %rsi   						# Next position has +1 base multiplications
            mov %rsi, %r10					# Move the num of mult. to counter
            dec %rdi 						# Decrease the current position
            jmp multiplication_loop

    convert_to_decimal_end:
        movq %r9, %rax
        movq  %rbp, %rsp
        popq  %rbp
        ret





