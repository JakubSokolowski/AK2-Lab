.section .data
  FREAD = 0
  FWRITE = 1
  SYSREAD = 0
  SYSWRITE = 1
  SYSOPEN = 2
  SYSCLOSE = 3
  SYSEXIT = 60
  EXIT_SUCCESS = 0
  BUFFOR_SIZE = 512


  FILE_IN: .ascii "in.txt\0"
  FILE_OUT: .ascii "out.txt\0"
  HEX_CHARS: .ascii "0123456789ABCDEF"
.section .bss
  .lcomm IN_BUF, 512
  .lcomm FIRST_NUM_BUFF, 512
  .lcomm SECOND_NUM_BUFF, 512
  .lcomm OUT_BUF, 512
  .lcomm OUT_HEX_BUF, 512
  .comm SUM_LEN, 4
.section .text

.globl _start
_start:

open_in:
  # Open the input file with 2 base 4 numbers
  mov $SYSOPEN, %rax # OPEN syscall
  mov $FILE_IN, %rdi # Filename
  mov $FREAD,   %rsi # Read
  mov $0,    %rdx    # Mode
  syscall
  mov %rax, %r8      # Save the file descriptor from OPEN
read_in:
  movq $SYSREAD,     %rax    # %rax - 0 (code for read)
  movq %r8,          %rdi    # %rdi - file descriptor
  movq $IN_BUF,      %rsi    # %rsi - buffer start
  movq $BUFFOR_SIZE, %rdx    # %rdx - buffer size
  syscall

  mov %rax, %r9             # Save the num of read bytes
  mov $0, %rax
  mov $0, %rbx
close_in:
  mov $SYSCLOSE, %rax # Pierwszy parametr - numer wywołania
  mov %r8, %rdi       # Drugi parametr - ID otwartego pliku
  syscall

read_first_number:
  # The numbers in file are separated by /n, so for exeample:
  # 2 8 digit numbers will take 18 bytes of space
  # r9 is number of bytes. Do get index from number of bytes, decrease
  # the value in r9 by 2 - ommiting newline and indexing from 0
  # %rdi - IN_BUF pointer
  # %rsi - FIRST_NUM_BUFF pointer

  mov $0,   %rax     # Reset the 'char' register
  mov %r9,  %rdi     # Skopiowanie liczby bajtów do licznika
  sub $2,   %rdi     # Indeks ostatniego znaku drugiej liczby w IN_BUF
  mov $0,   %rsi     # Początek FIRST_NUM_BUFF
  mov $0,   %rcx     # Wartość przesunięcia
  mov $0,   %r10     # Długość pierwszej liczby (bity)

  # Wczytanie liczb o podstawie 4 z pliku, i wpisanie ich do bufora jako
  # liczby o podstawie 16 w konwencji Little Endian.
  # Przykładowa liczba w 4: 1231 2123, bin: 01101101 10011011
  # Każde 8 bitów reprezentuje 2 cyfry w systemie 16-kowym
  # Używając konwencji Little Endian, liczba zostanie zapisana w pamięci jako
  # bin: 10011011 01101101
  read_char:
    # Wczytanie do rejestru 4 znaków
    mov IN_BUF(,%rdi,1), %al  # Wczytanie znaku do al
    cmp $0xa,  %al            # Sprawdzenie, czy znak to '\n'
    je write_last
    add $2, %r10
    sub $0x30, %al            # Zakładamy że znak jest cyfrą
                              # Konwersja znaku na cyfrę przez odjęcie '0'
    cmp $6, %rcx              # Shift offset equal to 0, indicates that
                              # %al register is full
    jg write_byte
    shlb %cl, %al             # Każda cyfra zapisana jest na 2 bitach
                              # Wydobycie tych dwóch bitów przez przesunięcie
    or %al, %bl               # i "sklejenie"
    add $2, %cl
    dec %rdi
    jmp read_char
  write_byte:
    mov %bl, FIRST_NUM_BUFF(,%rsi,1)
    mov $0, %bl
    inc %rsi
    mov $0, %rcx
    jmp read_char
  write_last:
    mov %bl, FIRST_NUM_BUFF(,%rsi,1)
    mov $0, %bl
    mov $0, %rsi
    mov $0, %rcx
    jmp read_second_number
