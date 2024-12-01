%define GDTBASE 0x0

EXTERN screen__print_str, screen__print_uint, screen__endl

GLOBAL syscalls__exec ; *args -> int status

STRUC Descriptor ; voir notes_bootloader
	.limite0_15: resw 1
	.base0_15: resw 1
	.base16_23: resb 1
	.acces: resb 1
	.limite16_19: resb 1
	.base24_31: resb 1	
ENDSTRUC