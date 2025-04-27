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