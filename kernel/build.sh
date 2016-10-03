#
cd ./src

# -s -ffunction-sections -fdata-sections -Wl,--gc-sections
gcc -m32 -s -nostartfiles -nostdlib -lgcc entry.cpp main.cpp -o ../bin/kernel.sys -O2 -Wl,-e,kernel_entry -T ../link.ld

cp ../bin/kernel.sys ../../bin/kernel.sys
