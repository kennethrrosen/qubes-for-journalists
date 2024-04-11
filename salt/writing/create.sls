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

writing-prefs-id:
  qvm.prefs:
    - name: writing
    - netvm: ''
    - disk: 75G
    - memory: 8000
    - maxmem: 8000
    - vcpus: 2
    - autostart: false

writing-features-id:
  qvm.features:
    - name: writing
    - disable:
      - service.qubes-update-check
    - enable:
      - service.cupsd
      - syncthing
      - service.cups
    - set:
      - menu-items: libreoffice-writer.desktop split-browser.desktop split-browser-safest.desktop
      
syncthing-present-id:
  qvm.present:
    - name: syncthing
    - template: fedora-39
    - label: orange
    - class: StandaloneVM

syncthing-prefs-id:
  qvm.prefs:
    - name: syncthing
    - netvm: sys-firewall
    - disk: 75G
    - memory: 800 
    - maxmem: 800
    - vcpus: 1

/etc/qubes/policy.d:
  file.directory:
    - user: root
    - group: root
    - mode: '0755'

/etc/qubes/policy.d/30-user.policy:
  file.append:
    - name: /etc/qubes/policy.d/30-user.policy
    - text: |
        #syncthing
        admin.vm.Start + writing syncthing allow target=dom0
        admin.vm.Shutdown + writing syncthing allow target=dom0
        service.CheckSyncthing + syncthing writing allow target=dom0
        #todo shared-folders-permissions        

ensure-qubes-shared-folders-dom0-exists:
  file.managed:
    - name: /qubes-shared-folders-dom0.rpm
    - source: salt://files/qubes-shared-folders-dom0-0.2.1-53.fc37.noarch.rpm

install-dom0-qubes-shared-folders:
  cmd.run:
    - name: sudo dnf install -y /qubes-shared-folders-dom0.rpm

{% elif grains['id'] == 'writing' %}

install-contrib-repos:
 file.managed:
     - name: /etc/yum.repos.d/qubes-contrib-vm-r4.2.repo
     - source: salt://writing/files/qubes-contrib-vm-r4.2.repo
     - user: root
     - group: root
     - mode: '0644'

writing-install-packages:
  pkg.installed:
    - pkgs: 
      - qubes-split-browser
      - libreoffice
#      - wine64
      - winetricks
#      - wine32:i386
#      - winbind
    - pkg.uptodate:
      - refresh: True

#todo
install-crossover:
  cmd.run:
    - name: |
         curl --proxy http://127.0.0.1:8082/ --tlsv1.2 --proto =https --max-time 180 -0 http://crossover.codeweavers.com/redirect/crossover.rpm --output crossover.rpm
         dnf install -y ./crossover.rpm

ensure-qubes-shared-folders-writ-exists:
  file.managed:
    - name: /qubes-shared-folders.rpm
    - source: salt://writing/files/qubes-shared-folders-0.3.1-63.fc39.x86_64.rpm

install-writ-qubes-shared-folders:
  cmd.run:
    - name: sudo dnf install -y ./qubes-shared-folders.rpm

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
    - mode: '0755'

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
    - mode: '0755'

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
    - mode: '0755'

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
    - mode: '0755'

manage-syncthing-mount-service-enable:
  service.enabled:
    - name: syncthing-mount.service

manage-syncthing-mount-timer-enable:
  service.enabled:
    - name: syncthing-mount.timer

manage-syncthing-mount-shutdown-enable:
  service.enabled:
    - name: syncthing-shutdown.service

ensure-autostart-directory:
  file.directory:
    - name: /home/user/.config/autostart
    - user: user
    - group: user
    - mode: '0755'
    - makedirs: True

{% elif grains['id'] == 'syncthing' %}

ensure-qubes-shared-folders-syncthing-exists:
  file.managed:
    - name: /qubes-shared-folders.rpm
    - source: salt://writing/files/qubes-shared-folders-0.3.1-63.fc39.x86_64.rpm     

install-syncthing-qubes-shared-folders:
  cmd.run:
    - name: sudo dnf install -y /qubes-shared-folders.rpm

install-syncthing-suite:
  pkg.installed:
    - pkgs:
      - syncthing
#      - syncthingtray
    - pkg.uptodate:
      - refresh: True

manage-syncthing-rc-local:
  file.managed:
    - name: /rw/config/rc.local
    - contents: |
        #!/bin/sh
        syncthing
#        syncthingtray
    - mode: '0755'

{% endif %}
