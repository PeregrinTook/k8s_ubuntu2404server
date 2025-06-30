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

## Project Structure Highlights