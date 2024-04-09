{#
SPDX-FileCopyrightText: 2024 Kenneth R. Rosen <kennethrrosen@proton.me>
SPDX-License-Identifier: GPL-3.0-or-later
#}

{% if grains['id'] == 'dom0' %}

vms-depends:
  qvm.template_installed:
    - name: fedora-39

clone-whatsapp:
  qvm.clone:
    - name: tpl-whatsapp
    - template: fedora-39
    - label: black
    - class: TemplateVM
    - require:
        - qvm: vms-depends

whatsapp-present-id:
  qvm.present:
    - name: whatsapp
    - template: tpl-whatsapp
    - label: yellow
    - class: AppVM
    - netvm: sys-whonix
    - autostart: false
    - require:
        - qvm: vms-depends
    - features:
      - set:
        - menu-items: whatsdesk_whatsdesk.desktop

{% elif grains['id'] == 'tpl-whatsapp' %}

whatsapp-install-app-depends:
  pkg.installed:
    - pkgs:
      - qubes-snapd-helper
      - snapd

whatsapp-whatsdesk-download:
  cmd.run:
    - name: snap install core -y && snap install whatsdesk
    - require:
      - pkg: whatsapp-install-app-depends

{% endif %}
