%include "kernel/idt.inc"

GLOBAL idt__init ; void -> void

[BITS 32]

idt: times IDTSIZE dd 0, 0
idt_ptr:
	ISTRUC Idtptr
		at Idtptr.limite, dw 0
		at Idtptr.base, dd 0
	IEND

%if 0
Fonction init_descriptor : short int select, unsigned int offset, short int type, Descriptor *desc -> void
Initisalise un descripteur système de type Interrupt Gate
%endif
init_descriptor:
push eax
push ebp
mov ebp, esp
push esi
	mov eax, [ebp + 12]
	mov esi, [ebp + 24]
	mov [esi + Descriptor.select], ax
	mov eax, [ebp + 20]
	mov [esi + Descriptor.type], ax
	mov eax, [ebp + 16]
	mov [esi + Descriptor.offset0_15], ax
	shr eax, 16
	mov [esi + Descriptor.offset16_31], ax
pop esi
mov esp, ebp
pop ebp
mov eax, [esp + 4]
mov [esp + 16], eax
pop eax
add esp, 12
ret

%if 0
Fonction init : void -> void
Initialise la table des descripteurs d'interruptions
%endif
idt__init:
push eax
push ebp
mov ebp, esp
push ebx
push ecx
	mov eax, idt
	mov cx, IDTSIZE
	.while:
	cmp cx, 0
	jz .whileend
		dec cx
		push eax
		push INTGATETYPE
		push isr__default
		push 0x08 ; car le descripteur de code est en 0x08 dans la GDT
		call init_descriptor
		add eax, 8 ; 8 = sizeof(Descriptor)
	jmp .while
	.whileend:

	mov eax, idt
	add eax, 112 ; 112 = 14 * 8
	push eax
	push INTGATETYPE
	push isr__pagefault_int
	push 0x08
	call init_descriptor

	mov eax, idt
	add eax, 256 ; 256 = 32 * sizeof(Descriptor), 32 est l'indice du descripteur pour l'horloge
	push eax
	push INTGATETYPE
	push isr__clock_int
	push 0x08
	call init_descriptor

	add eax, 8 ; 33 est l'indice du descripteur pour le clavier
	push eax
	push INTGATETYPE
	push isr__keyboard_int
	push 0x08 
	call init_descriptor

	mov eax, idt
	add eax, 1024
	push eax
	mov ebx, INTGATETYPE
	or ebx, 0x6000
	push ebx
	push isr__syscalls_int
	push 0x08
	call init_descriptor



	mov eax, IDTSIZE
	xor ebx, ebx
	mov bl, 8
	mul ebx
	mov ebx, IDTBASE
	mov word[idt_ptr + Idtptr.limite], ax
	mov [idt_ptr + Idtptr.base], ebx

	push eax
	push idt
	push ebx
	call string__memcpy

	lidt [idt_ptr] ; Load Interrupt Descriptor Table
pop ecx
pop ebx
mov esp, ebp
pop ebp
pop eax
ret