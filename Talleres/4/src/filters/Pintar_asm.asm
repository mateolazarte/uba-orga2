global Pintar_asm

;void Pintar_asm(unsigned char *src,
;              unsigned char *dst,
;              int width,
;              int height,
;              int src_row_size,
;              int dst_row_size);


; *src[rdi],
; *dst[rsi],
; width[rdx],
; height[rcx],
; src_row_size[r8],
; dst_row_size[r9]

Pintar_asm:
	push rbp
	mov rbp, rsp

	;un registro xmm8 con todas F (blanco)
	pcmpeqd xmm8, xmm8	

	;un registro xmm7 con todos 0 (negro) (la transparencia siempre es FF)
	mov rax, 0xFF000000FF000000			; cargo 64bits de pixeles negros
	movq xmm7, rax						; muevo a la parte baja de xmm6 y xmm7 los pixeles negros
	movq xmm6, rax
	shufpd xmm7, xmm7, 0b01				; muevo la parte baja de xmm7 a su parte alta
	paddw xmm7, xmm6					; sumo xmm7 con xmm6 y resulta en que xmm7 tiene 128 bits de pixeles negros

	; un registro xmm6 para borde izquierdo (N N B B)
	mov rax, 0xFFFFFFFFFFFFFFFF			; cargo 64 bits de pixeles blancos
	movq xmm5, rax						; los muevo a la parte baja de xmm5
	shufpd xmm5, xmm5, 0b01				; los muevo a la parte alta de xmm5
	paddw xmm6, xmm5					; sumo xmm6 con xmm5 y resulta en que xmm6 tiene parte alta pixeles blancos, parte baja negros

	; un registro xmm5 para borde derecho (B B N N)
	mov rax, 0xFF000000FF000000			; cargo 64bits de pixeles negros
	movq xmm5, rax						; los muevo a la parte baja de xmm5
	shufpd xmm5, xmm5, 0b01				; los muevo a la parte alta de xmm5
	mov rax, 0xFFFFFFFFFFFFFFFF			; cargo 64bits de pixeles blancos
	movq xmm4, rax						; los muevo a la parte baja de xmm4
	paddw xmm5, xmm4					; sumo xmm5 con xmm4 y resulta en que xmm5 tiene parte alta pixeles negros, parte baja blancos

	;me guardo el puntero al primer elemento de la fila
	mov rax, rsi

	;guardo la cantidad de pixeles de una fila
	mov r10, rdx

	;contador de primeras filas negras
	mov r11, 2
	
	jmp .pintarTodoNegro	; empezamos pintando la primer fila que debe ser negra

.salir:
	pop rbp
	ret
	

.pintarTodoNegro:
	movdqu [rsi], xmm7 		; pinto 4 pixeles de negro
	sub r10, 4				; resto en 4 la cantidad de pixeles que quedan por pintar en la fila
	jz .siguienteFilaNegra	
	add rsi, 16				; avanzo 16 bytes en el puntero (son los proximos 4 pixeles)
	jmp .pintarTodoNegro

.siguienteFilaNegra:
	dec r11
	jmp .siguienteFila

.pintarBordeIzquierdo:
	movdqu [rsi], xmm6		; pinto 2 pixeles de negro y 2 de blanco
	sub r10, 4
	add rsi, 16
	jmp .pintarTodoBlanco

.pintarTodoBlanco:
	movdqu [rsi], xmm8		; pinto 4 pixeles de blanco
	sub r10, 4				; resto en 4 la cantidad de pixeles que quedan por pintar en la fila
	add rsi, 16
	cmp r10, 4				; pregunto si llegué al borde derecho
	je .pintarBordeDerecho
	jmp .pintarTodoBlanco

.pintarBordeDerecho:
	movdqu [rsi], xmm5		; pinto 2 pixeles de blanco y 2 de negro
	jmp .siguienteFila

.siguienteFila:
	sub rcx, 1					; decremento en 1 la cantidad de filas que quedan por pintar
	jz .salir					; si no queda ninguna, salimos
	add rax, r9					; sumo al puntero del primer pixel de la fila lo necesario (r9) para avanzar a la siguiente
	mov rsi, rax				; lo guardo en rsi para recorrer la fila
	mov r10, rdx				; guardo la cantidad de pixeles de una fila
	cmp r11, 0					; pregunto si hay que pintar fila negra superior
	jne .pintarTodoNegro
	cmp rcx, 2					; si quedan 1 o 2 filas por pintar, son negras
	jle .pintarTodoNegro
	jmp .pintarBordeIzquierdo 	; si no es ninguna de las opciones anteriores, entonces comienzo a pintar una fila del medio


