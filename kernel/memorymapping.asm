%include "kernel/memorymapping.inc"

[BITS 32]

%if 0
Fonction init :
%endif
memorymapping__init:
push eax
push ebp
mov ebp, esp
push ecx
push edx
	mov eax, PT0_ADDR
	or eax, 3 ; <- pages noyaux
	mov [PD0_ADDR], eax

	; mov eax, PT1_ADDR
	; or eax, 3
	; mov [PD1_ADDR], eax

	; mov eax, PT1_ADDR
	; or eax, 3
	; mov [PD1_ADDR], eax

	xor ecx, ecx
	inc ecx
	.for:
	cmp ecx, 1023
	jz .forend
		inc ecx
		mov dword[PD0_ADDR + 4*ecx], 0
	jmp .for
	.forend:

	; adresse les premiers 4 Mo de mémoire en identity mappping
	xor eax, eax
	xor ecx, ecx
	.for2:
	cmp ecx, 1024
	jz .forend2
		mov edx, eax
		or edx, 3 ; <- pages noyaux
		mov dword[PT0_ADDR + 4*ecx], edx
		add eax, 4096 ; passe à l'adresse suivante, car equivalent à incrémenter le mot de poids fort constitué des bits 12 à 31
		inc ecx
	jmp .for2
	.forend2:
	; mov eax, 0xC00000
	; xor ecx, ecx
	; .for3:
	; cmp ecx, 1024
	; jz .forend3
	; 	mov edx, eax
	; 	or edx, 3
	; 	mov dword[PT1_ADDR + 4*ecx], edx
	; 	add eax, 4096
	; 	inc ecx
	; jmp .for3
	; .forend3:
	; mov dword[0xC00000], 42

	; sauvegarde le répertoire de pages
	mov eax, PD0_ADDR
	mov cr3, eax

	; active le drapeau de pagination :
	mov eax, cr0
	or eax, PAGING_FLAG 
	mov cr0, eax
pop edx
pop ecx
mov esp, ebp
pop ebp
pop eax
ret

; %if 0
; Fonction set_frame_used : unsigned int n, unsigned int m -> void
; Indique comme utilisé la page d'indice 'n' en mode 'm'
; Paramètres :
; - n : Indice de la page
; - m : mode noyau (3) ou utilisateur (7)
; %endif
; memorymapping__set_frame_used:
; push eax
; push ebp
; mov ebp, esp
; push ebx
; push ecx
; push edx
; push edi
; 	mov eax, [ebp + 12]
; 	mov edi, [ebp + 16]
; 	mov ebx, eax
; 	and eax, 0x3FF ; get page in table
; 	shr ebx, 10 ; get table in repertory
; 	mov edx, [PD0_ADDR + 4*ebx]
; 	cmp edx, 0 ; est-ce que la table de page est initialisée ?
; 	jnz .set
; .initialize: ; initialise la table de pages
; 	mov edx, ebx
; 	shr edx, 12
; 	add edx, PT0_ADDR
; 	or edx, edi
; 	mov [PD0_ADDR + 4*ebx], edx

; 	xor ecx, ecx
; 	.for:
; 	cmp ecx, 1024
; 	jz .forend
; 		mov dword[edx + 4*ecx], 0
; 		inc ecx
; 	jmp .for
; 	.forend:
; .set:
; 	mov ecx, eax
; 	shl ecx, 12
; 	or ecx, edi
; 	mov dword[edx + 4*eax], ecx ; on utilise la page
; pop edi
; pop edx
; pop ecx
; pop ebx
; mov esp, ebp
; pop ebp
; pop eax
; ret

%if 0
Fonction create_task_test : void -> void *
Crée un répertoire de pages pour la tâche utilisateur et renvoie l'adresse réelle de ce répertoire (pour pouvoir le charger par CR3)
%endif
memorymapping__create_task_test:
push eax
push ebp
mov ebp, esp
	mov eax, 1 ; 8192 octets : 4096 pour la directory page et 4096 pour la première page table utilisateur
	push eax
	call memorymapping__bma_reserve_pages ; eax -> adresse physique
	pop edi
	mov edx, eax
	; utilise la table 255 du répertoire noyau pour save le nouveau répertoire utilisateur avant la passation
	mov edi, PT255_ADDR
	or edi, 3
	mov [PD255_ADDR], edi
	mov ebx, eax
	or ebx, 3
	mov [PT255_ADDR], ebx 
	add eax, 4096
	mov ebx, eax
	or ebx, 3
	mov [PT255_ADDR + 4], ebx
	; maintenant, l'adresse des deux pages est accessible seulement par les adresses : 0x3FC00000 et 0x3FC01000

	mov eax, PT0_ADDR ; pour l'identity mapping sur le mapping noyau
	or eax, 3
	mov dword[0x3FC00000], eax ; première table du répertoire utilisateur = première table noyau
	mov eax, edx
	add eax, 4096 ; eax = adresse réelle de première table utilisateur
	or eax, 7 ; car utilisateur this time
	mov dword[0x3FC003FC], eax ; adresse réelle de la page table utilisateur => après passation, accéder à 0x3FC00000 <=> accéder premier octet de première page utilisateur

	; ; sauvegarde le répertoire de pages avec son adresse réelle
	; mov cr3, eax

	; la suite est tâche dépendante : (à améliorer avec un gestionnaire de création de tâche)

	mov eax, 1 ; 2 pages pour la tâche en elle-même
	push eax
	call memorymapping__bma_reserve_pages
	pop edi
	mov ebx, eax
	or ebx, 7
	mov dword[0x3FC01000], ebx
	add eax, 4096
	or eax, 7
	mov dword[0x3FC01004], eax

	; save l'adresse réelle du répertoire de page en lui-même (comme dernière table) (voir push de l'appel au reserve pages du début)
	mov dword[0x3FC00FFC], edx

	mov [ebp + 4], edx ; renvoie dans EAX l'adresse réelle du répertoire
