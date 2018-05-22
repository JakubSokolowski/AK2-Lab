#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define SIZE 512
extern void rdtsc(unsigned long long *timestamp);
extern double scalar_sse(void*s1, void*s2, int size);


int get_random(int low, int up) {
    return rand() % (up + 1 - low) + low;
}

float * random_vec() { 
    float max = 10.0;
    float *t = malloc(SIZE*sizeof(float));
    int i;
    float num = 0.0;
    for(i=0; i<SIZE; i++) {
        num = (float)rand()/(float)(RAND_MAX/max);
        t[i] = num;
    } 
    return t;
}

int * random_int_vec() {
    int *t = malloc(SIZE*sizeof(int));
    int i;
    float num = 0.0;
    for(i=0; i<SIZE; i++) {
        t[i] = get_random(0,10);
    } 
    return t;
}


double scalar_normal(float*s1, float*s2, int size) {
    double prod; 
    for(int i = 0; i < size; i++)
        prod += s1[i] * s2[i]; 
    return prod;
}

void rdtsc_test() {
    unsigned long long timestamp = 0;
    unsigned long long timestamp2 = 0;
    printf("Timestamp before: %llu\n", timestamp);
    rdtsc(&timestamp);
    printf("Timestamp 1: %llu\n", timestamp);
    rdtsc(&timestamp2);
    printf("Timestamp 2: %llu\n", timestamp2);
    printf("Difference in cycles: %llu\n", timestamp2 - timestamp);
}
int main (void) {  
    srand((unsigned int)time(NULL));
    float* s1 = random_vec();
    float* s2 = random_vec(); 
   
    unsigned long long start_clocks = 0, end_clocks = 0;
    rdtsc(&start_clocks);
    double result = scalar_normal(s1,s2,SIZE);
    rdtsc(&end_clocks);
    printf("Result: %f\nNormal operations clocks: %llu\n", result, end_clocks - start_clocks);
    rdtsc(&start_clocks);
    result = scalar_sse(s1,s2,SIZE);
    rdtsc(&end_clocks);
    printf("Result: %f\nSSE operations  clocks: %llu\n", result, end_clocks - start_clocks);
    //rdtsc_test();
    free(s1);
    free(s2);
    return 0;
}