k8s-master@192.168.56.50 k8s-master
k8s-worker1@192.168.56.51 k8s-worker1
k8s-worker2@192.168.56.52 k8s-worker2

100.66.72.97 2Lapa


ssh k8s-m@100.66.72.100 'bash -s' < ./switch_hostname.sh 

sudo visudo
k8s-worker1 ALL=(ALL) NOPASSWD: ALL

ping -c 4 k8s-master

scp ./switch_hostname.sh k8s-m@100.66.72.108:/home/k8s-m/switch_hostname.sh

sudo nano /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp3s0:
      addresses:
        - 192.168.56.51/24

sudo netplan try
sudon reboot now

ssh-copy-id k8s-worker1@192.168.56.60

VBoxManage list vms
VBoxManage startvm "test" --type headless
VBoxManage "test" poweroff