{#
SPDX-FileCopyrightText: 2024 Kenneth R. Rosen <kennethrrosen@proton.me>
SPDX-License-Identifier: GPL-3.0-or-later
#}

{% if grains['id'] == 'dom0' %}

vms-depends:
  qvm.template_installed:
    - name: whonix-workstation-17

tor-browser-present-id:
  qvm.present:
    - name: tor-browser
    - label: purple
    - template: fedora-39
    - class: AppVM

tor-browser-prefs-id:
  qvm.prefs:
    - name: tor-browser
    - netvm: ''
    - autostart: false

tor-browser-features-id:
   qvm.features:
    - name: tor-browser
    - set:
      - menu-items: split-browser.desktop split-browser-safest.desktop

{% elif grains['id'] == 'whonix-workstation-17' %}

whonix-refresh-nonroot:
    cmd.run:
        - name: upgrade-nonroot
        - runas: user

whonix-install-contrib-packages:
    pkg.installed:
        - pkgs:
            - qubes-repo-contrib
        - pkg.uptodate:
            - refresh: True

whonix-install-split:
    pkg.installed:
        - pkgs:
            - qubes-split-browser-disp

{% elif grains['id'] == 'fedora-39' %}

install-tor-split-contrib-packages:
    pkg.installed:
        - pkgs:
            - qubes-repo-contrib
            - qubes-split-browser
            - torbrowser-launcher
            - ca-certificates
        - pkg.update:
            - refresh: True

{% endif %}
