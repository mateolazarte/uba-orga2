extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global alternate_sum_4_using_c
global product_9_f

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[?], x2[?], x3[?], x4[?]
alternate_sum_4:
	;prologo
	; COMPLETAR
	push rbp
	mov rbp, rsp

	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8
	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx

	;epilogo
	; COMPLETAR
	pop rbp
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp
	
	; COMPLETAR
	call restar_c
	mov rdi, rax
	mov rsi, rdx
	call sumar_c
	mov rdi, rax
	mov rsi, rcx
	call restar_c

	;epilogo
	pop rbp
	ret



; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[?], x2[?], x3[?], x4[?]
alternate_sum_4_simplified:
	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx
	ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9], x7[?], x8[?]
alternate_sum_8:
	;prologo
	push rbp
	mov rbp, rsp

	; COMPLETAR
	mov rax, rdi

	sub rax, rsi
	
	add rax, rdx
	
	sub rax, rcx
	
	add rax, r8
	
	sub rax, r9
	;add rax, DWORD PTR [rbp + 16] ;esto no compila
	add rax,[rbp+16]
	sub rax,[rbp+24]
	;epilogo
	pop rbp
	ret

 
; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[rdi], x1[rsi], f1[xmm0]
product_2_f:

	cvtsi2ss xmm1, rsi ;De enteros a float
	mulss xmm0, xmm1
	roundss xmm0, xmm0, 3
	cvtss2si eax, xmm0 ;De float a entero
	mov [rdi], eax

	ret

;extern void product_9_f(uint32_t * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], 
	;x1[rsi], ;f1[xmm0], 
	;x2[rdx], f2[xmm1], 
	;x3[rcx], f3[xmm2], 
	;x4[r8], f4[xmm3]
	;x5[r9], f5[xmm4], 

	;x6[rbp+16], f6[xmm5]
	;x7[rbp+24], f7[xmm6]
	;x8[rbp+32], f8[xmm7],
;	;x9[rbp+40], f9[rbp+48]
product_9_f:
	;prologo
    push rbp
    mov rbp, rsp
	movsd xmm8, [rbp+48]

	;convertimos los flotantes de cada registro xmm en doubles
	; COMPLETAR
	cvtss2sd xmm0, xmm0
	cvtss2sd xmm1, xmm1
	cvtss2sd xmm2, xmm2
	cvtss2sd xmm3, xmm3
	cvtss2sd xmm4, xmm4
	cvtss2sd xmm5, xmm5
	cvtss2sd xmm6, xmm6
	cvtss2sd xmm7, xmm7
	cvtss2sd xmm8, xmm8

	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	; COMPLETAR

	mulsd xmm0, xmm1
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4
	mulsd xmm0, xmm5
 	mulsd xmm0, xmm6
	mulsd xmm0, xmm7
	mulsd xmm0, xmm8


	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	; COMPLETAR

	cvtsi2sd xmm1, rsi
	mulsd xmm0, xmm1
	cvtsi2sd xmm1, rdx
	mulsd xmm0, xmm1
	cvtsi2sd xmm1, rcx
	mulsd xmm0, xmm1
	cvtsi2sd xmm1, r8
	mulsd xmm0, xmm1
	cvtsi2sd xmm1, r9
	mulsd xmm0, xmm1
	cvtsi2sd xmm1, [rbp+16]
	mulsd xmm0, xmm1
	cvtsi2sd xmm1, [rbp+24]
	mulsd xmm0, xmm1
	cvtsi2sd xmm1, [rbp+32]
	mulsd xmm0, xmm1
	cvtsi2sd xmm1, [rbp+40]
	mulsd xmm0, xmm1

	
	; result
	movsd [rdi], xmm0
	; epilogo
	pop rbp
	ret


