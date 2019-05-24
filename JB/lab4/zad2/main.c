#include <stdio.h>

extern int check_exceptions();
extern int check_mode();
extern int set_mode(int mode);

extern void set_control_word(short word);


#define EMPTY_CONTROL_WORD 0b0000000000000000

#define NEAREST  0b0000000000000000
#define DOWN     0b0000010000000000
#define UP 			 0b0000100000000000
#define TRUNCATE 0b0000110000000000

#define NEAREST_F 0
#define DOWN      1
#define UP 			  2
#define TRUNCATE  3

#define PRECISION         0b0000000000100000
#define UNDERFLOW         0b0000000000010000
#define OVERFLOW 			    0b0000000000001000
#define ZERO 						  0b0000000000000100
#define DENORMALIZED 		  0b0000000000000010
#define INVALID_OPERATION 0b0000000000000001

short set_masks(short ctrl_word) {
	return  ctrl_word | 
					PRECISION |
					UNDERFLOW | 
					OVERFLOW |
					ZERO |
					DENORMALIZED | 
					INVALID_OPERATION ;
}

short get_mask_user_input(short ctrl_word) {
	  char decision;
	  printf("Set precision mask ? (y/n) \n");
		scanf("%c", &decision);
		if(decision == 'y')
			ctrl_word |= PRECISION;
		
		printf("Set underflow mask ? (y/n) \n");
		scanf("%c", &decision);
		if(decision == 'y')
			ctrl_word |= UNDERFLOW;
		
		printf("Set overflow mask ? (y/n) \n");
		scanf("%c", &decision);
		if(decision == 'y')
			ctrl_word |= OVERFLOW;

		printf("Set zero division mask ? (y/n) \n");
		scanf("%c", &decision);
		if(decision == 'y')
			ctrl_word |= ZERO;

		printf("Set denormalized mask ? (y/n) \n");
		scanf("%c", &decision);
		if(decision == 'y')
			ctrl_word |= DENORMALIZED;

		printf("Set invalid_operation mask ? (y/n) \n");
		scanf("%c", &decision);
		if(decision == 'y')
			ctrl_word |= INVALID_OPERATION;
		return ctrl_word;		
}





int main(void) {
  int option=1, mode=1;
	do {
	  printf("=== MENU: ===\n");
	  printf("1 - check rounding mode\n");
	  printf("2 - set rounding mode:\n");
		printf("3 - check precision: \n");
		printf("4 - set precision\n");
	  printf("0 - exit\n");
	  scanf("%d", &option);

	  switch(option) {
			case 1:
			    printf("\nCurrent rounding mode: ");
			    switch(check_mode()) {
			        case 0: printf("Round to nearest or even\n"); break;
			        case 1: printf("Round down\n"); break;
			        case 2: printf("Round up\n"); break;
			        case 3: printf("Truncate\n"); break;
			    }
			    break;
			case 2:
			    printf("\n0 - Round to nearest or even\n");
			    printf("1 - Round down\n");
			    printf("2 - Round up\n");
			    printf("3 - Truncate\n");
			    scanf("%d", &mode);
			    if (mode > 3 || mode < 0) 
						printf("Invalid value");
			    else 
 						set_mode(mode);
			    printf("\n");
			    break;
	  }
	} while(option!=0);
	printf("Rounding mode decided. Proceeding with program execution...");

	float b = 0.0;
	float a = 4.0;
	printf("\nEnter divisor:");
	scanf("%f", &b);
	float result = a / b;
  int ex = check_exceptions();
	if(ex == 0) {
		printf("No Exceptions");
	}
	if(ex == 1) {
		printf("Divide by zero exception");
	}
	return 0;
}
