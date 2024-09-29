{#
SPDX-FileCopyrightText: 2024 Kenneth R. Rosen <kennethrrosen@proton.me>
SPDX-License-Identifier: GPL-3.0-or-later
#}

{% if grains['id'] == 'dom0' %}

vms-depends:
  qvm.template_installed:
    - name: fedora-40

dangerzone-present-id:
  qvm.clone:
    - name: sd-dangerzone-template
    - source: fedora-40

dangerzone-features-id:
  qvm.features:
    - name: sd-dangerzone-template
    - enable:
      - appmenus-dispvm

dz-dvm-present-id:
  qvm.present:
    - name: sd-dangerzone-dvm
    - label: red
    - template: sd-dangerzone-template
    - class: AppVM

dz-dvm-prefs-id:
  qvm.prefs:
    - name: sd-dangerzone-dvm
    - netvm: ''
    - template_for_dispvms: True
    - default_dispvm: sd-dangerzone-dvm

dz-dvm-features-id
  qvm.features:
    - name: sd-dangerzone-dvm
    - set:
      - menu-items: press.freedom.dangerzone.desktop

dz-disp-present-id:
  qvm.present:
    - name: disp-sd-dangerzone
    - label: red
    - template: sd-dangerzone-dvm
    - default_dispvm: sd-dangerzone-dvm
    - class: DispVM

create-rpc-policy:
  file.managed:
    - name: /etc/qubes/policy.d/50-dangerzone.policy
    - contents: |
        dz.Convert         *       @anyvm       @dispvm:dz-dvm  allow

{% elif grains['id'] == 'sd-dangerzone-template' %}

install-dangerzone:
  cmd.run:
    - name: |
        sudo dnf config-manager --add-repo=https://packages.freedom.press/yum-tools-prod/dangerzone/dangerzone.repo
        sudo dnf install -y --nogpgcheck dangerzone-qubes

{% elif grains['id'] == 'disp-sd-dangerzone' %}

  qvm.features:
    - name: sd-dangerzone-dvm
    - set:
      - menu-items: press.freedom.dangerzone.desktop

{% endif %}
