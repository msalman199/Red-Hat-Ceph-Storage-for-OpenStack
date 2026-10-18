#!/bin/bash

echo "Applying network optimizations..."

sudo tee -a /etc/sysctl.conf > /dev/null << SYSCTL
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.core.rmem_default = 65536
net.core.wmem_default = 65536
net.ipv4.tcp_rmem = 4096 65536 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.netfilter.nf_conntrack_max = 1048576
SYSCTL

sudo sysctl -p

echo "Network optimization complete"
