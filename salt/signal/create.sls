{#
SPDX-FileCopyrightText: 2024 Kenneth R. Rosen <kennethrrosen@proton.me>
SPDX-License-Identifier: GPL-3.0-or-later
#}

{% if grains['id'] == 'dom0' %}

vms-depends:
  qvm.template_installed:
    - name: debian-12

signal-create-template-id:
  qvm.clone:
    - name: tpl-signal
    - source: debian-12

signal-create-appvm-id:
  qvm.present:
    - name: signal
    - template: tpl-signal
    - label: yellow
    - class: AppVM

signal-prefs-id:
  qvm.prefs:
    - name: signal
    - netvm: sys-whonix

signal-features-id:
  qvm.features:
    - name: signal
    - disable:
      - service.cups
      - service.cups-browsed
      - service.tinyproxy
      - service.tracker
      - service.evolution-data-server
    - set:
      - menu-items: qubes-start.desktop signal-desktop.desktop

setup-signal-firewall:
  cmd.run:
      - name: |
        qvm-check -q --running signal
        qvm-pause signal
        qvm-firewall signal reset
        qvm-firewall signal del --rule-no 0
        qvm-check -q --running signal
        qvm-unpause signal
        qvm-firewall signal add accept signal.org
        qvm-firewall signal add accept storage.signal.org
        qvm-firewall signal add accept chat.signal.org
        qvm-firewall signal add accept cdn.signal.org
        qvm-firewall signal add accept cdn2.signal.org
        qvm-firewall signal add accept sfu.voip.signal.org
        qvm-firewall signal add accept turn.voip.signal.org
        qvm-firewall signal add accept turn2.voip.signal.org
        qvm-firewall signal add accept turn3.voip.signal.org

{% elif grains['id'] == 'tpl-signal' %}

install-signal-keyring:
  cmd.run:
    - name: |
      curl --proxy http://127.0.0.1:8082/ --tlsv1.2 --proto =https --max-time 180 -0 https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > /usr/share/keyrings/signal-desktop-keyring.gpg
    - unless: test -f /usr/share/keyrings/signal-desktop-keyring.gpg

add-signal-repo:
  file.managed:
    - name: /etc/apt/sources.list.d/signal-xenial.list
    - contents: deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main
    - mode: '0644'
    - user: root
    - group: root

update-and-install-signal:
  pkg.installed:
    - pkgs:
      - signal-desktop
    - refresh: True

{% elif grains['id'] == 'signal' %}

setup-desktop-autostart:
  file.symlink:
    - name: /home/user/.config/autostart/signal-desktop.desktop
    - target: /usr/share/applications/signal-desktop.desktop
    - user: user
    - group: user
    - force: True
    - makedirs: True

{% endif %}
