OBJECTS = ./obj/entry.o ./obj/main.o ./obj/stdio.o ./obj/string.o
CC = gcc
CFLAGS = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector -O2 -I ./include\
             -nostartfiles -nodefaultlibs -ffreestanding -lgcc -Wall -Wextra -Werror -c
LDFLAGS = -T ./link.ld -e kernel_entry -melf_i386
AS = nasm
ASFLAGS = -f elf

all: kernel.sys

kernel.sys: $(OBJECTS)
	ld $(LDFLAGS) $(OBJECTS) -o ./bin/kernel.sys
	cp ./bin/kernel.sys ../bin/

./obj/%.o: ./src/%.cpp
	$(CC) $(CFLAGS) $< -o $@
