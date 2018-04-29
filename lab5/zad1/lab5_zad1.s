.section .data
  # scanf("%i %f %lf", &x, &y, &z, )
  format_in: .ascii "%d %f %lf\0"
  format_out: .ascii "Wynik: %f\n\0"
.section .bss
  .comm x_int, 4
  .comm y_float, 4
  .comm z_double, 8
.section .text
.globl main
main:

  # Read the numbers with scanf
  mov $0, %rax
  mov $format_in, %rdi
  mov $x_int, %rsi
  mov $y_float, %rdx
  mov $z_double, %rcx
  call scanf

  # Call function(x,y,z) from func.c
  mov $0, %rcx

  mov $2, %rax  # The number of float args
  mov x_int(,%rcx,4), %rdi
  movss y_float, %xmm0
  movsd z_double, %xmm1
  call function

  mov $1, %rax
  mov $format_out, %rdi
  call printf

  call exit
