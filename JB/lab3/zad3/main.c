#include <stdio.h>

long number = 1263;
char output_arr[10];
char rev_output_arr[10];

int main() {
    __asm__ __volatile__ ("mov %0, %%rax;"
                          "movq $0, %%rdi;"
                          "movq $8, %%r10;"
                          "division_loop: movl $0, %%edx;"
                          "div %%r10;"              
                          "add $0x30, %%edx;"
                          "mov %%dl, (%1, %%rdi,1);"
                          "inc %%rdi;" 
                          "cmp %%rax, %%r10;"
                          "jle division_loop;"
                          "add $0x30, %%eax;"
                          "mov %%al, (%1,%%rdi,1);"     
                          "movq $0, %%rax;"
                          "movq $0, %%rsi;"
                          "reverse_loop: cmp $0, %%rdi;"
                          "jl end;"
                          "mov (%1, %%rdi,1), %%al;"
                          "mov %%al, (%2, %%rsi, 1);"
                          "inc %%rsi;"
                          "dec %%rdi;"
                          "jmp reverse_loop;"
                          "end:;"
                          : 
                          : "r" (number), "r" (output_arr), "r" (rev_output_arr)
                          : "%rax", "%rdx", "%rdi", "%rsi", "%r10"
    );

    printf("Numer in base 8: %s\n", rev_output_arr);
    return 0 ;
}