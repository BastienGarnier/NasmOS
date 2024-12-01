; %include "kernel/process.inc"
%include "kernel/gdt.inc"

STRUC Registers
	; même ordre que pushad
	.eax: resd 1
	.ecx: resd 1
	.edx: resd 1
	.ebx: resd 1
	.esp: resd 1
	.ebp: resd 1
	.esi: resd 1
	.edi: resd 1
	;;;;;;;;;;;;;;;;;;;;;;;
	.eip: resd 1
	.eflags: resd 1 ; statut des registres
	.cs: resw 1
	.ss: resw 1
	.ds: resw 1
	.es: resw 1
	.fs: resw 1
	.gs: resw 1
	.cr3: resd 1 ; pointeur vers le répertoire de page
	.sizeof:
ENDSTRUC

; sizeof(Process) = 60 octets
STRUC Process
	.pid: resd 1 ; l'indice dans le tableau 'tab'

	.regs: resb Registers.sizeof

	.sizeof:
ENDSTRUC

; Pour l'instant, structurellement un tableau (et pas une liste)
STRUC ProcessList
	.length: resw 1
	.tab: resb 3840 ; 3840 / sizeof(Process) = 64 processus <=> Process tab[64]
	.sizeof:
ENDSTRUC

EXTERN screen__print_str, screen__print_uint
EXTERN default_tss
EXTERN process__list

GLOBAL scheduler__shortschedule, current_active_process
