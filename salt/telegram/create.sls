{#
SPDX-FileCopyrightText: 2024 Kenneth R. Rosen <kennethrrosen@proton.me>
SPDX-License-Identifier: GPL-3.0-or-later
#}

{% if grains['id'] == 'dom0' %}

vms-depends:
  qvm.template_installed:
    - name: fedora-39

clone-telegram:
  qvm.clone:
    - name: tpl-telegram
    - template: fedora-39
    - label: black
    - class: TemplateVM
    - require:
        - qvm: vms-depends

telegram-present-id:
  qvm.present:
    - name: telegram
    - template: tpl-telegram
    - label: yellow
    - class: AppVM
    - netvm: sys-whonix
    - autostart: false
    - require:
        - qvm: vms-depends
    - features:
      - set:
        - menu-items: org.telegram.desktop.desktop org.gnome.Nautilus.desktop

{% elif grains['id'] == 'tpl-telegram' %}

telegram-install-apps-in-template:
  pkg.installed:
    - pkgs:
      - telegram-desktop

{% endif %}