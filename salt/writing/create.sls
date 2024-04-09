{#
SPDX-FileCopyrightText: 2024 Kenneth R. Rosen <kennethrrosen@proton.me>
SPDX-License-Identifier: GPL-3.0-or-later
#}

{% if grains['id'] == 'dom0' %}

vms-depends:
  qvm.template_installed:
    - name: fedora-39

writing-present-id:
  qvm.present:
    - name: writing
    - template: fedora-39
    - label: blue
    - class: StandaloneVM
    - netvm: sys-firewall
    - disk: 75G
    - memory: 8000 
    - vcpus: 2
    - autostart: false
    - service:
      - enabled:
        - service.cupsd
        - syncthing
        - service.cups
    - require:
        - qvm: vms-depends
    - features:
      - set:
        - menu-items: libreoffice-writer.desktop split-browser.desktop split-browser-safest.desktop
        - qubes-update-check: false

writing-running-id:
  qvm.running:
    - name: writing
    - require:
      - qvm: writing-present-id
    - require:
        - qvm: writing-present-id

syncthing-present-id:
  qvm.present:
    - name: syncthing
    - template: fedora-39
    - label: orange
    - class: StandaloneVM
    - netvm: sys-firewall
    - disk: 75G
    - memory: 800 
    - vcpus: 1
    - autostart: false
    - service:
      - enabled:
        - qubes-update-check
    - require:
      - qvm: vm-depends
      - qvm: writing-present-id

syncthing-running-id:
  qvm.running:
    - name: syncthing
    - require:
      - qvm: syncthing-present-id

/etc/qubes/policy.d:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/etc/qubes/policy.d/30-user.policy:
  file.append:
    - name: /etc/qubes/policy.d/30-user.policy
    - text: |
        #syncthing
        admin.vm.Start + writ syncthing allow target=dom0
        admin.vm.Shutdown + writ syncthing allow target=dom0
        service.CheckSyncthing + syncthing writ allow target=dom0
    - require:
      - file: /etc/qubes/policy.d

install-dom0-qubes-shared-folders:
  pkg.installed:
    - sources:
      - mypackage: salt://files/qubes-shared-folders-dom0-0.2.1-53.fc37.noarch.rpm

{% elif grains['id'] == 'writing' %}

install-contrib-repos:
    install-contrib-repos:
        file.managed:
            - name: /etc/yum.repos.d/qubes-contrib-vm-r4.2.repo
            - source: salt://writing/files/qubes-contrib-vm-r4.2.repo
            - user: root
            - group: root
            - mode: 0644
            - require:
                - pkg: writing-running-id

writing-update:
  - pkg.uptodate:
    - refresh: True
    - require:
      - qvm: writing-running-id

writing-install-split-browser:
  pkg.installed:
    - name: qubes-split-browser
    - require:
      - qvm: writing-update

install-crossover:
  qvm.cmd:
    - names:
      - writing: sudo dnf install -y http://crossover.codeweavers.com/redirect/crossover.rpm
    - require:
      - qvm: writing-update

get-and-install-qubes-shared-folders:
        pkg.installed:
          - name: qubes-shared-folders
          - sources:
            - repo: https://repo.rudd-o.com/unstable/fc39/packages/qubes-shared-folders-0.3.1-63.fc39.x86_64.rpm
          - require:
            - qvm: install-crossover

install-libreoffice:
  pkg.installed:
    - libreoffice
    - winetricks 
    - wine64
    - wine32:i386 
    - winbind
    - require:
      - qvm: get-and-install-qubes-shared-folders

manage-syncthing-code:
  file.managed:
    - name: /usr/bin/syncthing-mount
    - contents: |
        #!/bin/sh
        # service.CheckSyncthing deprecated because it's not being run by systemd
        # Log file location
        LOG_FILE=/var/log/syncthing-mount.log

        TIMEOUT=300  # Timeout in seconds
        START_TIME=$(date +%s)

        echo "Beginning script" >> $LOG_FILE
        sleep 2

        while true; do
            if qrexec-client-vm syncthing admin.vm.Start </dev/null; then
                echo "Syncthing service is active" >> $LOG_FILE
                break  # Exit the loop if Syncthing is active
            else
                echo "Syncthing service is not active, waiting" >> $LOG_FILE
            fi
            
            CURRENT_TIME=$(date +%s)
            if [ $((CURRENT_TIME - START_TIME)) -ge $TIMEOUT ]; then
                echo "Timeout waiting for Syncthing to be ready" >> $LOG_FILE
                break  # Exit the loop on timeout
            fi
            sleep 5  # Check every 5 seconds
        done

        sleep 5
        # Mount Syncthing folder
        echo "Creating mount point" >> $LOG_FILE
        mkdir -p /home/user/mnt
        echo "Attempting to mount Syncthing folder" >> $LOG_FILE
        systemctl start syncthing-mount.timer
        qvm-mount-folder syncthing /home/user/Sync /home/user/mnt
        sleep 5
        # Check if mount was successful and log
        if mount | grep -q '/home/user/mnt'; then
            echo "Mount operation successful" >> $LOG_FILE
            # Copy Documents
            echo "Copying Documents to mounted folder" >> $LOG_FILE
            sudo cp -r /home/user/Documents/* /home/user/mnt
            echo "Copy operation completed" >> $LOG_FILE
        else
            echo "Mount operation failed" >> $LOG_FILE
        fi

        sudo umount /home/user/mnt
        sudo rm -rf /home/user/mnt
    - mode: 755
    - require:
      - qvm: install-libreoffice

manage-syncthing-mount-service:
  file.managed:
    - name: /etc/systemd/system/syncthing-mount.service
    - contents: |
        [Unit]
        Description=Mount Syncthing Folder and Copy Documents
        After=network.target

        [Service]
        Type=oneshot
        ExecStart=/usr/bin/syncthing-mount

        [Install]
        WantedBy=multi-user.target
    - mode: 755
    - require:
      - qvm: manage-syncthing-code

manage-syncthing-mount-timer:
  file.managed:
    - name: /etc/systemd/system/syncthing-mount.timer
    - contents: |
        [Unit]
        Description=Run Syncthing copy service every hour

        [Timer]
        OnCalendar=*:0/30
        Persistent=true

        [Install]
        WantedBy=timers.target
    - mode: 755
    - require:
      - qvm: manage-syncthing-mount-service

manage-syncthing-mount-shutdown:
  file.managed:
    - name: /etc/systemd/system/syncthing-shutdown.service
    - contents: |
        [Unit]
        Description=Shutdown Syncthing VM
        After=qubes-qrexec-agent.service

        [Service]
        Type=oneshot
        RemainAfterExit=true
        ExecStop=qrexec-client-vm syncthing admin.vm.Shutdown -v

        [Install]
        WantedBy=default.target
    - mode: 755
    - require:
      - qvm: manage-syncthing-mount-timer

manage-syncthing-mount-service-enable:
  service.enabled:
    - name: syncthing-mount.service
    - require:
      - qvm: manage-syncthing-mount-shutdown

manage-syncthing-mount-timer-enable:
  service.enabled:
    - name: syncthing-mount.timer
    - require:
      - qvm: manage-syncthing-mount-service-enable

manage-syncthing-mount-shutdown-enable:
  service.enabled:
    - name: syncthing-shutdown.service
    - require:
      - qvm: manage-syncthing-mount-timer-enable

writing-reset-netvm:
  qvm.reset_netvm:
    - name: writing
    - netvm: ''
    - require:
      - qvm: manage-syncthing-mount-shutdown-enable

ensure-autostart-directory:
  file.directory:
    - name: /home/user/.config/autostart
    - user: user
    - group: user
    - mode: 755
    - makedirs: True
    - require:
      - qvm: writing-present-id

move-crossover-desktop-file:
  file.managed:
    - name: /home/user/.config/autostart/libreoffice.desktop
    - source: /usr/share/applications/libreoffice.desktop
    - user: user
    - group: user
    - mode: 644
    - makedirs: True
    - require:
      - file: ensure-autostart-directory
      - qvm: writing-running-id

refresh-menu-entries:
  cmd.run:
    - name: 'touch /usr/share/applications/*.desktop && qvm-sync-appmenus writ'
    - require:
      - pkg: install-libreoffice
      - pkg: install-crossover

{% elif grains['id'] == 'syncthing' %}

syncthing-update:
  - pkg.uptodate:
    - refresh: True
    - require:
      - qvm: syncthing-running-id

get-and-install-qubes-shared-folders:
        pkg.installed:
          - name: qubes-shared-folders
          - sources:
            - repo: https://repo.rudd-o.com/unstable/fc39/packages/qubes-shared-folders-0.3.1-63.fc39.x86_64.rpm
          - require:
            - qvm: syncthing-update

install-syncthing-suite:
  pkg.installed:
    - syncthing
    - syncthingtray
    - require:
      - qvm: syncthing-running-id

manage-syncthing-rc-local:
  file.managed:
    - name: /rw/config/rc.local
    - contents: |
        #!/bin/sh
        syncthing
        syncthingtray
    - mode: 755
    - require:
      - qvm: install-syncthing-suite

{% endif %}
