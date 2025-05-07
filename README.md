# k8s_ubuntu2404server
sh script for installing k8s cluster 
https://www.youtube.com/watch?v=yHbcpBkTLNU&list=LL&index=6&t=1311s



sudo -i

echo -e "\n192.168.56.50 k8s-master\n192.168.56.51 k8s-worker1" | sudo tee -a /etc/hosts > /dev/null


printf "overlay\nbr_netfilter\n" >> /etc/modules-load.d/containerd.conf

modprobe overlay
modprobe br_netfilter

printf "net.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1\nnet.bridge.bridge-nf-call-ip6tables = 1\n" >> /etc/sysctl.d/99-kubernetes-cri.conf

sysctl --system


wget https://github.com/containerd/containerd/releases/download/v2.0.5/containerd-2.0.5-linux-amd64.tar.gz -P /tmp/
tar Cxzvf /usr/local /tmp/containerd-2.0.5-linux-amd64.tar.gz

wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -P /etc/systemd/system/

systemctl daemon-reload
systemctl enable --now containerd


wget https://github.com/opencontainers/runc/releases/download/v1.3.0/runc.amd64 -P /tmp/
install -m 755 /tmp/runc.amd64 /usr/local/sbin/runc



wget https://github.com/containernetworking/plugins/releases/download/v1.7.1/cni-plugins-linux-amd64-v1.7.1.tgz -P /tmp/
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin /tmp/cni-plugins-linux-amd64-v1.7.1.tgz


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

reboot

apt-get install -y kubelet=1.31.3-1.1 kubeadm=1.31.3-1.1 kubectl=1.31.3-1.1
apt-mark hold kubelet kubeadm kubectl
free -m
kubeadm init --pod-network-cidr 10.10.0.0/16 --kubernetes-version 1.31.3 --node-name k8s-master

kubeadm token create --print-join-command #!!!!!   for
kubeadm join 10.0.2.15:6443 --token 0hny7w.gk78cs23nv1oeowl \
        --discovery-token-ca-cert-hash sha256:02101f641a146563280ea4bac92444aef2036738ac32a687f59f12b296b87493

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml


wget https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml
vi custom-resources.yaml
kubectl apply -f custom-resources.yaml



echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bashrc
source ~/.bashrc

sudo virt-install \
  --name alpine-vm \
  --memory 512 \
  --vcpus 1 \
  --disk path=/home/alexkol/alpine-vm.qcow2,size=2 \
  --cdrom /home/alexkol/Downloads/alpine-standard-3.21.3-x86_64.iso \
  --disk path=/home/alexkol/k8s_ubuntu2404server/alpine-answers.iso,device=cdrom,readonly=on \
  --os-variant generic \
  --network bridge=virbr0,model=virtio




grep -q "SystemdCgroup = true" "/etc/containerd/config.toml"