mov esp, ebp
pop ebp
pop eax
ret
.ok_text db "OK", 10, 0

%if 0
Fonction bma_init : void -> void
Initialise les noeuds de l'arbre binaire d'allocation
%endif
memorymapping__bma_init:
push eax
push ebp
mov ebp, esp
push ecx
push edx
push ebx
	xor eax, eax
	mov al, 1
	xor ecx, ecx
	mov cl, 21
	.for:
		xor edx, edx
		mov ebx, eax
		dec ebx
		.for2:
			mov byte[BMA_BITMAP + ebx], cl	
			inc edx
			inc ebx
		cmp edx, eax
		jnz .for2
		shl eax, 1
	dec cl
	cmp cl, 0
	jg .for
pop ebx
pop edx
pop ecx
mov esp, ebp
pop ebp
pop eax
ret

%if 0
TODO : régler le bug qui empêche d'allouer 1 une seule page (n = 0)
Fonction bma_reserve_pages : unsigned int n -> void *
Réserve 'n' pages consécutives, de taille (n*4) Ko, où 'n' = 2^{p}, p\in{N}
Paramètres :
 - n : ordre du nombre de pages consécutives à réserver
Retour : adresse de la première page
%endif
memorymapping__bma_reserve_pages:
push eax
push ebp
mov ebp, esp
push ebx
push edx
push esi
	mov bl, byte[BMA_BITMAP]
	mov edx, [ebp + 12]
	inc edx
	cmp bl, dl
	jl .error
	xor eax, eax
	push eax
	.for:
	pop esi ; pour dévider la mémoire et éviter fuite + récupérer parent pour le jge
	cmp eax, 1048576
	jge .up
		push eax ; sauvegarde le parent
		shl eax, 1
		inc eax
		mov bl, byte[BMA_BITMAP + eax] ; gauche
		inc eax
		mov bh, byte[BMA_BITMAP + eax] ; droite

		; à voir pour amélioration :
		cmp bl, dl
		jl .else
			cmp bh, dl
			jl .else1
				cmp bh, bl
				jl .for
			.else1:
				dec eax
			jmp .for
		.else:
			cmp bh, dl
			jl .up0
	jmp .for
	.error:
		push bma_error
		call screen__print_str
	jmp .end
	.up0:
	pop esi ; parent
	.up:
	mov eax, esi	
	mov byte[BMA_BITMAP + eax], 0
	push eax
	.for2:
	cmp eax, 1048575
	jge .forend2
		shl eax, 1
		inc eax
	jmp .for2
	.forend2:
	mov edx, eax
	sub edx, 1048575
	shl edx, 12 ; pour passer à l'adresse réel
	mov [ebp + 4], edx
	pop eax ; on revient au noeud
	.forup:
	cmp eax, 0
	jz .forupend
		dec eax
		shr eax, 1
		; MAJ du noeud :
		mov edx, eax ; sauvegarde de l'adresse parent
		shl eax, 1
		inc eax
		mov bl, byte[BMA_BITMAP + eax] ; gauche
		inc eax
		mov bh, byte[BMA_BITMAP + eax] ; droite

		mov si, bx
		cmp bl, bh
		mov bl, bh
		cmovle esi, ebx
		mov bx, si
		mov eax, edx ; restauration
		mov byte[BMA_BITMAP + eax], bl

	jmp .forup
	.forupend:
.end:
pop esi
pop edx
pop ebx
mov esp, ebp
pop ebp
pop eax
ret

%if 0
Fonction bma_free_page : void *addr -> int
Libère le bloc de pages à l'adresse 'addr'
Paramètres :
 - addr : adresse relative 
%endif
memorymapping__bma_free_page:
pop eax
push ebp
mov ebp, esp
	mov ebx, [ebp + 12]
	shr ebx, 12 ; calcul l'indice dans le bitmap
mov esp, ebp
pop ebp
pop eax
; pour stocker les infos : arbre binaire de 2**21 - 1 noeuds
bma_error db "Erreur d'allocation BMA", 10, 0
bma_up db "Allocation OK", 10, 0