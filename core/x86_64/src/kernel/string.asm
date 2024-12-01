%include "kernel/string.inc"

[BITS 32]

%if 0
Fonction memcpy : void *dest, void *src, unsigned int n -> void
Copie 'n' octets présents à l'adresse src vers l'adresse dest
Parametres
- n : nombre d'octets à copier
- dest : adresse de destination du copiage
- src : adresse contenant les données à copier
Retour -> void
%endif
string__memcpy:
push eax
push ebp
mov ebp, esp
push ebx
push ecx
push edx
	mov ebx, [ebp + 12] ; dest
	mov eax, [ebp + 16] ; source
	mov ecx, [ebp + 20] ; n
	dec ecx
	.while:
	cmp ecx, 0
	jz .whileend
		mov dl, byte[eax + ecx]
		mov byte[ebx + ecx], dl
		dec ecx
	jmp .while
	.whileend:
	mov dl, byte[eax + ecx]
	mov byte[ebx + ecx], dl
pop edx
pop ecx
pop ebx
mov esp, ebp
pop ebp
mov eax, [esp + 4]
mov [esp + 12], eax
pop eax
add esp, 8
ret
