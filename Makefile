NFLAGS=-f elf32 -g
TARGET=tic-tac-toe

all:
	nasm $(NFLAGS) -o main.o main.asm
	nasm $(NFLAGS) -o io.o io.asm
	ld -m elf_i386 -o $(TARGET) main.o io.o

clean:
	rm main.o $(TARGET)
