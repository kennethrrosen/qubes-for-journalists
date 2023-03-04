# prerequisites include postfix subprocess lm-sensors
# and then add as cron job:
#    Log in to the OPNsense web interface.
#    Go to System > Settings > Cron.
#    Click on "Add".
#    Enter the following information:
#        "User": root
#        "Command": /usr/local/bin/python3 /path/to/opnsense_report.py
#        "Description": OPNsense Report Script
#        "Minute": 0
#        "Hour": 6
#        "Day of the Month": *
#        "Month": *
#        "Day of the Week": *
#    Click on "Save".
import subprocess
import shutil

# Define email addresses
smtp_from = 'opnsense@example.com'
smtp_to = 'admin@example.com'
subject = input("Enter email subject: ")

# Define shell command to collect all data
shell_command = """
echo "<h2>Local Disk Space/Usage:</h2>"
df -h | sed -e 's/^/<pre>/' -e 's/$/<\\/pre>/' -e '1d'
echo "<h2>CPU Power and Temperature:</h2>"
sensors | sed -e 's/^/<pre>/' -e 's/$/<\\/pre>/'
echo "<h2>AdBlockHome Statistics:</h2>"
curl -s http://localhost:3000/api/status | jq '.' | sed -e 's/^/<pre>/' -e 's/$/<\\/pre>/'
echo "<h2>IP Addresses:</h2>"
ip -4 address show | sed -e 's/^/<pre>/' -e 's/$/<\\/pre>/'
echo "<h2>Port Scanning Messages:</h2>"
grep -i nmap /var/log/syslog | sed -e 's/^/<pre>/' -e 's/$/<\\/pre>/'
echo "<h2>SSH Login Attempts:</h2>"
grep sshd.*Failed /var/log/auth.log | sed -e 's/^/<pre>/' -e 's/$/<\\/pre>/'
echo "<h2>Active LAN IPs:</h2>"
arp -a | sed -e 's/^/<pre>/' -e 's/$/<\\/pre>/'
echo "<h2>LAN Bandwidth Usage:</h2>"
iftop -i lan0 -s 5 -t | sed -e 's/^/<pre>/' -e 's/$/<\\/pre>/'
echo "<h2>WAN Bandwidth Usage:</h2>"
iftop -i wan0 -s 5 -t | sed -e 's/^/<pre>/' -e 's/$/<\\/pre>/'
echo "<h2>WiFi Bandwidth Usage:</h2>"
iftop -i wlan0 -s 5 -t | sed -e 's/^/<pre>/' -e 's/$/<\\/pre>/'
echo "<h2>WireGuard Tunnel Activity:</h2>"
wg show all | sed -e 's/^/<pre>/' -e 's/$/<\\/pre>/'
echo "<h2>Zenarmor Blocks:</h2>"
grep block /var/log/syslog | sed -e 's/^/<pre>/' -e 's/$/<\\/pre>/'
echo "<h2>DHCP Requests:</h2>"
grep dhcp4 /var/log/syslog | sed -e 's/^/<pre>/' -e 's/$/<\\/pre>/'
echo "<h2>Intrusion Detection Alerts:</h2>"
suricatasc -c dump eve.json alert | sed -e 's/^/<pre>/' -e 's/$/<\\/pre>/'
"""

# Run shell command and collect output
result = subprocess.run(['sh', '-c', shell_command], capture_output=True, text=True)

# Capture network traffic data
os.makedirs('/var/log/tcpdump', exist_ok=True)
tcpdump_command = ['/usr/sbin/tcpdump', '-i', 'lan0', '-w', '/var/log/tcpdump/lan0.pcap']
subprocess.run(tcpdump_command)

# Construct the email message
body = '<html><head></head><body><table border="1">'
body += '<tr><th>Category</th><th>Details</th></tr>'

for section, output in output_dict.items():
    body += f'<tr><td>{section}</td><td><pre>{output}</pre></td></tr>'

body += '</table></body></html>'
message = f'To: {smtp_to}\nFrom: {smtp_from}\nSubject: {subject}\nContent-Type: text/html\n\n{body}'

# Attach network switch traffic data to the email
attachment_path = '/var/log/tcpdump/lan0.pcap'
with open(attachment_path, 'rb') as attachment:
    attachment_data = attachment.read()
attachment_name = os.path.basename(attachment_path)

# Send the email using Postfix
sendmail_command = ['/usr/sbin/sendmail', '-t']
with subprocess.Popen(sendmail_command, stdin=subprocess.PIPE) as proc:
    proc.communicate(message.encode())
