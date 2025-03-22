global temperature_asm

section .data

section .text
;void temperature_asm(unsigned char *src,
;              unsigned char *dst,
;              int width,
;              int height,
;              int src_row_size,
;              int dst_row_size);


; *src[rdi], puntero de entrada
; *dst[rsi], puntero de salida
; width[rdx],
; height[rcx],
; src_row_size[r8], Representa el ancho de Bytes por fila (src)
; dst_row_size[r9] " " (dst)

temperature_asm:
	push rbp ; Inizializo el Stack Frame 
	mov rbp, rsp 
	push r12
	push r13
	push r14

	;cargo un registro xmm4 con ochos (para luego multiplicar):
	mov rax, 0x0000000300000003
	movq xmm4, rax
	movq xmm5, rax
	;shufpd mezcla los datos de los registros según un inmediato. En este caso, 0b01 indica que la parte baja de xmm8 debe ir a la parte alta
	shufpd xmm4, xmm4, 0b01		
	paddw xmm4, xmm5			; sumando xmm8 con xmm9 tengo en xmm8 un registro con un 8 por cada word
	cvtdq2pd xmm4, xmm4			; pasamos a flotante			

	; Falta los iteraciones y los cambios de desplazamientos para [rdi]
	mov r12, rsi
	mov r13, rdx 
	mov r14, rdi

.for:
	movq xmm0, [r14] ;Paso Quadwords tq abarca pixel(i,j) y pixel(i,j+1)
	movq xmm1, [r14]
	shufpd xmm1, xmm1, 0b01
	paddw xmm0, xmm1	; xmm0 = | A:R:G:B | A:R:G:B | A:R:G:B | A:R:G:B |
	movaps xmm1, xmm0 ;   xmm1 = | A:R:G:B | A:R:G:B | A:R:G:B | A:R:G:B |
	pslld xmm1, 8 ;       xmm1 = | R:G:B:0 | R:G:B:0 | R:G:B:0 | R:G:B:0 |  QUIERO QUEDARME SOLO CON B
	movaps xmm2, xmm1;    xmm2 = | R:G:B:0 | R:G:B:0 | R:G:B:0 | R:G:B:0 |  QUIERO QUEDARME SOLO CON G
	movaps xmm3, xmm1; 	  xmm3 = | R:G:B:0 | R:G:B:0 | R:G:B:0 | R:G:B:0 |  QUIERO QUEDARME SOLO CON R

	; xmm1 - B
	pslld xmm1, 16 ; 	  xmm1 = | B 0 0 0 | B 0 0 0 | B 0 0 0 | B 0 0 0 | 
	psrld xmm1, 24 ; 	  xmm1 = | 0 0 0 B | 0 0 0 B | 0 0 0 B | 0 0 0 B | 

	; xmm2 - G
	pslld xmm2, 8;       xmm2 = | G:B 0 0 | G:B 0 0 | G:B 0 0 | G:B 0 0 | 
	psrld xmm2, 24 ; 	 xmm1 = | 0 0 0 G | 0 0 0 G | 0 0 0 G | 0 0 0 G | 

	; xmm3 - R
	psrld xmm3, 24;      xmm3 = | 0 0 0 R | 0 0 0 R | 0 0 0 R | 0 0 0 R |

	paddd xmm1, xmm2
	paddd xmm1, xmm3;    xmm1 = | B+G+R | B+G+R | B+G+R | B+G+R |

	;pslld xmm1, 1
	cvtdq2pd xmm1, xmm1  ; convierto ambas sumas a punto flotante
	divpd xmm1, xmm4	; divido la suma por 3
	roundpd xmm1, xmm1, 3  ; truncar los valores hacia abajo
	cvtpd2dq xmm1, xmm1 ; convierto los resultados en enteros

	; xmm1 = | 0 0 0 0 | 0 0 0 0 | 0 0 0 T2 | 0 0 0 T1 |

	movd eax, xmm1 		; guardo el primer resultado para compararlo
	call .comparar
	movd xmm0, r10d
	movd [r12], xmm0
	add r12, 4		; avanzo para escribir el siguiente pixel destino
	psrldq xmm1, 4 ; xmm1 = | 0 0 0 0 | 0 0 0 0 | 0 0 0 0 | 0 0 0 T2 |
	movd eax, xmm1
	call .comparar
	movd xmm0, r10d
	movd [r12], xmm0
	add r12, 4		; avanzo para escribir el siguiente pixel destino
	add r14, 8		; avanzo para leer los proximos 2 pixeles
	sub r13, 2		; resto el contador de pixeles por linea
	cmp r13, 0		; si quedan pixeles en la linea, repito el ciclo
	jne .for
	add rsi, r9		; salto a la siguiente linea src
	add rdi, r8 	; salto a la siguiente linea dst
	mov r12, rsi	; r12 recorre la linea de src
	mov r13, rdx 	; r13 tiene la cantidad de pixeles por linea
	mov r14, rdi	; r14 recorre la linea de dst
	sub rcx, 1		; rcx tiene las lineas restantes 
	cmp rcx, 0		; si quedan lineas, se repite el ciclo
	jne .for

.fin:
	pop r14 
	pop r13
	pop r12
	pop rbp
    ret

.comparar:
	cmp eax, 32
	jl .caso1
	cmp eax, 96
	jl .caso2
	cmp eax, 160
	jl .caso3
	cmp eax, 224
	jl .caso4
	jmp .caso5



.caso1: ; t < 32  
	shl eax, 2		; eax = T * 4 	
	add eax, 128	; eax = T * 4 + 128
	mov r10d, 0xFF000000
	add r10d, eax
	ret


.caso2: ;  32 <= t < 96 
	sub eax, 32
	shl eax, 2      
	mov r10d, 0x00000000 
	add r10d, eax	
	shl r10d, 8
	mov r11d, 0xFF0000FF
	add r10d, r11d
	ret

.caso3: ;  96 <= t < 160
	; red
	mov ebx, eax
	sub eax, 96
	shl eax, 2
	;blue
	sub ebx, 96
	shl ebx, 2
	mov ebp, 255
	sub ebp, ebx

	mov r10d, 0xFF00FF00
	add r10d, ebp
	mov r11d, 0x00000000
	add r11d, eax
	shl r11d, 16
	add r10d,r11d
	ret

.caso4: ; 160 ≤ t < 224
	sub eax, 160
	shl eax, 2
	mov ebx, 255
	sub ebx, eax
	mov r11d, 0x00000000
	add r11d, ebx
	shl r11d, 8 
	mov r10d, 0xFFFF0000
	add r10d, r11d
	ret

.caso5: ; cc.
	sub eax, 224
	shl eax, 2
	mov ebx, 255
	sub ebx, eax
	mov r11d, 0x00000000
	add r11d, ebx
	shl r11d, 16
	mov r10d, 0xFF000000
	add r10d, r11d
	ret


