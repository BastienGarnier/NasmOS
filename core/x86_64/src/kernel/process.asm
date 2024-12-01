[BITS 32]

%include "kernel/process.inc"

process__list:
ISTRUC ProcessList
	at ProcessList.length, dw 0
	at ProcessList.tab, db 3840 dup 0 
IEND

%if 0
Fonction load_task: void *prgm_destination_addr, void *prgm_physical_addr, unsigned int prgm_len -> int status
Copie le programme de 'prgm_len' octets situé à l'adresse "physique prgm_physical_addr" vers l'adresse 'prgm_destination_addr'
%endif
process__load_task:
push eax
push ebp
mov ebp, esp
	xor ecx,ecx
	mov cx, [process__list + ProcessList.length]
	mov eax, 15
	mul ecx
	mov ecx, eax

	call memorymapping__create_task_test

	mov [process__list + ProcessList.tab + ecx*4 + Process.regs + Registers.cr3], eax ; EAX de la création de tâche

	mov ebx, cr3
	mov cr3, eax

	mov eax, [ebp + 16] ; prgm_len
	push eax
	mov eax, [ebp + 12] ; physical_addr
	push eax
	mov edx, 0x3FC00000 ; destination_addr
	push edx
	call string__memcpy
	
	mov cr3, ebx
	
	mov byte[process__list + ProcessList.tab + ecx*4 + Process.regs + Registers.ss], 0x33
	mov [process__list + ProcessList.tab + ecx*4 + Process.regs + Registers.eip], edx
	add edx, 0x2000 ; pour avoir esp
	mov [process__list + ProcessList.tab + ecx*4 + Process.regs + Registers.esp], edx
	mov byte[process__list + ProcessList.tab + ecx*4 + Process.regs + Registers.cs], 0x23
	mov byte[process__list + ProcessList.tab + ecx*4 + Process.regs + Registers.ds], 0x2B

	xor eax,eax
	mov ax, [process__list + ProcessList.length]
	mov [process__list + ProcessList.tab + ecx*4 + Process.pid], ax
	inc ax
	mov [process__list + ProcessList.length], ax

	
mov esp, ebp
pop ebp
mov eax, [esp + 4]
mov [esp + 8], eax
pop eax
add esp, 4
ret