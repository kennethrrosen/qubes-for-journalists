{#
SPDX-FileCopyrightText: 2024 Kenneth R. Rosen <kennethrrosen@proton.me>
SPDX-License-Identifier: GPL-3.0-or-later
#}

{% if grains['id'] == 'dom0' %}

vms-depends:
  qvm.template_installed:
    - name: fedora-39

dangerzone-present-id:
  qvm.clone:
    - name: tpl-dangerzone
    - source: fedora-39

dangerzone-features-id:
  qvm.features:
    - name: tpl-dangerzone
    - enable:
      - appmenus-dispvm

dz-dvm-present-id:
  qvm.present:
    - name: dz-dvm
    - label: red
    - template: tpl-dangerzone
    - class: AppVM

dz-dvm-prefs-id:
  qvm.prefs:
    - name: dz-dvm
    - netvm: ''
    - template_for_dispvms: True
    - default_dispvm: ''

dz-dvm-features-id
  qvm.features:
    - name: dz-dvm
    - set:
      - menu-items: press.freedom.dangerzone.desktop

create-rpc-policy:
  file.managed:
    - name: /etc/qubes/policy.d/50-dangerzone.policy
    - contents: |
        dz.Convert         *       @anyvm       @dispvm:dz-dvm  allow

{% elif grains['id'] == 'tpl-dangerzone' %}

install-dangerzone:
  cmd.run:
    - name: |
        dnf config-manager --add-repo=https://packages.freedom.press/yum-tools-prod/dangerzone/dangerzone.repo
        dnf install -y --nogpgcheck dangerzone-qubes

{% endif %}
