install-dangerzone:
  cmd.run:
    - name: |
        sudo dnf config-manager --add-repo=https://packages.freedom.press/yum-tools-prod/dangerzone/dangerzone.repo
        sudo dnf install --assumeyes --nogpgcheck dangerzone-qubes
