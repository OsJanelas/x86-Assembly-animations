nasm -f bin bootloader.asm -o bootloader.bin
nasm -f bin kernel.asm -o kernel.bin
cmd /c "copy /b bootloader.bin+kernel.bin MitochondrionOS 2.1.img"