%include "kernel/scheduler.inc"

[BITS 32]

current_active_process: dd 0

%if 0
Fonction shortschedule : void -> void
%endif
scheduler__shortschedule:
push eax
push ebp
mov ebp, esp
	cmp dword[current_active_process], 0
	jnz .else

		cmp dword[process__list + ProcessList.length], 0
		jz .else
			mov eax, process__list
			add eax, ProcessList.tab ; le premier processus
			mov [current_active_process], eax

			mov edi, [current_active_process]
			add edi, Process.regs ; pointe vers les registres du premier processus
		jmp .commut
	.else:
	cmp dword[process__list + ProcessList.length], 1
	jle .end
	; ici, on a au moins deux processus, on sauvegarde donc le contexte puis
	; on modifie le pointeur vers current_active_process et appel à la fonction de switch
	; le contexte est déjà en partie sauvegardé par SAVE_REGS appelé à l'interruption d'horloge
		mov edi, [current_active_process] ; adresse du processus courant
		add edi, Process.regs
		mov eax, [esp + 20]
		mov word[edi + Registers.gs], ax
		mov eax, [esp + 24]
		mov word[edi + Registers.fs], ax
		mov eax, [esp + 28]
		mov word[edi + Registers.es], ax
		mov eax, [esp + 32]
		mov word[edi + Registers.ds], ax
		mov eax, [esp + 36]
		mov dword[edi + Registers.edi], eax
		mov eax, [esp + 40]
		mov dword[edi + Registers.esi], eax
		mov eax, [esp + 44]
		mov dword[edi + Registers.ebp], eax
		mov eax, [esp + 48]
		mov dword[edi + Registers.esp], eax
		mov eax, [esp + 52]
		mov dword[edi + Registers.ebx], eax
		mov eax, [esp + 56]
		mov dword[edi + Registers.edx], eax
		mov eax, [esp + 60]
		mov dword[edi + Registers.ecx], eax
		mov eax, [esp + 64]
		mov dword[edi + Registers.eax], eax
		mov eax, [esp + 68]
		mov dword[edi + Registers.eip], eax
		mov eax, [esp + 72]
		mov word[edi + Registers.cs], ax
		mov eax, [esp + 76]
		mov dword[edi + Registers.eflags], eax
		mov eax, [esp + 80]
		mov dword[edi + Registers.esp], eax
		mov eax, [esp + 84]
		mov word[edi + Registers.ss], ax

		mov eax, esp
		add eax, 88
		mov [default_tss + TSS.esp0], eax

		mov ebx, dword[current_active_process]
		mov eax, [ebx + Process.pid]
		inc eax
		inc eax
		cmp dword[process__list + ProcessList.length], eax
		jg .else2
			dec eax
			mov edx, Process.sizeof
			mul edx
			add eax, process__list
			add eax, ProcessList.tab
			mov dword[current_active_process], eax

			mov edi, [current_active_process]
			add edi, Process.regs
		jmp .commut
		.else2:
			mov eax, process__list
			add eax, ProcessList.tab ; le premier processus -> tab[0]
			mov dword[current_active_process], eax

			mov edi, [current_active_process]
			add edi, Process.regs
	.commut:
		mov esp, [default_tss + TSS.esp0] ; réinitialise la pile pour avoir un truc propre
		
		; Pour préparer le iret de commutation : push ss, esp, eflags, cs, eip
		; iret va depop tout ça
		xor eax, eax
		mov ax, word[edi + Registers.ss]
		push eax
		mov eax, [edi + Registers.esp]
		push eax
		mov eax, [edi + Registers.eflags]
		or eax, 0x200 ; réactive le Interrupt Enabled Flag
		and eax, 0xFFFFBFFF ; ? Voir Nested Task Flag jsp
		push eax
		xor eax, eax
		mov ax, word[edi + Registers.cs]
		push eax
		mov eax, [edi + Registers.eip]
		push eax

		mov edx, dword[edi + Registers.eax]
		push edx
		mov edx, dword[edi + Registers.ecx]
		push edx
		mov edx, dword[edi + Registers.edx]
		push edx
		mov edx, dword[edi + Registers.ebx]
		push edx
		mov edx, dword[edi + Registers.ebp]
		push edx
		mov edx, dword[edi + Registers.esi]
		push edx
		mov edx, dword[edi + Registers.edi]
		push edx
		xor edx, edx
		mov dx, word[edi + Registers.ds]
		push edx
		mov dx, word[edi + Registers.es]
		push edx
		mov dx, word[edi + Registers.fs]
		push edx
		mov dx, word[edi + Registers.gs]
		push edx

		mov al, 0x20
		out 0x20, al ; "End of Interrupt" (EOI) envoyé au PIC

		mov eax, dword[edi + Registers.cr3]
		mov cr3, eax

		pop gs
		pop fs
		pop es
		pop ds
		pop edi
		pop esi
		pop ebp
		pop ebx
		pop edx
		pop ecx
		pop eax

		iret
.end:
mov esp, ebp
pop ebp
pop eax
ret
.msg: db "Euh ok ?", 10, 0
