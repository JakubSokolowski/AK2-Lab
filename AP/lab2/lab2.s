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

    U8_BASE = 8
    U6_BASE = 6
    U8_LOWER_BOUND = 0x30 # ASCII char '0'
    U8_UPPER_BOUND = 0x47 # ASCII char '7'
    ZERO_CHAR = 0x30
    NEWLINE = 0xA

    err_msg: .ascii "Invalidu U8 character\n"
    err_msg_size =.-err_msg
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
  je negativity_check
  mov $0, %rax
  mov IN_BUF(, %rdi, 1), %al  # Write single char from buf to %al
  sub $0x30, %al              # Subtract zero char from ASCII value in al to get
                              # it's integer value

  cmp $8, %al                 # Integer value in %al must be between 0 and 7
  jge write_err_msg           # Error, if value is greater than 7
  cmp $0, %al                 # or smaller than 0
  jl write_err_msg
  # Validation passed, write the number to NUM_ARR, increase counters
  mov %al, NUM_ARR(, %rdi, 4) # Save one int at a time
  inc %rdi
  jmp validation_loop

negativity_check:
    mov $0, %rdi
    cmp $3, NUM_ARR(, %rdi, 4)		# Check if the first number in array is 5,6,7
                                                              # That means this U8 number is negative
    jge is_negative
    jmp is_positive

is_negative:
    # To convert it properly, need to get the number complement
    movq $0, %rdi              # Reset the counter register
    movq $1, %r11							 # Mark the number as negative

complement_loop:
    # Iterate over all the digits in arr
    cmp %r8, %rdi              # Done, if the last but one digit is reached
    je increment_last 				 # The last step is incrementing the last digit
    mov $7, %eax						   # Move the max digit of input system to eax
    sub NUM_ARR(,%rdi,4), %eax # Subtract the current digit from max digit
    mov %eax, NUM_ARR(,%rdi,4) # And place the result back into the array
    inc %rdi	STDIN					 # Inrease counter register
    jmp complemSTDIN

increment_last:STDIN
    # Increment the last digit. The digit can't be bigger than the max digit
    # for given base, if this happens, increment the prevoius digit and so on.
    dec %rdi
    increment_loop:
      # In the first iteration, rdi contains the last NUM_ARR index.
        # Iterate backwards
      cmp $0, %rdi
        je shift_and_insert					# Handle the edge case
        mov NUM_ARR(,%rdi,4), %eax	# Move the current digit. into eax
        cmp $7, %eax								# Check if the digit is max digit
        jne increment_digit				  # If it is not, break
        mov $0, %eax							  # Max digit, set current to 0
        mov %eax, NUM_ARR(, %rdi,4) # Place it back into array
        dec %rdi 										# Decrement counter, check prev digit
        jmp increment_loop

    increment_digit:
        # Increments the current digit, and places it back into array
        inc %eax
        mov %eax, NUM_ARR(, %rdi,4)
        mov $0, %rdi
        jmp convert_to_decimal

    shift_and_insert:
        # Shift all the digits right by one position
        # Insert the 1 into the first position
        mov %r8, %rdi
        shift_loop:
            cmp $0, %rdi
            je insert_front
            mov NUM_ARR(,%rdi,4), %eax # Copy the digit at current position
            inc %rdi 									 # Increase the counter and insert
            mov %eax, NUM_ARR(,%rdi,4) # at the next position
            dec %rdi									 # Decrease the counter by 2
            dec %rdi
            jmp shift_loop
        insert_front:
            movl $1, NUM_ARR(,%rdi,4)	 # Mov 1 at the front of array
            mov $0, %rdi							 # Reset the counter
            jmp convert_to_decimal

is_positive:
     movq $0, %rdi
    movq $0, %r11
    jmp convert_to_decimal

convert_to_decimal:
    # Compute the U10 value of number by iterating backwards over NUM_ARR
    mov %r8, %rdi		# Move the size of array to %rdi counter
    dec %rdi
    mov $0, %r9 		# The decimal value of number is in r9
    mov $1, %rsi    # The value of base^exponent in rsi
    mov %rsi, %r10	# The exponent multiplication counter
    mov $0, %rax		# Reset the rax register
    mov $U8_BASE, %rbx

    add NUM_ARR(,%rdi, 4), %r9	# At the last digit to result
    dec %rdi
    multiplication_loop:
        cmp $0, %rdi
        jl convert_to_base
        mov NUM_ARR(,%rdi,4), %eax # Place next digit into rax
        compute_base_exponent:		 # Compute digit * base ^ exponent
            cmp $0, %r10						 # Check if there are any mult. left
            je finished_multiplication
            mul %rbx						 # Multiply by base
            dec %r10								 # Decrease the num of mult. by base left
            jmp compute_base_exponent
    finished_multiplication:
            # At this point the value of digit * base ^ exponent for position
            # should be in %rax. Add this to final result
            add %rax, %r9
            inc %rsi   						# Next position has +1 base multiplications
            mov %rsi, %r10					# Move the num of mult. to counter
            dec %rdi 						# Decrease the current position
            jmp multiplication_loop

