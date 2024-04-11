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

protonmail-prefs-id:
  qvm.prefs:
    - name: proton-mail
    - netvm: sys-whonix

protonmail-features-id:
  qvm.features:
    - set:
      - menu-items: qubes-start.desktop proton-mail.desktop

{% elif grains['id'] == 'proton-mail' %}

protonmail-install-deps:
    pkg.installed:
        - pkgs:
          - curl
          - wget
        - pkg.uptodate:
          - refresh: True

protonmail-install:
    cmd.run:
        - name: |
            wget https://proton.me/download/mail/linux/ProtonMail-desktop-beta.rpm
            dnf install -y ProtonMail-desktop-beta.rpm

setup-autostart:
  file.symlink:
    - name: /home/user/.config/autostart/proton-mail.desktop
    - target: /usr/share/applications/proton-mail.desktop
    - user: user
    - group: user
    - force: True
    - makedirs: True

{% endif %}
