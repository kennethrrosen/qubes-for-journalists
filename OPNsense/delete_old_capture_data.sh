## Reporting companion script, capturing network traffic can generate a lot of data, which can quickly fill up your disk space. 
## You'll want to periodically delete old capture files to prevent your disk from running out of space
## Save this script to a file, such as /usr/local/bin/delete_old_captures.sh, make executable,
## and then add a cron job to run it once a day (crontab -e): 
## 0 0 * * * /usr/local/bin/delete_old_captures.sh

#!/bin/bash

find /var/log/tcpdump -type f -mtime +7 -delete
