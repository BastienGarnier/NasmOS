#!/bin/bash

kernelfiles=$(ls kernel | grep -e .asm\$)
bootsectfiles=$(ls bootsect | grep -e .asm\$)

for file in $kernelfiles
do
	filename="${file%.*}"
	echo Assembly $file to $filename.o
	nasm -f elf -o kernel/$filename.o kernel/$file	
done

# nasm -f elf -o bootsect/boot.o bootsect/bootsect.asm
ld --oformat binary -Ttext 1000 --start-group kernel/kernel.o kernel/screen.o kernel/gdt.o kernel/string.o kernel/idt.o kernel/interrupt.o kernel/syscalls.o kernel/pic.o kernel/memorymapping.o --end-group -o kernel/kernel -m elf_i386 -no-pie # il faut absolument mettre le kernel.o en premier pour qu'il soit écrit en début de binaire, et soit donc bien à l'adresse 0x1000
nasm -f bin -o bootsect/bootsect bootsect/bootsect.asm
cat bootsect/bootsect kernel/kernel /dev/zero | dd of=floppyA bs=512 count=2880
# # cat kernel/kernel /dev/zero | dd of=floppyA bs=512 count=2880
# dd if=bootgrub of=floppyA bs=1k
# check=$(grub-file --is-x86-multiboot kernel/kernel)
# echo $?
# echo $check

# cat kernel/kernel /dev/zero | dd of=floppyA bs=512 count=2880