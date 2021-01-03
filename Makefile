all:
	nasm -f elf32 -o main.o main.asm
	ld -m elf_i386 -o main.out main.o

clean:
	rm main.o main.out
