#!/bin/bash
set -euo pipefail
trap 'handle_error $LINENO' ERR  # Ловим любые ошибки
# ==== Входные данные ====
VM_NAME=$1
USERNAME=$2
PUBKEY_FILE=$3
STATIC_IP=$4  # Можно передать или взять по умолчанию
RAM=2048
VCPUS=2
DISK_SIZE=10  # в ГБ
OS_VARIANT=ubuntu22.04

TEMPLATE_IMG="/home/alexkol/k8s_ubuntu2404server/images/ubuntu-template.qcow2"

# Проверка аргументов
if [[ -z "$VM_NAME" || -z "$USERNAME" || -z "$PUBKEY_FILE" ]]; then
  echo "Usage: $0 <vm-name> <username> <ssh-public-key-file> [static-ip]"
  exit 1
fi

# ==== Пути ====
VM_IMG="/home/alexkol/k8s_ubuntu2404server/for_cloud/${VM_NAME}.qcow2"
SEED_ISO="/home/alexkol/k8s_ubuntu2404server/for_cloud/${VM_NAME}-seed.iso"
PUBKEY=$(cat "$PUBKEY_FILE")

# ==== Шаг 1: Клонируем образ ====
echo "[+] Клонируем базовый образ..."
qemu-img create -f qcow2 -b "$TEMPLATE_IMG" -F qcow2 "$VM_IMG" ${DISK_SIZE}G

# ==== Шаг 2: cloud-init ====
TMPDIR=$(mktemp -d)
cat > "$TMPDIR/user-data" <<EOF
#cloud-config
hostname: $VM_NAME
users:
  - name: $USERNAME
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    shell: /bin/bash
    ssh-authorized-keys:
      - $PUBKEY
    lock_passwd: true

write_files:
  - path: /etc/netplan/01-netcfg.yaml
    permissions: '0600'
    content: |
      network:
        version: 2
        ethernets:
          enp1s0:
            dhcp4: true
            optional: true
          enp2s0:
            dhcp4: false
            addresses: [$STATIC_IP/24]
            routes:
              - to: 192.168.100.0/24
                via: 192.168.100.1
  - path: /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
    permissions: '0644'
    content: |
      network: {config: disabled}


package_update: true
package_upgrade: true
# packages:
#   - nginx
#   - docker.io

runcmd:
  - ip link set enp2s0 up  # Чтобы принудительно активировать интерфейс enp2s0
  - systemctl enable nginx
  - systemctl start nginx
  - systemctl enable docker
  - usermod -aG docker $USERNAME
  - netplan apply
  - ip link set enp2s0 up
EOF

cat > "$TMPDIR/meta-data" <<EOF
instance-id: $VM_NAME
local-hostname: $VM_NAME
EOF

cloud-localds "$SEED_ISO" "$TMPDIR/user-data" "$TMPDIR/meta-data"

# ==== Шаг 3: virt-install ====
echo "[+] Запускаем виртуалку..."
virt-install \
  --name "$VM_NAME" \
  --ram "$RAM" \
  --vcpus "$VCPUS" \
  --disk path="$VM_IMG",format=qcow2 \
  --disk path="$SEED_ISO",device=cdrom \
  --os-variant "$OS_VARIANT" \
  --import \
  --network network=default \
  --network bridge=virbr1 \
  --noautoconsole

echo "[✓] ВМ '$VM_NAME' создана с IP $STATIC_IP. SSH доступен как $USERNAME@$STATIC_IP"

# ==== Очистка ====
rm -rf "$TMPDIR"
