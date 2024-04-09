{#
SPDX-FileCopyrightText: 2024 Kenneth R. Rosen <kennethrrosen@proton.me>
SPDX-License-Identifier: GPL-3.0-or-later
#}

{% if grains['id'] == 'dom0' %}

signal-create_template:
  qvm.present:
    - name: tpl-signal
    - source: debian-12
    - properties:
        label: black
        class: TemplateVM

signal-create_appvm:
  qvm.present:
    - name: signal
    - properties:
        template: tpl-signal
        label: yellow
        netvm: sys-whonix
        autostart: False
    - features:
        - disable:
          - service.cups
          - service.cups-browsed
          - service.tinyproxy
          - service.tracker
          - service.evolution-data-server
        - set:
          - menu-items: "signal-desktop.desktop"

{% elif grains['id'] == 'tpl-signal' %}

install-signal-keyring:
  cmd.run:
    - name: wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > /usr/share/keyrings/signal-desktop-keyring.gpg
    - unless: test -f /usr/share/keyrings/signal-desktop-keyring.gpg

add-signal-repo:
  file.managed:
    - name: /etc/apt/sources.list.d/signal-xenial.list
    - contents: deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main
    - mode: '0644'
    - user: root
    - group: root
    - require:
      - cmd: install-signal-keyring

update-and-install-signal:
  pkg.installed:
    - names:
      - signal-desktop
    - refresh: True
    - require:
      - file: add-signal-repo

{% elif grains['id'] == 'signal' %}

setup_firewall:
  cmd.run:
  - require:
    - qvm: signal
      - name: |
        qvm-check -q --running signal && qvm-pause signal
        qvm-firewall signal reset
        qvm-firewall signal del --rule-no 0
        qvm-check -q --running signal && qvm-unpause signal
        qvm-firewall signal add accept signal.org
        qvm-firewall signal add accept storage.signal.org
        qvm-firewall signal add accept chat.signal.org
        qvm-firewall signal add accept cdn.signal.org
        qvm-firewall signal add accept cdn2.signal.org
        qvm-firewall signal add accept sfu.voip.signal.org
        qvm-firewall signal add accept turn.voip.signal.org
        qvm-firewall signal add accept turn2.voip.signal.org
        qvm-firewall signal add accept turn3.voip.signal.org

setup_desktop_autostart:
  file.symlink:
    - name: /home/user/.config/autostart/signal-desktop.desktop
    - target: /usr/share/applications/signal-desktop.desktop
    - user: user
    - group: user
    - force: True
    - makedirs: True

{% endif %}
