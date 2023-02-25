#!/bin/bash

# Set up logging
LOG_FILE="/var/log/journo-shaker-install.log"
exec > >(tee -i $LOG_FILE)
exec 2>&1

# Get the user's home directory
user_home=$(eval echo "~${SUDO_USER}")

# Move the unzipped journo-shaker folder to /srv/salt/
if [ -d ~/journo-shaker ]; then
    sudo mv ~/journo-shaker /srv/salt/
else
    echo "Error: the journo-shaker folder was not found in the home directory of the current user."
    exit 1
fi

# Replace "user" with the actual username in all the salt state files
if sudo find /srv/salt/journo-shaker -type f -name "*.sls" -exec sed -i "s/user/${SUDO_USER}/g" {} \; ; then
    echo "Successfully replaced 'user' with the actual username in all the salt state files."
else
    echo "Error: failed to replace 'user' with the actual username in all the salt state files."
    exit 1
fi

# Set the correct permissions on the salt files
if sudo chown -R root:root /srv/salt/journo-shaker && sudo chmod -R 644 /srv/salt/journo-shaker ; then
    echo "Successfully set the correct permissions on the salt files."
else
    echo "Error: failed to set the correct permissions on the salt files."
    exit 1
fi

# Enable all the Salt top files
if sudo qubesctl top.enable /srv/salt/journo-shaker/*.top ; then
    echo "Successfully enabled all the Salt top files."
else
    echo "Error: failed to enable all the Salt top files."
    exit 1
fi

# Apply all the Salt state files
if sudo qubesctl --verbose state.apply ; then
    echo "Successfully applied all the Salt state files."
else
    echo "Error: failed to apply all the Salt state files."
    exit 1
fi

echo "Journo-Shaker installation completed successfully. Please check the log file at ${LOG_FILE} for details."
