#include <stdio.h>


long factorial(int number);

int main(int argc, char* argv[]) {
    int number = 5;
    int result = factorial(number);
    printf("Factorial of %d is %d \n", number, result);
    return 0;
}