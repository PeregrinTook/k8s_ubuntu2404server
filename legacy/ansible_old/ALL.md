﻿### ALL: 

sudo su

printf "\n192.168.15.93 k8s-control\n192.168.15.94 k8s-1\n192.168.15.95 k8s-1\n\n" >> /etc/hosts

printf "overlay\nbr_netfilter\n" >> /etc/modules-load.d/containerd.conf

modprobe overlay
modprobe br_netfilter

printf "net.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1\nnet.bridge.bridge-nf-call-ip6tables = 1\n" >> /etc/sysctl.d/99-kubernetes-cri.conf

sysctl --system

wget https://github.com/containerd/containerd/releases/download/v1.7.24/containerd-1.7.24-linux-amd64.tar.gz -P /tmp/
tar Cxzvf /usr/local /tmp/containerd-1.7.24-linux-amd64.tar.gz
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -P /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now containerd

wget https://github.com/opencontainers/runc/releases/download/v1.2.2/runc.amd64 -P /tmp/
install -m 755 /tmp/runc.amd64 /usr/local/sbin/runc

wget https://github.com/containernetworking/plugins/releases/download/v1.6.1/cni-plugins-linux-amd64-v1.6.1.tgz -P /tmp/
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin /tmp/cni-plugins-linux-amd64-v1.6.1.tgz

<<<<<<<<<<< manually edit and change SystemdCgroup to true (not systemd_cgroup)
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
vi /etc/containerd/config.toml
systemctl restart containerd

swapoff -a  <<<<<<<< just disable it in /etc/fstab instead

apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg

mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update

reboot

sudo su

apt-get install -y kubelet=1.31.3-1.1 kubeadm=1.31.3-1.1 kubectl=1.31.3-1.1
apt-mark hold kubelet kubeadm kubectl

# check swap config, ensure swap is 0
free -m


############ ONLY RUN THE FOLLOWING ON CONTROL NODE .. control plane install ########
kubeadm init --pod-network-cidr 10.10.0.0/16 --kubernetes-version 1.31.3 --node-name k8s-control

export KUBECONFIG=/etc/kubernetes/admin.conf

# add Calico 3.29.1 CNI  <<<<<< edit the CIDR for pods if its custom
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml
wget https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml
vi custom-resources.yaml
kubectl apply -f custom-resources.yaml

# get worker node commands to run to join additional nodes into cluster
kubeadm token create --print-join-command
######################################################################################


### ONLY ON WORKER nodes
Run the command from the token create output above

### Tag nodes for worker
kubectl label node k8s-1 node-role.kubernetes.io/worker=worker
