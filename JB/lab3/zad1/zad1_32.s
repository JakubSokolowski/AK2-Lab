.section .data
    format_in: .ascii "%d\0"
    msg: .ascii "Hello World!\n\0"
    format_out: .ascii "Wynik: %d\n\0"

.section .bss
    .comm x_int, 4
    .comm y_float, 4
    .comm z_double, 8
    
.section .text
.globl main
main:
    # Read the numbers with scanf
   

    # Print the numbers with 
    mov $msg, %eax
    push %eax
    call printf


    call exit
