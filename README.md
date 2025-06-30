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
