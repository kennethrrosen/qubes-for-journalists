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
    - source: fedora-39

whatsapp-present-id:
  qvm.present:
    - name: whatsapp
    - template: tpl-whatsapp
    - label: yellow
    - class: AppVM

whatsapp-prefs-id:
  qvm.prefs:
    - name: whatsapp
    - netvm: sys-whonix

whatsapp-features-id:
  qvm.features:
    - name: whatsapp
    - set:
      - menu-items: whatsdesk_whatsdesk.desktop

{% elif grains['id'] == 'tpl-whatsapp' %}

whatsapp-install-app-depends:
  pkg.installed:
    - pkgs:
      - qubes-snapd-helper
      - snapd
    - pkg.uptodate:
      - refresh: True

{% elif grains['id'] == 'whatsapp' %}

snapd-service-running:
  service.running:
    - name: snapd.service

whatsapp-snap-core-install:
  cmd.run:
    - name: |
            snap install core
            snap install whatsdesk
#            snap install whatsapp-for-linux

{% endif %}
