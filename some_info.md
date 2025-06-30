# Copy your SSH key to a remote host for passwordless login
ssh-copy-id k8s-master@192.168.56.50

# Safely edit the sudoers file to manage user privileges
sudo visudo

# Securely copy a script to a remote host
scp ./switch_hostname.sh k8s-m@100.66.72.108:/home/k8s-m/switch_hostname.sh

# Test new Netplan network config without rebooting (auto rollback if fails)
sudo netplan try

# List all virtual machines registered in VirtualBox
VBoxManage list vms

# List only running VirtualBox VMs
VBoxManage list runningvms

# Activate Python virtual environment for Ansible
source ~/ansible-venv/bin/activate

# Show logs for a specific Kubernetes pod in the calico-system namespace
kubectl logs calico-node-qsxw4 -n calico-system

# Show detailed status of a specific Kubernetes pod
kubectl describe pod calico-node-qsxw4 -n calico-system

# Activate Ansible virtual environment (repeated for context)
source ~/ansible-venv/bin/activate

# Run Terraform to apply infrastructure and export VM info as JSON
(cd /home/alexkol/k8s_ubuntu2404server/terraform && terraform apply -auto-approve && terraform output -json VM_info > vm_info.json)

# Run Ansible playbook using generated inventory
(cd /home/alexkol/k8s_ubuntu2404server && ansible-playbook -i ansible/inventory.yml ansible/main.yml)

# Internal service URL for Prometheus dashboard (accessible inside the cluster)
"http://prometheus-server.monitoring.svc"

# k8s_ubuntu2404server
# Shell script for installing Kubernetes cluster
# Based on: https://www.youtube.com/watch?v=yHbcpBkTLNU&list=LL&index=6&t=1311s

# --- Set KUBECONFIG env var permanently ---
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bashrc
source ~/.bashrc

# --- Manually install a minimal Alpine VM using virt-install ---
sudo virt-install \
  --name alpine-vm \                                 # VM name
  --memory 512 \                                     # RAM in MB
  --vcpus 1 \                                        # Number of CPU cores
  --disk path=/home/alexkol/alpine-vm.qcow2,size=2 \ # Primary disk (QCOW2)
  --cdrom /home/alexkol/Downloads/alpine-standard-3.21.3-x86_64.iso \ # Alpine ISO
  --disk path=/home/alexkol/k8s_ubuntu2404server/alpine-answers.iso,device=cdrom,readonly=on \ # Preseed/answer file ISO
  --os-variant generic \                             # OS variant
  --network bridge=virbr0,model=virtio               # Use bridged network with virtio driver

# --- Show failed systemd services (useful for troubleshooting) ---
systemctl --failed

# --- Check if containerd uses SystemdCgroup ---
grep -q "SystemdCgroup = true" "/etc/containerd/config.toml"

