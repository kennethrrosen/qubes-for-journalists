writ:
  qvm.present:
    - label: blue
    - template: fedora-36-minimal
    - netvm: none
    - mem: 3000
    - maxmem: 3000
    - features:
      - qubes-core-agent-dom0-updates
      - qubes-core-agent-sysinfo
      - qubes-usb-proxy

install_crossover:
  cmd.run:
    - name: |
        wget https://media.codeweavers.com/pub/crossover/cxlinux/demo/crossover-21.1.2-1.rpm
        sudo dnf install crossover-21.1.2-1.rpm -y
install_scrivener:
  cmd.run:
    - name: |
        wget -O scrivener.deb "https://www.literatureandlatte.com/downloads/scrivener-3.2.2.0-amd64.deb"
        dpkg -i scrivener.deb
    - creates: /opt/scrivener/bin/scrivener

install_libreoffice:
  pkg.installed:
    - name: libreoffice

install_split_browser:
  pkg.installed:
    - name: qubes-split-browser

note:
  cmd.run:
    - name: |
        echo "Please signup for Crossover before the 30-day trial ends through the following website:"
        echo "https://www.codeweavers.com/products/crossover-linux/download"
