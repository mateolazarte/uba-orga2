
section .text

global checksum_asm

; uint8_t checksum_asm(void* array, uint32_t n)

checksum_asm:
	push rbp
	mov rbp, rsp

	;cargo un registro xmm8 con ochos (para luego multiplicar):
	mov rax, 0x0008000800080008
	movq xmm8, rax
	movq xmm9, rax
	;shufpd mezcla los datos de los registros según un inmediato. En este caso, 0b01 indica que la parte baja de xmm8 debe ir a la parte alta
	shufpd xmm8, xmm8, 0b01		
	paddw xmm8, xmm9			; sumando xmm8 con xmm9 tengo en xmm8 un registro con un 8 por cada word

.for:
	movdqu xmm0, [rdi]			; 8 elementos DE A
	add rdi, 16					; muevo el puntero a B
	movdqu xmm1, [rdi]			; 8 elementos DE B
	
	paddsw xmm0, xmm1			; A + B = R
	movdqu xmm1, xmm0 			; copia de R

	pmullw xmm0, xmm8			; R * 8 (low)
	pmulhw xmm1, xmm8			; R * 8 (high)
	movdqu xmm2, xmm0 			; copia de R * 8 (low)

	punpcklwd xmm0, xmm1		; xmm0 <- R0,...,R3 * 8
	punpckhwd xmm2, xmm1		; xmm2 <- R4,...,R7 * 8

	add rdi, 16					; muevo el puntero a los primeros de C
	movdqu xmm1, [rdi]			; 4 primeros de C
	add rdi, 16					; muevo el puntero a los ultimos de C
	movdqu xmm3, [rdi]			; 4 ultimos de C

	pcmpeqd xmm0, xmm1 			; comparo los 4 primeros resultados con los 4 primeros de C
	pmovmskb eax, xmm0			; los resultados de la comparacion mas significativos en xmm0 los guardo en eax 
	cmp eax, 0xFFFF				; si eax es igual a 0xFFFF, entonces C y los resultados eran iguales
	jne .desiguales				; sino, salto a desiguales para retornar un 0

	pcmpeqd xmm2, xmm3 			; comparo los 4 ultimos resultados con los 4 ultimos de C
	pmovmskb eax, xmm2			; los resultados de la comparacion mas significativos en xmm0 los guardo en eax 
	cmp eax, 0xFFFF				; si eax es igual a 0xFFFF, entonces C y los resultados eran iguales
	jne .desiguales				; sino, salto a desiguales para retornar un 0
	
	dec rsi						; decremento la cantidad total de tandas
	add rdi, 16					; muevo el puntero a la siguiente tanda
	cmp rsi, 0					; si las tandas que quedan son 0, termino el ciclo
	jne .for					; si quedan tandas, salto al for

.iguales:
	mov rax, 1

.salir:
	pop rbp
	ret

.desiguales:
	mov rax, 0
	jmp .salir

	ret

