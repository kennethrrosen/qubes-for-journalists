{#
SPDX-FileCopyrightText: 2024 Kenneth R. Rosen <kennethrrosen@proton.me>
SPDX-License-Identifier: GPL-3.0-or-later
#}

{% if grains['id'] == 'dom0' %}

dangerzone_depends:
  qvm.template_installed:
    - name: fedora-38

dangerzone-present:
  qvm.present:
    - name: tpl-dangerzone
    - label: black
    - template: fedora-38
    - class: TemplateVM
    - properties:
        template_for_dispvms: True
    - require:
      - qvm: dangerzone_depends

create-dz-dvm:
  qvm.present:
    - name: dz-dvm
    - label: red
    - template: tpl-dangerzone
    - class: AppVM
    - properties:
        netvm: ''
        template_for_dispvms: True
        default_dispvm: ''
    - require:
      - qvm: dangerzone-present

create-rpc-policy-folder:
  file.managed:
    - name: /etc/qubes/policy.d/50-dangerzone.policy
    - contents: |
        dz.Convert         *       @anyvm       @dispvm:dz-dvm  allow
    - require:
      - qvm: create-dz-dvm

{% elif grains['id'] == 'tpl-dangerzone' %}

install-dangerzone:
  cmd.run:
    - name: |
        sudo dnf config-manager --add-repo=https://packages.freedom.press/yum-tools-prod/dangerzone/dangerzone.repo
        sudo dnf install --assumeyes --nogpgcheck dangerzone-qubes

{% endif %}
