#include <stdio.h>

extern int check_mode();
extern int set_mode(int mode);

int main(void) {
  int option=1, mode=1;
	do {
	  printf("=== MENU: ===\n");
	  printf("1 - check rounding mode\n");
	  printf("2 - set rounding mode:\n");
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
	return 0;
}
