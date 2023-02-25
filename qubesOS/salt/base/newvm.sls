# Create a new Qubes OS VM

{% set vm_name = 'new-vm' %}
{% set template_name = 'fedora-32' %}

# Create the new VM based on the specified template
new-vm:
  qvm.present:
    - name: {{ vm_name }}
    - template: {{ template_name }}

# Install packages on the new VM
packages:
  pkg.installed:
    - pkgs:
      - nano
      - vim
      - git
      - python3

# Configure SSH settings on the new VM
ssh_config:
  file.append:
    - name: /etc/ssh/sshd_config
    - text: 'PermitRootLogin no'

# Restart the SSH service
ssh_restart:
  service.running:
    - name: sshd
    - watch:
      - file: ssh_config
