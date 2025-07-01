# Kubernetes Cluster Automation with Terraform and Ansible

## Project Overview
This project automates the deployment of a **Kubernetes cluster on Ubuntu 24.04** using KVM/libvirt virtual machines provisioned with Terraform and configured via Ansible.

## Disclaimer
⚠️ **Educational Project Notice**  
This is a learning-focused implementation designed for practice and experimentation. It:
- Is not production-ready
- Doesn't implement all security best practices
- May lack advanced configurations needed for real-world use
- Primarily serves as a demonstration of automation tools

## Technical Stack
| Component       | Technologies Used                |
|-----------------|----------------------------------|
| Infrastructure  | Terraform, KVM/libvirt, cloud-init |
| Orchestration  | Kubernetes (kubeadm)             |
| Container Runtime | containerd                     |
| Networking      | NGINX Ingress Controller        |
| Monitoring      | Prometheus + Grafana            |
| Configuration   | Ansible                         |

## Implementation Details

### 1. Infrastructure Provisioning (Terraform)
- Modular architecture with separate components for:
  - Network configuration
  - VM creation (master + worker nodes)
  - Storage setup
  - Dynamic Ansible inventory generation
- Uses cloud-init for initial VM configuration

### 2. Cluster Configuration (Ansible)
Playbooks handle:
1. Node preparation (packages, system settings)
2. containerd installation and configuration
3. Kubernetes master initialization
4. Worker node joining
5. Ingress controller deployment
6. Monitoring stack setup

### 3. Additional Components
- Sample application deployments
- Grafana dashboard configuration
- Legacy scripts for reference

## Project Structure

..
├── ansible
│ ├── 01-prepare-nodes.yml
│ ├── 02-configure-containerd.yml
│ ├── 03-configure-master.yml
│ ├── 04-nginx-ingress-controller.yml
│ ├── 05-join-workers.yml
│ ├── 06-monitoring.yml
│ ├── k8s-files
│ │ └── test-deployment_and_svc.yaml
│ ├── main.yml
│ └── vars.yml
├── config_vms_autogen
├── images
│ ├── noble-server-cloudimg-amd64.img
│ ├── ubuntu-template.qcow2
│ └── ubuntu-template.qcow2.backup
├── kvm_libvirt_cheatsheet.md
├── legacy
│ ├── [old files...]
├── README.md
├── some_info.md
├── templates
│ ├── ansible
│ │ └── inventory_template.yml.tpl
│ └── terraform
│ └── cloud_user_network_init
│ ├── cloud_init.yml.tmpl
│ └── network_config.yml.tmpl
└── terraform
├── [terraform files...]
├── modules
│ ├── network
│ ├── storage
│ └── vm


## Prerequisites

Before deploying the infrastructure, ensure the following tools and settings are in place:

- Virtualization enabled in BIOS
- Installed: `libvirt`, `virsh`, `kvm`, `Terraform`, `Ansible`, `Python3`, and `venv`

---

## Pre-Setup Instructions

### 1. Enable Virtualization and Install Required Packages

Make sure virtualization is enabled in your BIOS. Then install the necessary packages:

```bash
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
sudo apt install -y libvirt-daemon virsh
```

Add your user to the `libvirt` group:

```bash
sudo usermod -aG libvirt $(whoami)
newgrp libvirt
```

---

### 2. Install Terraform, Ansible, and Create a Virtual Environment

Install [Terraform](https://developer.hashicorp.com/terraform/downloads) and [Ansible](https://docs.ansible.com/) using your preferred method.

Then create and activate a Python virtual environment for Ansible:

```bash
python3 -m venv venv
source venv/bin/activate
pip install ansible
```

---

### 3. Customize Terraform and Ansible Variables

Edit variable files to suit your environment:

- `terraform.tfvars` (Terraform)
- `inventory.yml`, `group_vars/`, etc. (Ansible)

Adjust parameters such as:

- VM names
- Network settings
- Image paths

---

### 4. Deploy Infrastructure with Terraform

Initialize and apply the Terraform configuration:

```bash
terraform init
terraform apply
```

This will create virtual machines and network interfaces as defined.

---

### 5. Run Ansible Playbook

Once the infrastructure is deployed, run the Ansible playbook:

```bash
source venv/bin/activate
ansible-playbook -i inventory.yml playbook.yml
```

This will configure the newly created VMs.

You can also use the kvm_libvirt_cheatsheet.md file in this repository for additional helpful commands and tips during setup and troubleshooting.


## Useful Commands Examples

Here are some example commands you can use during deployment:

- Activate Ansible virtual environment:
```bash
source ~/ansible-venv/bin/activate

Run Ansible playbook (adjust the path to your project folder): 
(cd /path/to/your/project && ansible-playbook -i ansible/inventory.yml ansible/main.yml)

Deploy infrastructure with Terraform and export VM info:
(cd /path/to/your/project/terraform && terraform apply -auto-approve && terraform output -json VM_info > vm_info.json)
