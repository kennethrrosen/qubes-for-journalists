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
    - template: fedora-39
    - class: TemplateVM
    - require:
        - qvm: vms-depends

work-present-id:
  qvm.present:
    - name: work
    - label: purple
    - template: tpl-work
    - class: AppVM
    - netvm: proton-vpn
    - autostart: false
    - require:
        - qvm: vms-depends
    - set:
          - menu-items: qubes-start.desktop google-chrome.desktop

{% elif grains['id'] == 'tpl-work' %}

google-chrome-download-key:
    cmd.run:
        - name: rpm --import https://packages.microsoft.com/keys/microsoft.asc
        - creates:
            - /etc/pki/rpm-gpg/MICROSOFT-GPG-KEY

google-chrome-add-repository:
    pkgrepo.managed:
        - name: google-chrome
        - humanname: Google Chrome
        - baseurl: http://dl.google.com/linux/chrome/rpm/stable/x86_64
        - gpgcheck: 1
        - gpgkey: file:///etc/pki/rpm-gpg/MICROSOFT-GPG-KEY
        - require:
            - cmd: google-chrome--download-key

google-chrome-install-apps:
    pkg.installed:
        - pkgs:
            - google-chrome-stable
        - require:
            - pkgrepo: google-chrome--add-repository

setup-chrome-autostart:
  file.symlink:
    - name: /home/user/.config/autostart/google-chrome.desktop
    - target: /usr/share/applications/google-chrome.desktop
    - user: user
    - group: user
    - force: True
    - makedirs: True
    - require:
            - qvm: google-chrome-install-apps

slack-install:
    cmd.run:
        - name: |
            sudo dnf -y install wget
            wget https://downloads.slack-edge.com/releases/linux/4.35.126/prod/x64/slack-4.35.126-0.1.el8.x86_64.rpm
            sudo dnf install ./slack-*.el8.x86_64.rpm
            sudo dnf update -y
        - require:
            - qvm: setup-chrome-autostart

{% elif grains['id'] == 'work' %}

setup-slack-autostart:
  file.symlink:
    - name: /home/user/.config/autostart/slack.desktop
    - target: /usr/share/applications/slack.desktop
    - user: user
    - group: user
    - force: True
    - makedirs: True
    - require:
            - qvm: slack-install

{% endif %}
