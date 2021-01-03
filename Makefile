all:
	nasm -f elf32 -o main.o main.asm -g
	nasm -f elf32 -o io.o io.asm -g
	ld -m elf_i386 -o main.out main.o io.o

clean:
	rm main.o main.out
