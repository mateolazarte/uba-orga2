

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar:
NODO_LENGTH	EQU	32
LONGITUD_OFFSET	EQU	24
; 8 bytes para el puntero 'next' (tamaño hasta ahora: 8)
; 1 byte para el uint8 'categoria' (tamaño hasta ahora: 9)
; 7 bytes de padding para alinear a 8 bytes (tamaño hasta ahora: 16)
; 8 bytes para el puntero 'arreglo' (tamaño hasta ahora: 24)
; 4 bytes para el uint32 'longitud' (tamaño hasta ahora: 28)
; 4 bytes de padding para alinear a 8 bytes (tamaño total: 32 Bytes)

PACKED_NODO_LENGTH	EQU	21
PACKED_LONGITUD_OFFSET	EQU	17
; 8 bytes para el puntero 'next' (tamaño hasta ahora: 8)
; 1 byte para el uint8 'categoria' (tamaño hasta ahora: 9)
; 8 bytes para el puntero 'arreglo' (tamaño hasta ahora: 17)
; 4 bytes para el uint32 'longitud' (tamaño total: 21 Bytes)

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[rdi]
cantidad_total_de_elementos:
	push rbp
	mov rbp, rsp

	mov rax, 0 		; rax cuenta la cantidad total de elementos
	cmp rdi, 0 		; veo si la lista es null
	je salir   		; si es nula, hay 0 elementos y salgo 
					; 'je' pregunta si dos elementos son iguales
	mov rdi, [rdi]	; entro al primer nodo (es el primer objeto del struct)

while:
	add eax, DWORD [rdi + LONGITUD_OFFSET]	; sumo la longitud (DWORD especifica el tamaño: 32bits)
	mov rdi, [rdi]							; voy al siguiente nodo
	cmp rdi, 0								; veo si hay un null
	jne while								; jump if not equal

salir:
	pop rbp
	ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[rdi]
cantidad_total_de_elementos_packed:
	push rbp
	mov rbp, rsp

	mov rax, 0 				; rax cuenta la cantidad total de elementos
	cmp rdi, 0 				; veo si la lista es null
	je salir_packed   		; si es nula, hay 0 elementos y salgo 
							; 'je' pregunta si dos elementos son iguales
	mov rdi, [rdi]			; entro al primer nodo (es el primer objeto del struct)

while_packed:
	add eax, DWORD [rdi + PACKED_LONGITUD_OFFSET]	; sumo la longitud
	mov rdi, [rdi]									; voy al siguiente nodo
	cmp rdi, 0										; veo si hay un null
	jne while_packed								; jump if not equal

salir_packed:
	pop rbp
	ret

