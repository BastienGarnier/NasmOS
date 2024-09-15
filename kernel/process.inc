STRUC Process
	.pid: resd 1

	STRUC Registers
		.eax: resd 1
		.ecx: resd 1
		.edx: resd 1
		.ebx: resd 1
		.esp: resd 1
		.ebp: resd 1
		.esi: resd 1
		.edi: resd 1
		.eip: resd 1
		.eflags: resd 1
		.cs: resw 1
		.ss: resw 1
		.ds: resw 1
		.es: resw 1
		.fs: resw 1
		.gs: resw 1
		.cr3: resd 1
	ENDSTRUC
ENDSTRUC