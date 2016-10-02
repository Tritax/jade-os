nasm -f bin boot.asm -o ./bin/boot.bin
nasm -f bin stage2.asm -o ./bin/stage2.sys
nasm -f bin kernel.asm -o ./bin/kernel.sys
