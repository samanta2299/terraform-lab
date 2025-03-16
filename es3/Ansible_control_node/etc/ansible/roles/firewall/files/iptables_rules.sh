#!/bin/bash
# Reset delle regole di iptables
iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Definizione delle interfacce
INTERNET="enp0s8"   # Interfaccia NAT verso Internet
EXT_NET="enp0s9"    # Interfaccia subnet_a (rete esterna)
INT_NET="enp0s10"   # Interfaccia subnet_b (rete interna)
DMZ_NET="enp0s16"   # Interfaccia subnet_dmz (DMZ)
MGMT_NET="enp0s17"  # Interfaccia hostonly (management)

# Consenti traffico locale su loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Consenti SSH da rete di gestione (per Ansible)
iptables -A INPUT -i $MGMT_NET -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -o $MGMT_NET -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Consenti SSH da rete interna
iptables -A INPUT -i $INT_NET -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -o $INT_NET -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Connessioni stabilite e correlate
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Consenti ICMP (ping) su tutte le interfacce
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A FORWARD -p icmp -j ACCEPT

# Regole per la DMZ
# Consenti accesso HTTP/HTTPS dalla rete esterna verso DMZ
iptables -A FORWARD -i $EXT_NET -o $DMZ_NET -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i $EXT_NET -o $DMZ_NET -p tcp --dport 443 -j ACCEPT

# Consenti accesso HTTP/HTTPS dalla rete interna verso DMZ
iptables -A FORWARD -i $INT_NET -o $DMZ_NET -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i $INT_NET -o $DMZ_NET -p tcp --dport 443 -j ACCEPT

# Blocca traffico diretto tra rete esterna e interna
iptables -A FORWARD -i $EXT_NET -o $INT_NET -j DROP
iptables -A FORWARD -i $INT_NET -o $EXT_NET -j DROP

# Consenti traffico da DMZ verso Internet (solo HTTP/HTTPS)
iptables -A FORWARD -i $DMZ_NET -o $INTERNET -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i $DMZ_NET -o $INTERNET -p tcp --dport 443 -j ACCEPT

# Consenti traffico da rete interna verso Internet
iptables -A FORWARD -i $INT_NET -o $INTERNET -j ACCEPT

# Traffico DNS
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A INPUT -p tcp --sport 53 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A FORWARD -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -p tcp --dport 53 -j ACCEPT
iptables -A FORWARD -p udp --sport 53 -j ACCEPT
iptables -A FORWARD -p tcp --sport 53 -j ACCEPT

# ABILITA NAT per accesso a Internet
iptables -t nat -A POSTROUTING -o $INTERNET -j MASQUERADE

# Log dei pacchetti scartati
iptables -A INPUT -j LOG --log-prefix "IPTables-Input-Dropped: " --log-level 4
iptables -A FORWARD -j LOG --log-prefix "IPTables-Forward-Dropped: " --log-level 4

# SALVA LE REGOLE
mkdir -p /etc/iptables
iptables-save > /etc/iptables/rules.v
