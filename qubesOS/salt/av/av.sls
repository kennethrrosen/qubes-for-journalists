av:
  qvm.present:
    - label: green
    - template: fedora-33
    - netvm: sys-firewall
    - mem: 4096
    - maxmem: 8192
    - features:
      - virt_mode: hvm
      - qubes-core-agent-network-manager
      - qubes-core-agent-nautilus
      - qubes-core-agent-passwordless-root
      - qubes-core-agent-sysinfo
      - qubes-gpg-split
      - qubes-usb-proxy
      - qubes-update-check
      - qubes-update-notifier
      - qubes-vm-recommended
      - qubes-app-linux-pdf-converter
      - qubes-app-linux-pdf-viewer
      - qubes-app-linux-xinput
      - qubes-input-proxy-sender
      - qubes-input-proxy-receiver
      - qubes-menus
      - qubes-db

install_zoom:
  cmd.run:
    - name: |
        sudo dnf install -y wget
        wget https://zoom.us/client/latest/zoom_x86_64.rpm
        sudo dnf install -y zoom_x86_64.rpm
install_google_chat:
  pkg.installed:
    - name: epel-release
  cmd.run:
    - name: sudo dnf install -y libappindicator-gtk3 google-chrome-stable

install_teams:
  cmd.run:
    - name: |
        sudo dnf install -y wget
        wget https://packages.microsoft.com/yumrepos/ms-teams/teams-1.3.00.5153-1.x86_64.rpm
        sudo dnf install -y teams-1.3.00.5153-1.x86_64.rpm
        sudo dnf install -y libXScrnSaver
50-sys-audio.policy:
  file.managed:
    - name: /etc/qubes-rpc/policy/sys-audio
    - source: https://raw.githubusercontent.com/QubesOS/qubes-mgmt-salt-dom0-virtual-machines/master/qvm/sys-audio.policy
    - user: root
    - group: root
    - mode: '0644'

sys-audio-rpc:
  qvm.sysrq:
    - target: av
    - cmd: u
    - arg: sys-audio

sys-audio-vm:
  service.running:
    - name: qubes-audio
    - enable: True
    - watch:
      - file: 50-sys-audio.policy
