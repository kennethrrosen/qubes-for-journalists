{#
SPDX-FileCopyrightText: 2024 Kenneth R. Rosen <kennethrrosen@proton.me>
SPDX-License-Identifier: GPL-3.0-or-later
#}

{% if grains['id'] == 'dom0' %}

{% set tpl_vm = 'tpl-securedrop' %}
{% set source_vm = 'whonix-wokrstation-17' %}
{% set external_url = 'YOUR_SECUREDROP_TOR_LINK_HERE %}

clone_whonix_ws:
  qvm.clone:
    - name: {{ tpl_vm }}
    - source: {{ source_vm }}

securedrop-features-id:
  qvm.features:
    - name: {{ tpl_vm }}
    - enable:
      - appmenus-dispvm

decuredrop-present-id:
  qvm.present:
    - name: securedrop-viewer
    - label: green
    - template: tpl-securedrop
    - class: AppVM

dz-dvm-prefs-id:
  qvm.prefs:
    - name: securedrop-viewer
    - netvm: sys-whonix
    - default_dispvm: tpl-securedrop

modify_html_pages:
  cmd.run:
    - names: |
            qvm-run -p {{ tpl_vm }} "sed -i 's|file:///usr/share/doc/homepage/whonix-welcome-page/whonix.html|{{ external_url }}|g' /usr/share/doc/homepage/whonix-welcome-page/whonix.html"
            qvm-run -p {{ tpl_vm }} "sed -i 's|file:///usr/share/qubes/xdg-override/doc/homepage/whonix-welcome-page/whonix.html|{{ external_url }}|g' /usr/share/qubes/xdg-override/doc/homepage/whonix-welcome-page/whonix.html"
