
section .text

global invertirQW_asm

; void invertirQW_asm(uint64_t* p)

invertirQW_asm:
	push rbp
	mov rbp, rsp

	pxor xmm1, xmm1
	pxor xmm2, xmm2

	movq xmm1, QWORD [rdi]
	movq xmm2, QWORD [rdi + 8]
	;psllq xmm1, 63
	;paddq xmm1, xmm2
	movq QWORD [rdi], xmm2  
	movq QWORD [rdi + 8], xmm1  

	pop rbp
	ret
