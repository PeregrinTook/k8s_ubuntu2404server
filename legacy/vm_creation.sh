#!/bin/bash



VBoxManage createvm --name "test" --ostype Ubuntu_64 --register

VBoxManage modifyvm "test" --memory 4096 --cpus 2 --boot1 dvd --nic1 nat --nic2 hostonly --hostonlyadapter2 vboxnet0
VBoxManage modifyvm "test" --vram 16

VBoxManage storagectl "test" --name "IDE" --add ide --controller PIIX4
VBoxManage storagectl "test" --name "SATA" --add sata --controller IntelAhci

# Создание и подключение виртуального диска
VBoxManage createhd --filename "/home/alexkol/VirtualBox VMs/test/test.vdi" --size 20480 --format VDI
VBoxManage storageattach "test" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "/home/alexkol/Downloads/ubuntu-24.04.2-live-server-amd64.iso"
VBoxManage storageattach "test" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "/home/alexkol/VirtualBox VMs/test/test.vdi"

# Настройка EFI
VBoxManage modifyvm "test" --firmware efi
VBoxManage storageattach "test" --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium ./cidata.iso
# # Запуск виртуальной машины
# VBoxManage startvm "test" --type headless
