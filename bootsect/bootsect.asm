%define BASE 0x0100 ; en 16 bits, 0x0100:0x0 = 0x1000
%define KSIZE 50 ; pour l'instant suffit, à augmenter par la suite

; indique a Nasm que l'on travaille en 16 bits
[BITS 16]
[ORG 0x0]

jmp start
%include "bootsect/util.inc" ; juste la fonction d'affichage
start:
	; initialisation des segments en 0x07C00 (parce que sinon les variables sont cherchés n'importe où)
	; En effet, le programme du secteur de boot est chargé par le BIOS en 0x7C00
	mov ax, 0x07C0 
	mov ds, ax
	mov es, ax

	; initialisation de la pile de 0x8F000 à 0x80000
	mov ax, 0x8000
	mov ss, ax
	mov sp, 0xf000

	mov [bootdrive], dl ; l'unité de boot, (voir internet ?)

	; affiche un msg
	mov si, msgDebut
	call afficher

	; Chargement effectif du noyau :
	xor ax, ax
	int 0x13 ; initialisation de l'I/O disk

	push es ; (histoire de pas bousiller les segments, on sauvegarde du pile)

	; j'ai pas le droit d'ecrire ca : mov es, dword BASE, donc j'écrit ca :
	mov ax, BASE
	mov es, ax

	; en utilisant les tables données sur https://en.wikipedia.org/wiki/INT_13H
	mov ah, 2
	mov al, KSIZE

	; faudra voir signification cylindre, secteur et tete
	mov ch, 0; cylindre
	mov cl, 2 ; secteur. Le premier c'est 1 qui est le bootloader, donc 2 c'est le noyau :)
	mov dh, 0 ;tete
	mov dl, [bootdrive]
	mov bx, 0
	int 13h ; normalement c'est bon
	; CF = 1 si erreur, 0 sinon
	; AH = code de retour
	; AL = nombre de secteurs lus effectivement
	pop es

	jc erreur

	; Passage en mode protégé : il faut calculer la valeur du pointeur GDT (gdtptr) puis changer cr0
	; gdtptr.limite
	mov ax, gdtend
	mov bx, gdt
	sub ax, bx
	mov word [gdtptr], ax
	; -------------
	; gdtptr.base
	xor eax, eax
	xor ebx, ebx
	mov ax, ds
	mov ecx, eax ; on le met la car comme l'adresse est sur 32 bits, ca va compliqué a calculer sinon :)*
	shl ecx, 4 ; décalage à gauche
	mov bx, gdt
	add ecx, ebx
	mov [gdtptr + 2], ecx ; pouf c'est bon !
	; -----------
	cli
	; mise à 1 de cr0
	lgdt [gdtptr] ; le nom de l'instruction veut tout dire : Load Global/General Descriptor Table
	mov eax, cr0 ; visiblement, cr0 est sur 32 bits
	or ax, 1
	mov cr0, eax
	; ---------------
; Ces deux commandes vident le cache du processeur et sont donc vitales (même si ça semble pas comme ça xD)
	jmp next
next:
; --------------------------------------------------------------------------------------
	; Réinialisation des descripteurs de segments
	; Segment de données
	mov ax, 0x10
	mov ds, ax
	mov fs, ax
	mov gs, ax
	mov es, ax
	; Segment de pile
	mov ss, ax
	mov esp, 0x0009F000
	; Segment de code (car dans la GDT, le segment de code est à l'offset 0x8 car il faut sauter le NULL)
	jmp dword 0x8:0x1000 ; on peut pas mettre BASE*0x10... :'|
erreur:
	mov si, msgErreur
	call afficher
end:
	jmp end

;--- Variables ---
msgDebut db "Chargement du kernel !", 13, 10, 0
msgErreur db "Erreur de chargement du kernel !", 13, 10, 0
bootdrive db 0
;-----------------
;--- GDT ---
gdt:
	db 0, 0, 0, 0, 0, 0, 0, 0 ; descripteur NULL
gdt_cs: ; Descripteur de code
	db 0xFF, 0xFF, 0x0, 0x0, 0x0, 10011011b, 11011111b, 0x0
gdt_ds: ; Descripteur de données
	db 0xFF, 0xFF, 0x0, 0x0, 0x0, 10010011b, 11011111b, 0x0
gdtend:
gdtptr:
	dw 0 ; limite
	dd 0 ; base

;--- NOP jusqu'à 510 ---
times 510-($-$$) db 144
dw 0xAA55