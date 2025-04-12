EXECUTABLE=port.exe

all:
	nasm -f elf64 port.asm -o port.o -l port.lst
	ld port.o -o $(EXECUTABLE)
	./$(EXECUTABLE)
	
#Clean folder
clean:
	rm -rf *o *.lst *.exe

debug: 
	nasm -f elf64 port.asm -o port.o -l port.lst
	ld port.o -o $(EXECUTABLE)
	gdb ./$(EXECUTABLE) -tui

test:
	nasm -f elf64 test2.asm -o test2.o
	gcc -no-pie -o test2.exe test2.o
	./test2.exe