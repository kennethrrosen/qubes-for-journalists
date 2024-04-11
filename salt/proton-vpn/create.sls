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

protonvpn-prefs-id:
  qvm.prefs:
    - name: proton-vpn
    - netvm: sys-firewall
    - memory: 800
    - maxmem: 800
    - autostart: True
    - provides-network: True

protonvpn-features-id
  qvm.features:
    - name: proton-vpn
    - disable:
      - service.cups
      - service.cups-browsed
      - service.tinyproxy
    - enable:
      - service.network-manager
      - service.qubes-firewall
    - set:
      - menu-items: protonvpn-app.desktop

{% elif grains['id'] == 'proton-vpn' %}

protonvpn-install-deps:
    pkg.installed:
      - pkgs:
        - curl
        - wget
      - pkg.uptodate:
        - refresh: True

protonvpn-install:
    cmd.run:
        - name: |
            wget https://repo.protonvpn.com/fedora-39-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.1-2.noarch.rpm
            dnf install -y ./protonvpn-stable-release-1.0.1-2.noarch.rpm
            dnf install -y --refresh proton-vpn-gnome-desktop
            dnf install -y libappindicator-gtk3 gnome-shell-extension-appindicator gnome-extensions-app

setup-autostart:
  file.symlink:
    - name: /home/user/.config/autostart/protonvpn-app.desktop
    - target: /usr/share/applications/protonvpn-app.desktop
    - user: user
    - group: user
    - force: True
    - makedirs: True

{% endif %}
