#include <stdio.h>
#include <math.h>
#include <stdlib.h>

int prime_factors(int number, int* factors);

int main(int argc, char* argv[]) {
    int number = 478;
    int factors[100];
    number = atoi(argv[1]);
    int result = prime_factors(number, factors);
    printf("%d, l. czynników: %d\n", number, result);
    for(int i = 0; i < 100 ;i++) {
        if(!factors[i])
            break;
        printf("%d ",factors[i]);
    }
    printf("\n");
}