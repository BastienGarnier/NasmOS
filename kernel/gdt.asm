%include "kernel/gdt.inc"

[BITS 32]

gdt: times GDTSIZE dd 0, 0
gdt_ptr:
	ISTRUC Gdtptr
		at Gdtptr.limite, dw 0
		at Gdtptr.base, dd 0
	IEND
default_tss: times 104 db 0

%if 0
Fonction init_descriptor : unsigned int base, unsigned int limite, unsigned char acces, unsigned char autres, Descriptor *desc -> void
Initialise un descripteur de segment selon les informations indiquées
Parametres ; remarque : [ebp + 4] est l'adresse de retour de la fonction
- base : base du descripteur
- limite: limite du descripteur
- acces : droits d'accès au segment
- autres : autres (dans l'octet 7 du descripteur)
- desc : pointeur vers le descripteur proprement dit
Retour -> void
%endif
init_descriptor:
push eax
push ebp
mov ebp, esp
push ebx
push esi
	mov esi, [ebp + 28] ; desc
	mov eax, [ebp + 12] ; base
	mov [esi + Descriptor.base0_15], ax ; ok
	shr eax, 16
	mov [esi + Descriptor.base16_23], al
	mov [esi + Descriptor.base24_31], ah
	mov eax, [ebp + 16] ; limite
	mov [esi + Descriptor.limite0_15], ax
	shr eax, 16
	and eax, 0xf
	mov ebx, [ebp + 24] ; autres
	shl ebx, 4
	add al, bl
	mov [esi + Descriptor.limite16_19], al
	mov eax, [ebp + 20] ; acces
	mov [esi + Descriptor.acces], al
pop esi
pop ebx
mov esp, ebp
pop ebp
mov eax, [esp + 4]
mov [esp + 20], eax
pop eax
add esp, 16
ret

%if 0
Fonction init : void -> void
Initialise la GDT pour le kernel
Parametres -> void
Retour -> void
%endif
gdt__init:
push eax
push ebp
mov ebp, esp
push ebx

	mov dword[default_tss + TSS.debug_flag], 0x0
	mov dword[default_tss + TSS.esp0], 0x9F000
	mov dword[default_tss + TSS.ss0], 0x18

	mov eax, gdt

	; DESCRIPTEURS NOYAU
	add eax, 8 ; pointe vers le descripteur de code
	push eax
	push 0x0D ; autres
	push 0x9B ; droits
	push 0xFFFFF ; limite
	push 0x0 ; base
	call init_descriptor

	add eax, 8 ; pointe vers le descripteur de données
	push eax
	push 0x0D ; autres
	push 0x93 ; droits
	push 0xFFFFF ; limite
	push 0x0 ; base
	call init_descriptor

	add eax, 8 ; pointe vers le descripteur de pile
	push eax
	push 0x0D ; autres
	push 0x97 ; droits
	push 0x0 ; limite
	push 0x0 ; base
	call init_descriptor

	; TACHE UTILISATEUR
	; idéalement, ne devrait pas être dans l'initialisation pour pouvoir créer des tâches plus tard
	add eax, 8
	push eax
	push 0x0D
	push 0xFF
	push 0xFFFFF ; adresse toute la mémoire, pour simplifier
	push 0x0
	call init_descriptor

	add eax, 8
	push eax
	push 0x0D
	push 0xF3
	push 0xFFFFF ; adresse toute la mémoire, pour simplifier
	push 0x0
	call init_descriptor

	add eax, 8
	push eax
	push 0x0D
	push 0xF7
	push 0x00
	push 0x0
	call init_descriptor
	; -----------------

	add eax, 8
	push eax
	push 0x0
	push 0xE9
	push 0x67
	push default_tss
	call init_descriptor

	mov eax, GDTSIZE
	xor ebx, ebx
	mov bl, 8
	mul ebx
	mov ebx, GDTBASE
	mov [gdt_ptr + Gdtptr.base], ebx
	mov word[gdt_ptr + Gdtptr.limite], ax

	push eax
	push gdt
	push dword GDTBASE
	call string__memcpy

	lgdt [gdt_ptr] ; Load Global Descriptor Table
pop ebx
mov esp, ebp
pop ebp
pop eax
ret

infinite:
	jmp infinite