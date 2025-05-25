k8s-master@192.168.122.50 k8s
k8s-worker1@192.168.122.51 k8s
k8s-worker2@192.168.122.52 k8s



ssh k8s-m@100.66.72.100 'bash -s' < ./switch_hostname.sh
или 

ssh k8s-worker1@192.168.56.51 'bash -s' <<EOF
whoami
echo -e "\n192.168.56.50 k8s-master\n192.168.56.51 k8s-worker1" | sudo tee -a /etc/hosts > /dev/null
cat /etc/hosts
EOF


sudo -i


ssh-keygen -t rsa -b 4096 -C "your_emai2l@example.com"

ssh-copy-id k8s-master@192.168.56.50

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
VBoxManage list runningvms

VBoxManage startvm "test" --type headless
VBoxManage controlvm "Ubuntu_VM" poweroff
for vm in $(VBoxManage list runningvms | awk '{print $1}' | tr -d '"'); do
    VBoxManage controlvm $vm acpipowerbutton
done





noble-server-cloudimg-amd64.img


rm /home/alexkol/.ssh/known_hosts && \
./customized_script.sh k8s-master k8s ~/.ssh/id_rsa.pub 192.168.100.50 && \
./customized_script.sh k8s-worker1 k8s ~/.ssh/id_rsa.pub 192.168.100.51 && \
./customized_script.sh k8s-worker2 k8s ~/.ssh/id_rsa.pub 192.168.100.52

ssh k8s@192.168.100.50


python3 -m venv ansible-venv

source ~/ansible-venv/bin/activate


root@k8s-master:~# systemctl --failed


source ~/ansible-venv/bin/activate && ansible-playbook -i ansible/inventory.yml ansible/k8s_cluster_with_calico.yml

ansible-playbook -i ansible/inventory.yml ansible/01-prepare-nodes.yml --tags "now"
( terraform apply -auto-approve && terraform output -json VM_info > vm_info.json &&
source ~/ansible-venv/bin/activate && cd /home/alexkol/k8s_ubuntu2404server && ansible-playbook -i ansible/inventory.yml ansible/main.yml )

kubectl logs calico-node-qsxw4 -n calico-system
kubectl describe pod calico-node-qsxw4 -n calico-system
