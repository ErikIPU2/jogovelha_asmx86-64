all: main clean

main: main.o gameFunctions.o
	ld -o main main.o gameFunctions.o

main.o: main.asm
	nasm -felf64 main.asm

gameFunctions.o: gameFunctions.asm
	nasm -felf64 gameFunctions.asm

.PHONY: clean

clean:
	rm -rf *.o