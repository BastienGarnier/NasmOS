%define IDTBASE 0x800 ; Il s'agit du premier octet après la GDT (qui a une taille de 0x100 * 8 = 0x800 octets). 
; On remarque que le kernel n'est pas touché puisqu'il commence sur le premier octet de la fin de l'IDT (en 0x1000 = 16 * 0x100)
%define IDTSIZE 0xff ; idem que GDT

%define INTGATETYPE 0x8E00 ; pour les interruptions
%define TRAPGATETYPE 0xEF00 ; pour les appels systèmes

EXTERN isr__default, isr__clock_int, isr__keyboard_int, isr__syscalls_int, isr__pagefault_int
EXTERN string__memcpy
GLOBAL idt__init ; void -> void

STRUC Descriptor
	.offset0_15: resw 1
	.select: resw 1
	.type: resw 1
	.offset16_31: resw 1
ENDSTRUC

STRUC Idtptr
	.limite: resw 1
	.base: resd 1
ENDSTRUC