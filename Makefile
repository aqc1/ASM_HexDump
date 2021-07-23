PROGRAM=dump_hex

all: compile

compile:
	nasm -f elf64 -o $(PROGRAM).o $(PROGRAM).asm
	ld -o $(PROGRAM) $(PROGRAM).o

debug:
	gdb -q $(PROGRAM)

dump:
	objdump -D $(PROGRAM).o

clean:
	rm -rf $(PROGRAM).o $(PROGRAM)
