extern malloc
extern free
extern fprintf
extern stack_snooper_n
extern stack_snooper

section .data
msgNull db "NULL"

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
strCmp:
	push rbp
	mov rbp, rsp

	mov rdx, 0 ;offset

bucle_cmp:
	mov cl, byte [rdi + rdx]	; guardo el char del string 'a' para despues compararlo
	cmp cl, byte [rsi + rdx]	; comparo los chars de 'a' y 'b'
	jg mayor 					; jump if greater (a > b)
	jl menor 					; jump if less (a < b)
	inc rdx 					; sumo en 1 el offset
	cmp cl, 0   				; si ambos son nulos, entonces ambos string son iguales
	jne bucle_cmp				; sino, son iguales y hay que ver el siguiente char

iguales:
	mov rax, 0
	jmp salir_cmp

mayor:
	mov rax, -1
	jmp salir_cmp

menor:
	mov rax, 1

salir_cmp:
	pop rbp
	ret

; char* strClone(char* a)
strClone:
	push rbp
	mov rbp, rsp
	;en rdi tengo el puntero

	push 0x55555555 
	;estos comentarios son para habilitar el punto 4)b)
	push 0x77777777
	push 0x55555555
	push 0x77777777

	;primero debemos calcular el largo del string
	mov rsi, 0 	; contador
bucle_size:
	mov cl, byte [rdi + rsi]	; guardo el char del string 'a' para despues compararlo
	cmp cl, 0
	je bucle_fin
	inc rsi
	jmp bucle_size

bucle_fin:
	inc rsi 		; cuento el char nulo
	push rdi		; guardo en la pila el puntero a char
	
	mov rdi, rsi	; paso como argumento en rdi la cantidad de bytes a reservar
	call malloc	WRT ..plt	; para malloc
	pop rdi			; recupero de la pila el puntero a char en rdi

	; en rax tengo el puntero al espacio reservado por malloc
	mov rsi, 0		; rsi es el offset para recorrer el string
bucle_clone:
	mov cl, byte [rdi + rsi]		; guardo en cl el siguiente char a copiar
	mov [rax + rsi], cl				; copio el char
	cmp cl, 0						; si es el char nulo, termino el programa
	je salir_clone					; jump if equal
	inc rsi							; sino, incremento para copiar el siguiente char
	jmp bucle_clone

salir_clone:
	pop rdi 
	; Estos comentarios son para habilitar el 4)b)
	pop rdi
	pop rdi
	pop rdi
	pop rbp
	ret

; void strDelete(char* a)
strDelete:
	push rbp
	mov rbp, rsp

	;en rdi tengo el puntero al char a liberar
	call free WRT ..plt

	pop rbp
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	push rbp
	mov rbp, rsp

	mov rdx, rdi	; guardo el puntero a char en rdx
	mov rcx, rsi	; guardo el puntero a FILE en rcx

	;primero veo si el string es vacio
	mov al, byte [rdi]	; copio el char en rax para luego compararlo
	cmp al, 0
	je print_null
	; si no lo es, escribimos el mensaje
	mov rdi, rcx		; el primer argumento es el puntero a FILE
	mov rsi, rdx		; el segundo argumento es el mensaje
	call fprintf WRT ..plt
	jmp salir_print

print_null:
	mov rdi, rcx		; el primer argumento es el puntero a FILE
	mov rsi, msgNull	; el segundo argumento es el mensaje
	call fprintf WRT ..plt

salir_print:
	pop rbp
	ret

; uint32_t strLen(char* a)
strLen:
	push rbp
	mov rbp, rsp
	push 0x11111111
	;estos comentarios son para habilitar el punto 4)b)
	push 0x33333333
	push 0x22222222

	mov rax, 0		; rax guarda la cantidad de caracteres y es el offset para recorrer el string
bucle_len:
    mov cl, byte [rdi + rax] 	; guardo en cl el siguiente char para luego compararlo
    cmp cl, 0            		; pregunto si llegué al final del string
    je salir_len            	; Si es nulo, salta para salir
    inc rax                 	; Incrementa el contador/offset
    jmp bucle_len

salir_len:
	push rax ;estos comentarios son para habilitar el punto 4)b)

	; snooper n = 1
	mov rdi, 1
	call stack_snooper_n wrt ..plt

	; snooper n = 2
	mov rdi, 2
	call stack_snooper_n wrt ..plt
	pop rax
	pop rdi
	pop rdi
	pop rdi
	pop rbp
	ret

; ****************
; Respuestas 4) B)
; a) - stack_snooper: imprime todos los elementos del stack frame de la función que lo llamó.
;	 - stack_snooper_n : imprime todos los elementos del stack frame de la función que lo llamó
;    y de las n funciones anteriores. 
; b) Resultados de imprimir en strLen:
;	 - El primer elemento impreso es el rbp del stack_snooper_n
;    - El segundo elemento es el viejo contenido del instruction pointer 
;	 - El tercer elemento es el rax pusheado (que guarda el resultado de strLen)
;	 - Los siguientes 3 elementos son los 3 push realizados en el epilogo
;	 - El siguiente elemento es el rbp de la funcion llamadora (strLen)
;    - Todos los demas elementos pertenecen a otros stack frames
;
; Duda: es correcto que haya un error de memoria? Usando stack_snooper no lo hay.