convert_to_base:
    # r8  - size of NUM_ARR
    # r9  - decimal value of number
    # r10 - base of system
    # rdi - current position in REV_NUM_ARR
    # r11 - signr
    # rax - divison result
    # rbx - division remainder
    mov $0, %rdi			 # Set curr. position in rev array to 0
    mov $U6_BASE, %r10
    mov %r9, %rax
    division_loop:
        mov $0, %edx
        div %r10					   # Divide number by the base. Value at position in
                                       # out base is the remainder of division - in rbx (ebx)
        mov %edx, REV_NUM_ARR(,%rdi,4) # Write digit to array
        inc %rdi					   # Increment counter
        cmp %rax, %r10 				   # Check stop condition - result < base
        jle division_loop		 	   # Result is bigger than base, keep looping
        # Stop condition reached, write division result to array
        mov %eax, REV_NUM_ARR(,%rdi,4)
        mov %rdi, %r8                  # Save the array size

reverse_array:
    mov $0 ,%eax
    mov $0, %rsi
    reverse_loop:
        cmp $0, %rdi
        jl complement_result
        mov REV_NUM_ARR(,%rdi,4), %eax
        mov %eax, NUM_ARR(,%rsi,4)
        inc %rsi
        dec %rdi
        jmp reverse_loop

complement_result:
    cmp $0, %r11			# Number is positive, go directly to conversion
    je int_to_ascii
    movq $0, %rdi
    # Number is negative, Get it's complement
    complement_loop_2:
        # Iterate over all the digits in arr
        cmp %r8, %rdi              # Done, if the last but one digit is reached
        jg increment_last_2 	   # The last step is incrementing the last digit
        mov $5, %eax			   # Move the max digit of input system to eax
        sub NUM_ARR(,%rdi,4), %eax # Subtract the current digit from max digit
        mov %eax, NUM_ARR(,%rdi,4) # And place the result back into the array
        inc %rdi									 # Inrease counter register
        jmp complement_loop_2

    increment_last_2:
        # Increment the last digit. The digit can't be bigger than the max digit
        # for given base, if this happens, increment the prevoius digit and so on.
        dec %rdi
        increment_loop_2:
          # In the first iteration, rdi contains the last NUM_ARR index.
          # Iterate backwards
          cmp $0, %rdi
            je shift_and_STDINnsert_2       # Handle the edge case
            mov NUM_ARR(,STDINrdi,4), %eax  # Move the current digit. into eax
            cmp $5, %eax STDIN              # Check if the digit is max digit
            jne incrementSTDINdigit_2       # If it is not, break
            mov $0, %eax	    		# Max digit, set current to 0
            mov %eax, NUM_ARR(, %rdi,4) # Place it back into array
            dec %rdi 	    			# Decrement counter, check prev digit
            jmp increment_loop_2

        increment_digit_2:
            # Increments the current digit, and places it back into array
            inc %eax
            mov %eax, NUM_ARR(, %rdi,4)
            mov $0, %rdi
            jmp int_to_ascii

        shift_and_insert_2:
            # Shift all the digits right by one position
            # Insert the 1 into the first position
            mov %r8, %rdi
            shift_loop_2:
                cmp $0, %rdi
                je insert_front_2
                mov NUM_ARR(,%rdi,4), %eax # Copy the digit at current position
                inc %rdi                   # Increase the counter and insert
                mov %eax, NUM_ARR(,%rdi,4) # at the next position
                dec %rdi                   # Decrease the counter by 2
                dec %rdi
                jmp shift_loop_2
            insert_front_2:
                movl $1, NUM_ARR(,%rdi,4)  # Mov 1 at the front of array
                mov $0, %rdi               # Reset the counter
                jmp int_to_ascii

int_to_ascii:
        mov $0, %rdi
    ascii_loop:
        cmp %r8, %rdi                 # Done, if the last but one char is reached
        jg write_outpt
        mov $0, %rax
        mov NUM_ARR(, %rdi, 4), %rax  # Write single char from buf to %al
        add $0x30, %rax               # Subtract zero char from ASCII value in al to get
                                      # it's integer value
        mov %al, OUT_BUF(, %rdi, 1)   # Save one char
        inc %rdi
        jmp ascii_loop

write_outpt:

    mov %rdi, %r10
    cmp $0, %r11			
    je after_prefix
    # Save the out_buf size
    movq $SYSWRITE,     %rax   # %rax - 1 (code for write)
    movq $STDOUT,       %rdi   # %rdi - file descriptor
    movq $prefix,       %rsi   # %rsi - bugger start
    movq $prefix_size,  %rdx   # %rdx - buffer size
    syscall

after_prefix:
    mov %r10, %rdi
    # Write the contents of NUM_ARR to STDOUT
    movb $NEWLINE, OUT_BUF(, %rdi, 1)
    movq $SYSWRITE,     %rax   # %rax - 1 (code for write)
    movq $STDOUT,       %rdi   # %rdi - file descriptor
    movq $OUT_BUF,      %rsi   # %rsi - buffer start
    movq $BUFFOR_SIZE,  %rdx   # %rdx - buffer size
    syscall

    movq $SYSWRITE,     %rax   # %rax - 1 (code for write)
    movq $STDOUT,       %rdi   # %rdi - file descriptor
    movq $NEWLINE,      %rsi   # %rsi - buffer start
    movq $1,  %rdx   # %rdx - buffer size
    syscall
    jmp end

write_err_msg:
    movq $SYSWRITE,     %rax   # %rax - 1 (code for # Move the buffor address to rcxwrite)
    movq $STDOUT,       %rdi   # %rdi - file descriptor
    movq $err_msg,      %rsi   # %rsi - bugger start
    movq $err_msg_size, %rdx   # %rdx - buffer size
    syscall
end:
    movq $SYSEXIT, %rax
    movq $EXIT_SUCCESS, %rdi
    syscall
