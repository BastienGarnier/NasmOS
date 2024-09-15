%include "kernel/syscalls.inc"

EXTERN screen__print_str, screen__print_uint, screen__endl

%if 0
Fonction exec : *args -> int status
%endif
syscalls__exec:
push eax
push ebp
mov ebp, esp
	mov eax, [ebp + 12] ; sys_num

	xor ebx, ebx
	mov ah, al
	.switch:
	cmp ah, 1
	jg .casedefault
	mov edx, .switchtable
	mov bl, ah
	mov ebx, [edx + 4*ebx]
	jmp ebx
	.case0:
	.casedefault:
	push .unknown_syscall
	call screen__print_str
	jmp .switchend
	.case1: ; sys_write
		mov ebx, [ebp + 48] ; voir notes_noyau.txt : ebx avant l'appel à l'interruption

		; ; Y avait besoin avant la pagination :
		; mov eax, [ebp + 28] ; ds_select
		; and eax, 0xF8
		; add eax, GDTBASE

		; xor edx, edx
		; xor ecx, ecx
		; mov dx, word[eax + Descriptor.base0_15]
		; mov cl, byte[eax + Descriptor.base16_23]
		; shl ecx, 16
		; add edx, ecx
		; xor ecx, ecx
		; mov cl, byte[eax + Descriptor.base24_31]
		; shl ecx, 24
		; add edx, ecx

		; add edx, ebx

		push ebx
		call screen__print_str

	.switchend:
mov esp, ebp
pop ebp
pop eax
ret
.switchtable:
	dd .case0 ; sys_read
	dd .case1 ; sys_write
	dd .casedefault
.unknown_syscall db "CaS1", 10, 0