read_second_number:
  mov $0,   %rax     # Reset the 'char' register
  mov $0,   %rsi     # Początek SECOND_NUM_BUFF
  mov $0,   %rcx     # Wartość przesunięcia
  mov $0,   %r11     # Długość drugiej liczby (bity)
  dec %rdi           # Pominięcie \n

  # Read the base 4 numbers from file, and write it to buffers as hex number
  # Wczytanie liczb o podstawie 4 z pliku, i wpisanie ich do bufora jako
  # liczby o podstawie 16 w konwencji Little Endian.
  # Przykładowa liczba w 4: 1231 2123, bin: 01101101 10011011
  # Każde 8 bitów reprezentuje 2 cyfry w systemie 16-kowym
  # Używając konwencji Little Endian, liczba zostanie zapisana w pamięci jako
  # bin: 10011011 01101101

  read_char_2:
    # Wczytanie do rejestru 4 znaków
    cmp $0, %rdi
    jl write_last_2
    mov IN_BUF(,%rdi,1), %al  # Wczytanie znaku do al
    sub $0x30, %al            # Zakładamy że znak jest cyfrą
                              # Konwersja znaku na cyfrę przez odjęcie '0'
    add $2, %r11
    cmp $6, %rcx              # Shift offset equal to 0, indicates that
                              # %al register is full
    jg write_byte_2
    shlb %cl, %al             # Każda cyfra zapisana jest na 2 bitach
                              # Wydobycie tych dwóch bitów przez przesunięcie
    or %al, %bl               # i "sklejenie"
    add $2, %cl
    dec %rdi
    jmp read_char_2
  write_byte_2:
    mov %bl, SECOND_NUM_BUFF(,%rsi,1)
    mov $0, %bl
    inc %rsi
    mov $0, %rcx
    jmp read_char_2
  write_last_2:
    mov %bl, SECOND_NUM_BUFF(,%rsi,1)
    mov $0, %bl
    mov $0, %rsi
    mov $0, %rcx

add_numbers:
  clc     # Wyzerowanie flagi przeniesienia
  pushfq  # Umieszczenie rejestru flag na stosie
  mov $0, %rsi # LE, iteracja od początku bufora
  adding_loop:
    mov FIRST_NUM_BUFF(, %rsi, 8), %rax
    mov SECOND_NUM_BUFF(, %rsi, 8), %rbx
    popfq
    adc %rbx, %rax
    pushfq
    mov %rax, OUT_BUF(,%rsi, 8)
    inc %rsi
    cmp $64, %rsi
    jl adding_loop

convert_hex:
  mov $0, %rdi
  mov $0, %rsi

  mov $0, %rax
  mov $0, %rbx
  mov $0, %rcx
  convert_loop:
  mov OUT_BUF(,%rdi, 1), %al
  mov %al, %bl
  shr $4, %bl
  and $0b1111, %al
  and $0b1111, %bl
  mov HEX_CHARS(,%rax,1), %cl
  mov %cl, OUT_HEX_BUF(,%rsi,1)
  inc %rsi
  mov HEX_CHARS(,%rbx,1), %cl
  mov %cl, OUT_HEX_BUF(,%rsi,1)
  inc %rsi
  inc %rdi
  cmp $512, %rdi
  jl convert_loop

reverse_out:
  mov $0, %rsi
  mov $512, %rdi
  mov $0, %rax
  mov $0, %rbx
  mov $0, %rcx
  reverse_loop:
    cmp $0 ,%rdi
    jl end_reverse
    mov OUT_HEX_BUF(,%rdi,1), %al
    dec %rdi
    cmp $'0', %al
    jne place_char
    cmp $0, $rcx
    je reverse_loop
    place_char:
      mov $1, %rcx
      mov %al, OUT_BUF(,%rsi,1)
      inc %rsi
      jmp reverse_loop
  end_reverse:
   movb $0x0A, OUT_BUF(,%rsi,1)
   inc %rsi
   mov $0, %rdi
   mov %rsi, %rbx



open_out:
  mov $SYSOPEN,  %rax # OPEN syscall
  mov $FILE_OUT, %rdi # filename
  mov $FWRITE,   %rsi # Read
  mov $0644,     %rdx # mode
  syscall
  mov %rax, %r9       # Save the file descriptor from OPEN
write_out:
  movq $SYSWRITE,    %rax    # %rax - 0 (code for read)
  movq %r9,          %rdi    # %rdi - file descriptor
  movq $OUT_BUF,     %rsi    # %rsi - buffer start
  movq %rbx,     %rdx    # %rdx - buffer size
  syscall
close_out:
  mov $SYSCLOSE, %rax # Pierwszy parametr - numer wywołania
  mov %r9, %rdi       # Drugi parametr - ID otwartego pliku
  mov $0, %rsi
  mov $0, %rdx
  syscall

  mov $SYSEXIT, %rax
  mov $EXIT_SUCCESS, %rdi
  syscall
