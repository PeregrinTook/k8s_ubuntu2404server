all:
  children:
    masters:
      hosts:
%{ for vm in masters ~}
        ${vm.name}:
          ansible_host: ${vm.ip}
          ansible_user: k8s
          ansible_become: yes
          ansible_python_interpreter: /usr/bin/python3
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
%{ endfor ~}

    workers:
      hosts:
%{ for vm in workers ~}
        ${vm.name}:
          ansible_host: ${vm.ip}
          ansible_user: k8s
          ansible_become: yes
          ansible_python_interpreter: /usr/bin/python3
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
%{ endfor ~}

  vars:
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
