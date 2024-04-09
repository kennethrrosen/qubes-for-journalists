{#
SPDX-FileCopyrightText: 2024 Kenneth R. Rosen <kennethrrosen@proton.me>
SPDX-License-Identifier: GPL-3.0-or-later
#}


{% if grains['id'] == 'dom0' %}

ensure_template_exists:
  qvm.clone:
    - name: fedora-39
    - clone_name: tpl-video
    - label: black

ensure_video_vm_exists:
  qvm.present:
    - name: video
    - label: red
    - template: tpl-video
    - netvm: proton-vpn
    - require:
      - qvm: ensure_template_exists

{% elif grains['id'] == 'tpl-video' %}

install_zoom:
  pkg.installed:
    - names:
      - wget
  cmd.run:
    - name: |
        wget https://zoom.us/client/latest/zoom_x86_64.rpm
        sudo dnf install -y zoom_x86_64.rpm

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

install_teams:
  pkg.installed:
    - names:
      - wget
  cmd.run:
    - name: |
        wget https://packages.microsoft.com/yumrepos/ms-teams/teams-1.3.00.5153-1.x86_64.rpm
        sudo dnf install -y teams-1.3.00.5153-1.x86_64.rpm
        sudo dnf install -y libXScrnSaver


{% endif %}

