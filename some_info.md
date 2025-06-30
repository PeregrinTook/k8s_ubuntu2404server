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
