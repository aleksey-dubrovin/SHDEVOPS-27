---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_host: ${clickhouse_ip}
      ansible_user: ${ssh_user}
      ansible_ssh_private_key_file: ${ssh_key_path}
      ansible_become: true
      ansible_become_method: sudo

vector:
  hosts:
    vector-01:
      ansible_host: ${vector_ip}
      ansible_user: ${ssh_user}
      ansible_ssh_private_key_file: ${ssh_key_path}
      ansible_become: true
      ansible_become_method: sudo

lighthouse:
  hosts:
    lighthouse-01:
      ansible_host: ${lighthouse_ip}
      ansible_user: ${ssh_user}
      ansible_ssh_private_key_file: ${ssh_key_path}
      ansible_become: true
      ansible_become_method: sudo