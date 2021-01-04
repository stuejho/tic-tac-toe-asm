NFLAGS=-f elf32 -g

all:
	nasm $(NFLAGS) -o main.o main.asm
	nasm $(NFLAGS) -o io.o io.asm
	ld -m elf_i386 -o main.out main.o io.o

clean:
	rm main.o main.out
