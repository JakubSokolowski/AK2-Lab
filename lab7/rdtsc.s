.section .data
.section .bss 
.lcomm sum_buf, 16
.section .text

.globl rdtsc
.globl scalar_sse
.type rdtsc,@function
rdtsc:
	push %rbp
	mov %rsp, %rbp
    xor %rax, %rax
	xor %rdx, %rdx
	cpuid
	rdtsc
	mov %edx, %ecx
	shl $32, %ecx
	mov %eax, %ecx
	mov %rcx, (%rdi)
	leave
ret
scalar_sse:
	push %rbp
	mov %rsp, %rbp
	push %rsi
	push %rdi
	# %rdi *s1, %rsi *s2, %rax %rdx *size

	# Number of iterations is size / 4
	mov %rdx, %rax
	xor %rdx, %rdx
	
	# result in xmm0
	xorps %xmm0, %xmm0
	# index to next 128bit chunk
	mov $0, %rcx
	scalar_loop:
		cmp $0, %rax
		je end
		movups (%rdi,%rcx,4), %xmm1
		movups (%rsi,%rcx,4), %xmm2
		mulps %xmm1, %xmm2
		addps %xmm2, %xmm0
		dec %rax
		inc %rcx
		jmp scalar_loop
	end:
	sum_result:
		# movups %xmm0, $sum_buf
		cvtss2sd %xmm0, %xmm0
		pop %rdi
		pop %rsi
		leave
		ret
ret


