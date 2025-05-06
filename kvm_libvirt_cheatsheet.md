
# 🧰 KVM + Libvirt + QEMU Полная шпаргалка

## 🗂️ Работа с виртуальными машинами (`virsh`)

### 📄 Список ВМ
```bash
virsh list                    # Активные ВМ
virsh list --all              # Все ВМ
```

### ▶️ Запуск / ⏹️ Остановка / ❌ Удаление
```bash
virsh start <vm-name>                         # Запуск
virsh shutdown <vm-name>                      # Корректное выключение
virsh destroy <vm-name>                       # Жёсткое выключение (как выдернуть вилку)

virsh undefine <vm-name>                      # Удалить из libvirt (диск останется)
virsh undefine --remove-all-storage <vm-name> # Полное удаление с диском
```

### ⏸️ Пауза и продолжение
```bash
virsh suspend <vm-name>
virsh resume <vm-name>
```

### 🔄 Автозапуск
```bash
virsh autostart <vm-name>
virsh autostart --disable <vm-name>
```

### ℹ️ Инфо
```bash
virsh dominfo <vm-name>
```

## 🌐 Работа с виртуальными сетями (`virsh net-*`)

```bash
virsh net-list --all
virsh net-start <network-name>
virsh net-destroy <network-name>
virsh net-autostart <network-name>
virsh net-undefine <network-name>
virsh net-edit <network-name>
virsh net-define <network.xml>
```

🧾 Пример: как включить `virbr1`
```bash
virsh net-start virbr1
virsh net-autostart virbr1
```

## 🪣 Пулы хранения (`virsh pool-*`)

```bash
virsh pool-list --all
virsh pool-start <pool-name>
virsh pool-define <pool.xml>
virsh pool-autostart <pool-name>
virsh pool-destroy <pool-name>
virsh pool-undefine <pool-name>
```

## 📦 Работа с образами (`qemu-img`)

### 📁 Создание и инфо:
```bash
qemu-img create -f qcow2 disk.qcow2 10G
qemu-img info disk.qcow2
```

### 🧬 Клонирование с backing file:
```bash
qemu-img create -f qcow2 -b base.qcow2 clone.qcow2
```

### 🔁 Конвертация:
```bash
qemu-img convert -O qcow2 input.raw output.qcow2
```

## ☁️ cloud-init: генерация ISO и настройки

### 📄 user-data
```yaml
#cloud-config
hostname: my-vm
users:
  - name: myuser
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh-authorized-keys:
      - ssh-rsa AAA...
    shell: /bin/bash
chpasswd:
  list: |
    myuser:password
  expire: false
```

### 📄 meta-data
```yaml
instance-id: my-vm
local-hostname: my-vm
```

### 📦 ISO для cloud-init
```bash
cloud-localds my-vm-seed.iso user-data meta-data
```

## ⚙️ Пример запуска ВМ с cloud-init
```bash
virt-install   --name my-vm   --ram 2048   --vcpus 2   --disk path=disk.qcow2,format=qcow2   --disk path=my-vm-seed.iso,device=cdrom   --os-variant ubuntu22.04   --import   --network bridge=virbr1   --noautoconsole
```

## ✅ Завершение с ошибкой при сбое (`set -e`)
В начало скрипта добавь:
```bash
#!/bin/bash
set -e  # Остановит выполнение при любой ошибке
```
