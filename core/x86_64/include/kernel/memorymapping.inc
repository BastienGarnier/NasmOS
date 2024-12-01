%define PAGING_FLAG 0x80000001

; Directory Page noyau :
%define PD0_ADDR 0x9F000 ; contient PT0_ADDR
%define PD1_ADDR 0x9F004 ; contient PT1_ADDR
%define PD255_ADDR 0x9F3FC ; contient PT255_ADDR

%define PT0_ADDR 0x200000 ; adresse de la première Page Table
%define PT1_ADDR 0x201000 ; adresse de la deuxième Page Table
%define PT255_ADDR 0x2FF000 ; adresse de la 255e Page Table

%define USER_OFFSET 0x3FFFF000
%define USER_STACK 0xE0000000

%if 0
Buddy Memory Allocator :
Bloc élémentaire : 4096 octets

Nombre de blocs : 1024*1024 = 2**20
=> il faut 2**18 * 8 - 1 = 2097151 octets (voir documentation ?)
%endif
%define BMA_BITMAP 0x300000 ; on place la bitmap en 0x300000, avec un max de 0x300000 + 0x200000 = 0x500000

EXTERN screen__print_uint, screen__endl, screen__print_str

GLOBAL memorymapping__init
GLOBAL memorymapping__set_frame_used
GLOBAL memorymapping__bma_init
GLOBAL memorymapping__bma_reserve_pages

GLOBAL memorymapping__create_task_test

; Écrit le résultat dans EAX
%macro physical_to_index 1
	mov eax, %1
	shr eax, 12
%endmacro

%macro index_to_physical 1
	mov eax, %1
	shl eax, 12
%endmacro

