# build
nasm -f bin boot.asm -o ./bin/boot.bin
nasm -f bin stage2.asm -o ./bin/stage2.sys

# nav
cd ./bin

# compile disk img
mv ./disk.img ./disk.prev

dd if=/dev/zero of=disk.img bs=512 count=2880
sudo losetup /dev/loop0 ./disk.img
sudo mkdosfs -F 12 /dev/loop0
dd if=boot.bin of=disk.img conv=notrunc
sudo mount /dev/loop0 /mnt -t msdos -o "fat=12"

sudo cp -v -f ./stage2.sys /mnt/stage2
sudo umount /mnt
sudo losetup -d /dev/loop0

# run emu
bochs-bin -f bochs.cfg

# back out
cd ..
