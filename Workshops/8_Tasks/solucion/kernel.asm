; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================
%include "print.mac"

global start

; COMPLETAR - Agreguen declaraciones extern según vayan necesitando
extern GDT_DESC
extern IDT_DESC
extern screen_draw_layout
extern idt_init
extern pic_reset
extern pic_enable
extern mmu_init_kernel_dir
extern copy_page
extern mmu_init_task_dir
extern tss_init
extern tasks_screen_draw
extern sched_init
extern tasks_init

; COMPLETAR - Definan correctamente estas constantes cuando las necesiten
; INDICE 1, GDT, PROTECCION 0
%define CS_RING_0_SEL (1 << 3)
; INDICE 3, GDT, PROTECCION 0      
%define DS_RING_0_SEL (3 << 3)

%define TSS_INITIAL_SEL (11 << 3)
%define TSS_IDLE_SEL (12 << 3)

BITS 16
;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
start_rm_msg db     'Iniciando kernel en Modo Real'
start_rm_len equ    $ - start_rm_msg

start_pm_msg db     'Iniciando kernel en Modo Protegido'
start_pm_len equ    $ - start_pm_msg

;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;

;; Punto de entrada del kernel.
BITS 16
start:
    ; COMPLETAR - Deshabilitar interrupciones
    cli

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO REAL
    ; (revisar las funciones definidas en print.mac y los mensajes se encuentran en la
    ; sección de datos)
    print_text_rm start_rm_msg, start_rm_len, 0x2, 0x00, 0x00

    ; COMPLETAR - Habilitar A20
    ; (revisar las funciones definidas en a20.asm)
    call A20_enable

    ; COMPLETAR - Cargar la GDT
    lgdt [GDT_DESC]

    ; COMPLETAR - Setear el bit PE del registro CR0
    
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; COMPLETAR - Saltar a modo protegido (far jump)
    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo

    jmp CS_RING_0_SEL:modo_protegido

BITS 32
modo_protegido:
    ; COMPLETAR - A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo
    mov ax, DS_RING_0_SEL
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax
    mov ss, ax

    ; COMPLETAR - Establecer el tope y la base de la pila
    mov esp, 0x25000
    mov ebp, esp
    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO PROTEGIDO

    print_text_pm start_pm_msg, start_pm_len, 0x3, 0x03, 0x00

    ; COMPLETAR - Inicializar pantalla
    call screen_draw_layout
   

    ; Cargar la IDT en memoria
    lidt [IDT_DESC]
    call idt_init

    ; PIC
    call pic_reset
    call pic_enable

    ; Activar paginación
    call mmu_init_kernel_dir
    mov cr3, eax

    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    

    ; Test de copy_page
    ;push 0x0   ; src
    ;push 0x500000   ; dst
    ;call copy_page

    ; Test de tarea
    ;mov ebx, cr3    ; Guardado del cr3 del kernel
    ;push 0x18000
    ;call mmu_init_task_dir
    ;pop ecx
    ;mov cr3, eax
    ;mov dword [0x07000000], 1
    ;mov dword [0x07000000], 2
    ;mov cr3, ebx    ; Volviendo al cr3 del kernel


    ;cli
   
    ; Iniciamos tss
    call tss_init
    call sched_init
    call tasks_init
    call tasks_screen_draw

    
    mov ax, TSS_INITIAL_SEL
    ltr ax

     ; El PIT (Programmable Interrupt Timer) corre a 1193182Hz.
    ; Cada iteracion del clock decrementa un contador interno, cuando éste llega
    ; a cero se emite la interrupción. El valor inicial es 0x0 que indica 65536,
    ; es decir 18.206 Hz
    mov ax, 0x3000
    out 0x40, al
    rol ax, 8
    out 0x40, al

    ; Habilitar interrupciones
    sti

    jmp TSS_IDLE_SEL:0

    ; Probar syscall
    ;int 0x58    ; El hexa de 88
    ;int 0x62    ; EL hexa de 98

    ; Ciclar infinitamente 
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
