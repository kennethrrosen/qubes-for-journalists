{#
SPDX-FileCopyrightText: 2024 Kenneth R. Rosen <kennethrrosen@proton.me>
SPDX-License-Identifier: GPL-3.0-or-later
#}

{% if grains['id'] == 'dom0' %}

vms-depends:
  qvm.template_installed:
    - name: fedora-39

protonmail-present-id:
  qvm.present:
    - name: proton-mail
    - template: fedora-39
    - label: blue
    - class: StandaloneVM
    - netvm: sys-whonix
    - require:
        - qvm: vms-depends
    - features:
      - set:
        - menu-items: proton-mail.desktop

{% if grains['id'] == 'proton-mail' %}

protonmail-install-deps:
    pkg.installed:
      - pkgs:
        - curl
        - wget
    - require:
      - qvm:
      protonmail-present-id

protonmail-install:
    cmd.run:
        - name: |
            wget https://proton.me/download/mail/linux/ProtonMail-desktop-beta.rpm
            sudo dnf install -y ProtonMail-desktop-beta.rpm
        - require:
            - qvm: protonmail-install-deps

protonmail-autostart:
    cmd.run:
        - name: |
            mkdir -p ~/.config/autostart
            ln -s /usr/share/applications
            proton-mail.desktop ~/.config/autostart/
        - require:
        - cmd:
        protonmail-install

{% endif %}