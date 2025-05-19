all:
  children:
    master:
      hosts:
        ${master_ip}:
          ansible_user: k8s
          ansible_become: yes
          ansible_python_interpreter: /usr/bin/python3
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no'

    workers:
      hosts:
%{ for ip in worker_ips }
        ${ip}:
          ansible_user: k8s
          ansible_become: yes
          ansible_python_interpreter: /usr/bin/python3
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
%{ endfor }

  vars:
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
