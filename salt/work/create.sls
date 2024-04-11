{#
SPDX-FileCopyrightText: 2024 Kenneth R. Rosen <kennethrrosen@proton.me>
SPDX-License-Identifier: GPL-3.0-or-later
#}

{% if grains['id'] == 'dom0' %}

vms-depends:
  qvm.template_installed:
    - name: fedora-39

clone-work:
  qvm.clone:
    - name: tpl-work
    - source: fedora-39

work-present-id:
  qvm.present:
    - name: work
    - label: purple
    - template: tpl-work
    - class: AppVM

work-prefs-id:
  qvm.prefs:
    - name: work
    - netvm: proton-vpn

work-features-id:
  qvm.features:
    - name: work
    - set:
        - menu-items: qubes-start.desktop google-chrome.desktop slack.desktop

{% elif grains['id'] == 'tpl-work' %}

google-chrome-install-deps:
    pkg.installed:
        - pkgs:
            - fedora-workstation-repositories
        - pkg.uptodate:
            - refresh: True

google-chrome-setup:
    cmd.run:
        - name: |
                dnf config-manager --set-enabled google-chrome
                dnf install -y --nogpgcheck google-chrome-stable

slack-install:
    cmd.run:
	- name: |
                curl --proxy http://127.0.0.1:8082/ --tlsv1.2 --proto =https --max-time 180 -0  https://downloads.slack-edge.com/releases/linux/4.35.126/prod/x64/slack-4.35.126-0.1.el8.x86_64.rpm --output slack.rpm
                dnf install -y ./slack.rpm
                dnf update -y

{% elif grains['id'] == 'work' %}

setup-slack-autostart:
  file.symlink:
    - name: /home/user/.config/autostart/slack.desktop
    - target: /usr/share/applications/slack.desktop
    - user: user
    - group: user
    - force: True
    - makedirs: True

setup-chrome-autostart:
  file.symlink:
    - name: /home/user/.config/autostart/google-chrome.desktop
    - target: /usr/share/applications/google-chrome.desktop
    - user: user
    - group: user
    - force: True
    - makedirs: True

{% endif %}
