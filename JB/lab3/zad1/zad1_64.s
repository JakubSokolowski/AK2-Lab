 .data
    format_out: .ascii "%d\n\0"

.text
.globl main
main:
    # Read the numbers with scanf
   

    # Print the numbers with 
    mov $0, %eax
    mov $format_out, %edi
    mov $1001, %esi
    call printf

    call exit
