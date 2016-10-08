#
#cd ./src

# -s -ffunction-sections -fdata-sections -Wl,--gc-sections
#gcc -m32 -s -ffreestanding -nostartfiles -nostdlib -lgcc stdio.cpp entry.cpp main.cpp -o ../bin/kernel.sys -O2 -I ../include -Wl,-e,kernel_entry -T ../link.ld

#cp ../bin/kernel.sys ../../bin/kernel.sys
make
