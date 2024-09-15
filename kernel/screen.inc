%define RAMSCREEN 0xB8000
%define SCREENSIZE 0xFA0 ; = 4000 : 25 lignes de 80 caractères (un octet pour le code ASCII, un octet pour l'attribut donc on a 160 octets par ligne)
%define RAMSCREENLIMIT 0xB8FA0

GLOBAL screen__print_str ; char *string -> void
GLOBAL screen__scroll_up ; int n -> void
GLOBAL screen__putc ; char c -> void
GLOBAL screen__update_cursor ; void -> void
GLOBAL screen__print_uint ; int n -> void
GLOBAL screen__endl