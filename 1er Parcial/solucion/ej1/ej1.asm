section .text

global contar_pagos_aprobados_asm
global contar_pagos_rechazados_asm

global split_pagos_usuario_asm

extern malloc
extern free
extern strcmp

%define offset_monto 0
%define offset_aprobado 1
%define offset_pagador 8
%define offset_cobrador 16
%define size_of_pago 24

%define offset_cant_aprobados 0
%define offset_cant_rechazados 1
%define offset_aprobados 8
%define offset_rechazados 16
%define size_of_pagoSplitted 24

%define offset_first_lista 0

%define offset_data_lista 0
%define offset_next_elem 8

;########### SECCION DE TEXTO (PROGRAMA)

; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
; rdi <- list_t* pList
; rsi <- char* usuario
contar_pagos_aprobados_asm:
    push rbp
    sub rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8  ; alineado a 16

    mov rbx, 0  ; rbx es mi contador
    
    ; resguardo rdi y rsi
    mov r12, rdi
    mov r13, rsi

    ; me muevo al primer elemento de la lista
    mov r12, [r12 + offset_first_lista] 

.for:
    cmp r12, 0
    je .salir
    mov r14, [r12 + offset_data_lista]  ; guardo en r14 mi dato, un struct de pago
    ; quiero comparar el cobrador del dato con el usuario
    mov rdi, [r14 + offset_cobrador]    ; paso cobrador del pago como parametro
    mov rsi, r13                        ; paso usuario como segundo parametro
    call strcmp
    cmp rax, 0                          ; si rax es 0, ambos strings son iguales
    jne .seguir
    xor r15, r15
    mov r15b, byte [r14 + offset_aprobado]  ; muevo el valor de aprobado del pago
    cmp r15b, 1                             ; si es 1, fue aprobado
    jne .seguir
    add rbx, 1
.seguir:
    mov r12, [r12 + offset_next_elem]       ; avanzo al siguiente elemento
    jmp .for

.salir:
    mov rax, rbx    ; devuelvo el resultado en rax
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
contar_pagos_rechazados_asm:
    push rbp
    sub rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8  ; alineado a 16

    mov rbx, 0  ; rbx es mi contador
    
    ; resguardo rdi y rsi
    mov r12, rdi
    mov r13, rsi

    ; me muevo al primer elemento de la lista
    mov r12, [r12 + offset_first_lista] 

.for_2:
    cmp r12, 0
    je .salir_2
    mov r14, [r12 + offset_data_lista]  ; guardo en r14 mi dato, un struct de pago
    ; quiero comparar el cobrador del dato con el usuario
    mov rdi, [r14 + offset_cobrador]    ; paso cobrador del pago como parametro
    mov rsi, r13                        ; paso usuario como segundo parametro
    call strcmp
    cmp rax, 0                          ; si rax es 0, ambos strings son iguales
    jne .seguir_2
    xor r15, r15
    mov r15b, byte [r14 + offset_aprobado]  ; muevo el valor de aprobado del pago
    cmp r15b, 0                             ; si es 0, fue rechazado
    jne .seguir_2
    add rbx, 1
.seguir_2:
    mov r12, [r12 + offset_next_elem]       ; avanzo al siguiente elemento
    jmp .for_2

.salir_2:
    mov rax, rbx    ; devuelvo el resultado en rax
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
split_pagos_usuario_asm:
    push rbp
    sub rbp, rsp
    push r12
    push r13
    push rbx
    sub rsp, 8

    ;resguardo datos
    mov r12, rdi
    mov r13, rsi

    ;PRIMERO VOY A RESERVAR MEMORIA

    mov rdi, size_of_pagoSplitted
    call malloc
    mov rbx, rax    ; resguardo puntero a retornar

    mov rdi, r12
    mov rsi, r13
    call contar_pagos_aprobados_asm
    mov byte [rbx + offset_cant_aprobados], al  ; guardo la cantidad de aprobados en el struct
    imul rax, 8     ; la cantidad de aprobados por el size de un puntero (8 Bytes) es lo que va a ocupar mi array de punteros a pagos
    mov rdi, rax
    call malloc
    mov [rbx + offset_aprobados], rax   ; guardo el array de punteros a pagos aprobados en el struct

    mov rdi, r12 
    mov rsi, r13
    call contar_pagos_rechazados_asm
    mov byte [rbx + offset_cant_rechazados], al ; guardo la cantidad de rechazados en el struct
    imul rax, 8     ; la cantidad de rechazados por el size de un puntero (8 Bytes) es lo que va a ocupar mi array de punteros a pagos
    mov rdi, rax
    call malloc 
    mov [rbx + offset_rechazados], rax  ; guardo el array de punteros a pagos rechazados en el struct

    ;AHORA VOY A RECORRER LA LISTA Y ARMAR LOS ARRAYS SEGUN CORRESPONDA

    mov r12, [r12 + offset_first_lista] ; voy al primer pago de la lista

    mov r9, 0   ; offset para recorrer arrays de aprobados
    mov r8, 0   ; offset para recorrer arrays de rechazados

.for_3:
    cmp r12, 0
    je .salir_3
    mov rcx, [r12 + offset_data_lista]  ; guardo el pago
    ; quiero comparar el cobrador del dato con el usuario
    mov rdi, [rcx + offset_cobrador]    ; paso cobrador del pago como parametro
    mov rsi, r13                        ; paso usuario como segundo parametro
    call strcmp
    cmp rax, 0      ; si los strings son iguales, rax debe tener un 0
    jne .siguiente_3
    mov rcx, [r12 + offset_data_lista]  ; guardo el pago otra vez
    xor r10, r10
    mov r10b, byte [rcx + offset_aprobado]  ; muevo el valor de aprobado del pago
    cmp r10b, 1                             ; si es 1, fue aprobado
    je .esAprobado                          ; sino, sigo de laro pues es rechazado

; Si es rechazado, debo agregar el puntero del pago al array de rechazados de mi struct
.esRechazado:                               
    mov r11, [rbx + offset_rechazados]  ; guardo en r11 el puntero d elos pagos rechazados
    mov [r11 + r8], rcx                 ; rcx tiene el puntero al pago, lo guardo en el array de aprobados
    add r8, 8   ; incremento el offset para el proximo elemento
    jmp .siguiente_3

; Si es aprobado, debo agregar el puntero del pago al array de aprobados de mi struct
.esAprobado:
    ;rbx apunta a mi struct
    mov r11, [rbx + offset_aprobados]   ; guardo en r11 el puntero de los pagos aprobados
    mov [r11 + r9], rcx                 ; rcx tiene el puntero al pago, lo guardo en el array de aprobados
    add r9, 8   ; incremento el offset para el proximo elemento

.siguiente_3:
    mov r12, [r12 + offset_next_elem]   ; avanzo al siguiente elemento de la lista
    jmp .for_3

.salir_3:
    mov rax, rbx    ; retorno el puntero al struct
    add rsp, 8
    pop rbx
    pop r13
    pop r12
    pop rbp
    ret