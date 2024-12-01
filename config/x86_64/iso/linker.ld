/*
linker avec flag -n <=> --nmagic qui désactive l'alignement automatique de sections
Comme ça on est sûr que le multiboot header est bien au début
*/

ENTRY(_start)

SECTIONS {
	. = 1M; /* adresse de chargement de la première section à 1 Mio*/

	.boot :
	{
		*(.multiboot_header) /*permet de forcer le header au début*/
	}
	
	.text :
	{
		*(.text)
	}
}