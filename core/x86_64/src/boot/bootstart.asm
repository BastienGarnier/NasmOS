extern _kmain

global _start

section .text
[BITS 32]
_start:
	mov dword[0xB8000], 0x2f4b2f4f
	call _kmain

	cli
	hlt