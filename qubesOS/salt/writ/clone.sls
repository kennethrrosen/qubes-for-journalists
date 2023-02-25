clone_precursor:
  qvm.template_installed:
    - name: fedora-36-minimal

writ-template-clone:
  qvm.clone:
    - name: writ-template
    - source: fedora-36-minimal

writ-template-label:
  qvm.label:
    - name: writ-template
    - label: yellow
