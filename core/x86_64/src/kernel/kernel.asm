%include "kernel/kernel.inc"

[BITS 32]

GLOBAL _kmain

_kmain:
	; Affichage d'un message par écriture dans la RAM vidéo

	push dword 25
	call screen__scroll_up
	pop edi

	push msg
	call screen__print_str
	pop edi

	push msg2
	call screen__print_str
	pop edi
	call idt__init

	push msg3
	call screen__print_str
	pop edi
	call pic__init

	push msg1
	call screen__print_str
	pop edi
	call gdt__init

	; Réinitialisation des descripteurs de segment pour qu'ils pointent vers la nouvelle GDT
	mov ax, 0x10 ; adresse dans la GDT du descripteur de données
	mov ds, ax
	mov fs, ax
	mov gs, ax
	mov es, ax
	mov ax, 0x18 ; adresse dans la GDT du descripteur de pile
	mov ss, ax
	mov esp, 0x9F000
	jmp 0x8:.next ; 0x8 = adresse dans la GDT du descripteur de code
	.next:

	push msg5
	call screen__print_str
	pop edi

	mov ax, 0x38 ; car le Task Register est dans la GDT à l'indice 7 : 0x38 = 7 * 8
	ltr ax

	push msg9
	call screen__print_str
	pop edi
	call memorymapping__init

	call memorymapping__bma_init
	mov eax, 11 ; 2**10 * 4Ko = 4Mo
	push eax
	call memorymapping__bma_reserve_pages
	pop edi

	call screen__update_cursor ; ptit update graphique, parce-que le cursor est n'importe où (aléatoire puis placé par BIOS)
	
	; call memorymapping__create_task_test ; EAX = adresse du répertoire de page pour cette tâche

	; mov cr3, eax ; EAX de la création de tâche

	push 0x2000
	push user_task1
	call process__load_task ; copie user_task1
	
	push 0x2000
	push user_task2
	call process__load_task ; copie user_task2
	
	; push 0x33
	; ; l'adresse dans la gdt le sélecteur de pile de la tache utilisateur est en 0x30
	; ; mais les trois premiers bits du sélecteur correspondent :
	; ; premier et deuxième : RPL (niveau de privilège)
	; ; troisième : 0 = GDT, 1 = LDT
	; push 0x3FC02000 ; esp pour la tâche
	
	; pushf
	; pop eax ; récupère le registre de drapeaux
	
	; or eax, 0x200 ; Active le Interrupt Flag (IF)
	; and eax, 0xffffbfff ; Désactive le Nested Task (NT)
	; push eax
	; push 0x23 ; le sélecteur de code de la tache utilisateur est en 0x20, mais 0x23 pour même raison que précédemment
	
	; push 0x3FC00000
	; mov ax, 0x2B ; = 0x28 + 3 voir précédemment
	; mov ds, ax
	; iret

	; push msg7
	; call screen__print_str

	sti

end:
	jmp end

msg db "Le kernel NasmOS est charge", 10, 0
msg1 db "Mise a jour de la GDT", 10, 0
msg2 db "Mise a jour de l'IDT", 10, 0
msg3 db "Initialisation du PIC", 10, 0
msg4 db "Autorisation des interruptions", 10, 0
msg5 db "Chargement du Task Register", 10, 0

msg7 db "Erreur de commutation", 10, 0
msg8 db "Fin d'execution de la tache utilisateur", 10, 0

msg9 db "Initialisation de la pagination noyau", 10, 0

user_task1:
push ebp
mov ebp, esp
	mov esi, 88888888
	mov edx, 87654321 ; ID de usertask 1 pour les tests
	.while:
		mov eax, 0x1
		mov ebx, .msg
		int 0x80
		mov ecx, 0x10000000
		.for:
			dec ecx
			cmp ecx, 0
		jnz .for
	jmp .while
mov esp, ebp
pop ebp
ret
.msg db "Tache utilisateur numero 1 en cours d'execution", 10, 0

user_task2:
push ebp
mov ebp, esp
	mov edx, 12345678 ; ID de usertask 1 pour les tests
	.while:
		mov eax, 0x1
		mov ebx, .msg
		int 0x80
		mov ecx, 0x10000000
		.for:
			dec ecx
			cmp ecx, 0
		jnz .for
	jmp .while
mov esp, ebp
pop ebp
ret
.msg db "Tache utilisateur numero 2 en cours d'execution", 10, 0
