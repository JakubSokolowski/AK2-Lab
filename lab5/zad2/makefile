alg_test : alg_test.o main
	ld  -o alg_test alg_test.o
alg_test.o : alg_test.s
	as -gstabs -o alg_test.o alg_test.s
main: main.c
	gcc main.c -o main -g
