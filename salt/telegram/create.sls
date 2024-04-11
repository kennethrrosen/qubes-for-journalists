{#
SPDX-FileCopyrightText: 2024 Kenneth R. Rosen <kennethrrosen@proton.me>
SPDX-License-Identifier: GPL-3.0-or-later
#}

{% if grains['id'] == 'dom0' %}

vms-depends:
  qvm.template_installed:
    - name: debian-12

clone-telegram:
  qvm.clone:
    - name: tpl-telegram
    - source: debian-12

telegram-present-id:
  qvm.present:
    - name: telegram
    - template: tpl-telegram
    - label: yellow
    - class: AppVM

telegram-prefs-id:
  qvm.prefs:
    - name: telegram
    - netvm: sys-whonix

telegram-features-id:
  qvm.features:
    - name: telegram
    - set
      - menu-items: org.telegram.desktop.desktop

{% elif grains['id'] == 'tpl-telegram' %}

telegram-install-apps-in-template:
  pkg.installed:
    - pkgs:
      - telegram-desktop
    - pkg.uptodate:
      - refresh: True

{% endif %}
