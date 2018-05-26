#include <stdio.h>
extern double exp_approx(double x, int n);
extern long factorial(long x);
extern double power(double x, int n);
int main() {
    double exponent = 2.0;
    int steps = 10;
    double approx = exp_approx(exponent, steps);
    printf("Tyler series of e ^ %lf: %lf\n", exponent, approx);
}