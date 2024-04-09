{#
SPDX-FileCopyrightText: 2024 Kenneth R. Rosen <kennethrrosen@proton.me>
SPDX-License-Identifier: GPL-3.0-or-later
#}

{% if grains['id'] == 'dom0' %}

vms-depends:
  qvm.template_installed:
    - name: fedora-39

protonvpn-present-id:
  qvm.present:
    - name: proton-vpn
    - template: fedora-39
    - label: gray
    - class: StandaloneVM
    - netvm: sys-firewall
    - memory: 800
    - maxmem: 800
    - autostart: True
    - provides-network: True
    - service:
      - enabled:
        - qubes-firewall
        - network-manager
    - require:
        - qvm: vms-depends
    - features:
      - set:
        - menu-items: protonvpn-app.desktop

{% if grains['id'] == 'proton-vpn' %}

protonvpn-install-deps:
    pkg.installed:
      - pkgs:
        - curl
        - wget
    - require:
      - qvm: protonvpn-present-id

protonvpn-install:
    cmd.run:
        - name: |
            wget https://repo.protonvpn.com/fedora-39-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.1-2.noarch.rpm
            sudo dnf install ./protonvpn-stable-release-1.0.1-2.noarch.rpm
            sudo dnf install --refresh proton-vpn-gnome-desktop
            sudo dnf install libappindicator-gtk3 gnome-shell-extension-appindicator gnome-extensions-app
        - require:
            - qvm: protonvpn-install-deps

setup-autostart:
  file.symlink:
    - name: /home/user/.config/autostart/protonvpn-app.desktop
    - target: /usr/share/applications/protonvpn-app.desktop
    - user: user
    - group: user
    - force: True
    - makedirs: True
        - require:
            - qvm: protonvpn-install

{% endif %}