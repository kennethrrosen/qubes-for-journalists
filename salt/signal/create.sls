{#
SPDX-FileCopyrightText: 2024 Kenneth R. Rosen <kennethrrosen@proton.me>
SPDX-License-Identifier: GPL-3.0-or-later
#}

{% if grains['id'] == 'dom0' %}

signal-create_template:
  qvm.present:
    - name: tpl-signal
    - source: fedora-39
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
          - menu-items: "org.signal.Signal.desktop"

{% elif grains['id'] == 'tpl-signal' %}

install-flatpak:
    pkg.installed:
        - names:
            - flatpak
        - refresh: True

install-signal-flatpak:
    pkg.installed:
        - names:
            - org.signal.Signal
        - refresh: True
    require:
        - pkg: install-flatpak

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
    - name: /home/user/.config/autostart/org.Signal.Signal.desktop
    - target: /usr/share/applications/org.signal.Signal.desktop
    - user: user
    - group: user
    - force: True
    - makedirs: True

{% endif %}
