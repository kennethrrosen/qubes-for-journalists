#!/bin/bash

# Block bogons and private networks on WAN
pfctl -t bogons -T add -f /usr/local/etc/pfBlockerNG/bogons.txt
pfctl -t RFC1918 -T add -f /usr/local/etc/pfBlockerNG/RFC1918.txt
pfctl -e
pfctl -a wan -p tcp -m tcp -s RFC1918 -j PASS
pfctl -a wan -p udp -m udp -s RFC1918 -j PASS
pfctl -a wan -p icmp -s RFC1918 -j PASS
pfctl -a wan -p tcp -m tcp -s bogons -j DROP
pfctl -a wan -p udp -m udp -s bogons -j DROP
pfctl -a wan -p icmp -s bogons -j DROP

# Block traffic to and from countries where you don't need to allow traffic
pfctl -t countryblock -T add CN/24,CU/24,IR/24,KP/24,SD/24,SY/24
pfctl -a wan -p tcp -m tcp -s countryblock -j DROP
pfctl -a wan -p udp -m udp -s countryblock -j DROP

# Allow all outbound traffic from LAN
pfctl -a lan -p tcp -m tcp -j PASS
pfctl -a lan -p udp -m udp -j PASS
pfctl -a lan -p icmp -j PASS

# Allow DNS traffic
pfctl -a wan -p udp -m udp -d lan --dport 53 -j PASS
pfctl -a wan -p tcp -m tcp -d lan --dport 53 -j PASS

# Allow HTTP and HTTPS traffic
pfctl -a wan -p tcp -m tcp -d lan --dport 80 -j PASS
pfctl -a wan -p tcp -m tcp -d lan --dport 443 -j PASS

# Allow OPNvpn and ProtonVPN traffic
pfctl -a wan -p udp -m udp -d lan --dport 41641 -j PASS
pfctl -a wan -p udp -m udp -d lan --dport 41642 -j PASS
pfctl -a wan -p udp -m udp -d lan --dport 1194 -j PASS

# Allow Tailscale traffic
pfctl -a wan -p udp -m udp -d lan --dport 41641 -j PASS
pfctl -a wan -p udp -m udp -d lan --dport 41642 -j PASS
pfctl -a wan -p udp -m udp -d lan --dport 1194 -j PASS
pfctl -a wan -p tcp -m tcp -d lan --dport 443 -j PASS

# Allow NTP traffic
pfctl -a wan -p udp -m udp -d lan --dport 123 -j PASS

# Enable NAT
pfctl -a wan -o -j MASQUERADE

# Enable IP blocking
pfctl -t blocked_ports -T flush
pfctl -t blocked_ports -T add 135
pfctl -t blocked_ports -T add 137
pfctl -t blocked_ports -T add 138
pfctl -t blocked_ports -T add 139
pfctl -t blocked_ports -T add 445
pfctl -t blocked_ports -T add 1900

# Add FireHOL Level 2 blocklist
curl -s "http://iplists.firehol.org/files/firehol_level2.netset" | grep -v '^#' | sed 's/^/block drop quick from any to any port 1:65535 tagged FireHOL_Level_2\n/' > /tmp/firehol_level2_rules
pfctl -t FireHOL_Level_2 -T replace -f /tmp/firehol_level2_rules
