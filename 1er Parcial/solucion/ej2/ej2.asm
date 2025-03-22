global mezclarColores

section .rodata
mayores: db 1,2,0,3,5,6,4,7,9,0xA,8,0xB,0xD,0xE,0xC,0xF
menores: db 2,0,1,3,6,4,5,7,0xA,8,9,0xB,0xE,0xC,0xD,0xF

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;void mezclarColores( uint8_t *X, uint8_t *Y, uint32_t width, uint32_t height);
; rdi <- uint8_t *X
; rsi <- uint8_t *Y
; rdx <- uint32_t width
; rcx <- uint32_t height
mezclarColores:
    push rbp
    sub rbp, rsp

    imul rdx, rcx           ; cantidad de pixeles totales

    movdqu xmm3, [mayores]  ; mascara para el primer caso
    movdqu xmm4, [menores]  ; mascara para el segundo caso
    pcmpeqd xmm10, xmm10    ; un registro con todos los bits en 1

.for:
    cmp rdx, 0
    je .salir

    movdqu xmm0, [rdi]      ; xmm0 <- |ARGB|ARGB|ARGB|ARGB| (X)

    ;PRIMERO VOY A MEZCLAR COLORES PARA TODOS LOS PIXELES
    ; Elimino la transparencia de X
    pslld xmm0, 8           ; xmm0 <- |RGB0|RGB0|RGB0|RGB0|
    psrld xmm0, 8           ; xmm0 <- |0RGB|0RGB|0RGB|0RGB|

    ; En xmm1 voy a mezclar los pixeles por si cumplen X[ij] R > X[ij] G > X[ij] B
    movdqu xmm1, xmm0       ; hago una copia de X
    pshufb xmm1, xmm3      ; mezclo X según la máscara "mayores"

    ; En xmm2 voy a mezclar los pixeles por si cumplen X[ij] R < X[ij] G < X[ij] B
    movdqu xmm2, xmm0       ; hago una copia de x
    pshufb xmm2, xmm4      ; mezclo X según la máscara "menores"

    ; Entonces, los registros me quedan así para cada caso:
    ; xmm1 <- |0BRG|0BRG|0BRG|0BRG| (caso mayores)
    ; xmm2 <- |0GBR|0GBR|0GBR|0GBR| (caso menores)
    ; xmm0 <- |0RGB|0RGB|0RGB|0RGB| (en otro caso)

    ;Ahora voy a separar R, G, y B de X para compararlos
    ;Hago 3 copias.
    movdqu xmm5, xmm0
    movdqu xmm6, xmm0
    movdqu xmm7, xmm0

    ;Despejo B
    pslld xmm5, 24
    psrld xmm5, 24

    ;Despejo G 
    pslld xmm6, 16
    psrld xmm6, 24
    movdqu xmm8, xmm6   ; copia de G

    ;Despejo R
    psrld xmm7, 16
    movdqu xmm9, xmm7   ; copia de R

    ;quiero ver si R es mayor que G
    pcmpgtd xmm7, xmm6
    ;quiero ver si G es mayor que B
    pcmpgtd xmm6, xmm5
    ;con and logico junto ambos resultados
    pand xmm7, xmm6
    ; Ahora en xmm7 tengo "unos" en los pixeles que cumplen el caso "mayores" 

    ;Repito lo anterior pero al reves, para el caso menores
    ;quiero ver si B es mayor a G
    pcmpgtd xmm5, xmm8
    ;quiero ver si G es mayor a R
    pcmpgtd xmm8, xmm9
    ;con and logico junto ambos resultados
    pand xmm8, xmm5
    ; Ahora en xmm8 tengo "unos" en los pixeles que cumplen el caso "menores"

    ; Ahora quiero un registro con los pixeles que no cumplen ninguno
    movdqu xmm9, xmm8   
    paddd xmm9, xmm7    ; sumo los casos mayores y menores
    ; xor entre xmm10 que tiene todos los bits en 1 me va a dejar en xmm9 solo aquellos que no cumplen ningun caso
    pxor xmm9, xmm10    

    ; Hasta ahora tengo
    ; xmm7 con bits en 1 para aquellos pixeles que cumplen "mayores"
    ; xmm8 con bits en 1 para aquellos pixeles quen cumplen "menores"
    ; xmm9 con bits en 1 para aquellos pixeles que no cumplen ninguno de los dos casos anteriores
    ; xmm1 <- |0BRG|0BRG|0BRG|0BRG| (caso mayores)
    ; xmm2 <- |0GBR|0GBR|0GBR|0GBR| (caso menores)
    ; xmm0 <- |0RGB|0RGB|0RGB|0RGB| (en otro caso)

    ;Ahora tengo que realizar ands logicos y quedarme con los pixeles que me interesan en cada caso
    pand xmm7, xmm1     ; me quedo con los que cumplen "mayores"
    pand xmm8, xmm2     ; me quedo con los que cumplen "menores"
    pand xmm9, xmm0     ; me quedo con los que no cumplen ninguno de los dos casos

    ;Finalmente, junto todos los resultados sumándolos
    paddd xmm7, xmm9
    paddd xmm7, xmm8

    ;Ahora xmm7 tiene el filtro correspondiente para cada pixel

    ;Aplico el filtro en "Y"
    movdqu [rsi], xmm7

    ;Avanzo
    add rdi, 16
    add rsi, 16
    sub rdx, 4
    jmp .for

.salir:
    pop rbp
    ret

