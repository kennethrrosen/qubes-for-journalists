#!/bin/bash
#                                                                                #
# ███████╗██╗    ██╗███████╗███████╗████████╗ ██████╗  ██████╗  ██████╗ ██████╗  #
# ██╔════╝██║    ██║██╔════╝██╔════╝╚══██╔══╝██╔════╝ ██╔═══██╗██╔═══██╗██╔══██╗ #
# ███████╗██║ █╗ ██║█████╗  █████╗     ██║   ██║  ███╗██║   ██║██║   ██║██║  ██║ #
# ╚════██║██║███╗██║██╔══╝  ██╔══╝     ██║   ██║   ██║██║   ██║██║   ██║██║  ██║ #
# ███████║╚███╔███╔╝███████╗███████╗   ██║   ╚██████╔╝╚██████╔╝╚██████╔╝██████╔╝ #
# ╚══════╝ ╚══╝╚══╝ ╚══════╝╚══════╝   ╚═╝    ╚═════╝  ╚═════╝  ╚═════╝ ╚═════╝  #
#                                                                                #
#                                      IT-Beratung mit Fokus auf Datensicherheit #
#                                                                                #
#                            www.sweetgood.de                                    #
#                                                                                #
# Copyright        : All rights reserved!
# Repository url   : https://codeberg.org/SWEETGOOD/andersgood-opnsense-scripts
# Author           : codiflow @ SWEETGOOD, Original sources below
# Filename         : backup-opnsense-via-api.sh
# Created at       : 2023-01-23
# Last changed at  : 2023-01-23
# Description      : Backup script for OPNsense API with optional GPG encryption
# Requirements     : date, curl, gzip, find, gpg (optional)

# Original source: https://forum.opnsense.org/index.php?topic=15349.0
# Alternative script source: https://forum.opnsense.org/index.php?topic=18218.0

# Stop on error
set -e

###################################################
# CONFIGURE THE VARIABLES ACCORDING TO YOUR NEEDS #
###################################################

# API key and secret
#   Create user in OPNsense, apply permission for "Backup API" to user or group
#   and create the API key after creating the user
key="API key for backup user"
secret="API secret for backup user"

# Number of days to keep backups
daystokeep=30

# The path where you want to store your backups (can be every mounted folder)
destination="/path/to/firewall/backups"

# The hostname or IP for your firewall
#   Add :PORT after the Hostname/IP if you changed the port for the webinterface
fwhost="firewall.fqdn or IP"

# Encryption (change to false if you don't need it)
encrypt=true

# Create GPG keypair beforehand and choose a secret passphrase using:
#   gpg --full-gen-key
#
# To decrypt the file afterwards issue the following commands:
#   gpg -d BACKUPFILE.xml.gz.gpg > BACKUPFILE.xml.gz
#   gzip -d BACKUPFILE.xml.gz
identityemail="Email address of locally stored GPG identity"

# Current date (for creating backup filename)
date=$(date +%Y-%m-%d)


#####################################
# NOTHING NEEDS TO BE CHANGED BELOW #
#####################################

# Check if API is reachable
result=$(curl -I -s -k -u "$key":"$secret" https://$fwhost/api/backup/backup/download | head -1)

if [[ $result != *"200"* ]]; then
   echo "Result of the HTTP request was $result"
   exit 1
fi

# Get current unencrypted backup via cURL and save as file
curl -s -k -u "$key":"$secret" https://$fwhost/api/backup/backup/download > $destination/$date.xml

error=$?

# Check for errors
if [ $error -gt 0 ]; then
   echo "cURL returned error number $error"
   exit 1
fi

# Compress the backup file
gzip $destination/$date.xml

# If encryption is enabled
if $encrypt; then
   # Encrypt the backup file
   gpg -e --recipient "$identityemail" $destination/$date.xml.gz
   # Remove unencrypted backup file
   rm $destination/$date.xml.gz
fi

# Data retention
find $destination/* -mtime +$daystokeep -exec rm {} \;
