#include <stdio.h>
extern double exp_approx(double x, int n);
extern long factorial(long x);
extern double power(double x, int n);
int main() {
    long num = 4;
    printf("%ld\n", factorial(5));
    double num2 = 2.2;
    int exp = 3;
    printf("%lf\n", power(num2,exp));
}