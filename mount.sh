# mount img
cd ./bin

# setup loop and mount
sudo losetup /dev/loop0 ./disk.img
sudo mount /dev/loop0 /mnt -t msdos -o "fat=12"
