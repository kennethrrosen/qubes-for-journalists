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
    - netvm: ''
    - autostart: false
    - require:
        - qvm: vms-depends
    - features:
      - set:
        - menu-items: "split-browser.desktop split-browser-safest.desktop"

{% elif grains['id'] == 'whonix-workstation-17' %}

whonix-install-contrib-repos:
    install-contrib-repos:
        file.managed:
            - name: /etc/apt/sources.list.d/qubes-contrib.list
            - source: salt://tor-browser/files/qubes-contrib.list
            - user: root
            - group: root
            - mode: '0644'
            - require:
                - pkg: qubes-template-whonix-workstation-17

whonix-update:
    - pkg.uptodate:
        - refresh: True
        - require:
            - qvm: whonix-install-contrib-repos

whonix-install-split-browser:
    pkg.installed:
        - pkgs:
            - qubes-split-browser-disp
        - require:
            - qvm: whonix-update

whonix-run-tor-update:
    cmd.run:
        - name: /usr/bin/update-torbrowser
        - require:
            - pkg: whonix-install-split-browser


{% elif grains['id'] == 'fedora-39' %}

install-contrib-repos:
    install-contrib-repos:
        file.managed:
            - name: /etc/yum.repos.d/qubes-contrib-vm-r4.2.repo
            - source: salt://tor-browser/files/qubes-contrib-vm-r4.2.repo
            - user: root
            - group: root
            - mode: '0644'
            - require:
                - pkg: qubes-template-fedora-39

fedora-update:
  - pkg.uptodate:
    - refresh: True
    - require:
      - qvm: writing-running-id

install-split-browser:
    pkg.installed:
        - pkgs:
            - qubes-split-browser

tor-install-apps-in-template:
    pkg.installed:
        - pkgs:
            - torbrowser-launcher
            - ca-certificates

{% endif %}
