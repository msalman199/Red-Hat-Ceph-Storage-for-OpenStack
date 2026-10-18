#!/bin/bash

echo "OSD Reweighting for Hotspot Mitigation"
echo "======================================"

sudo ceph osd df | awk 'NR>1 && $8 ~ /^[0-9.]+$/ {
    osd=$1; weight=$3; util=$8
    if (util > 1.3) {
        new_weight = weight * 0.9
        print "sudo ceph osd reweight osd." osd " " new_weight " # Current util: " util
    } else if (util < 0.7) {
        new_weight = weight * 1.1
        if (new_weight > 1.0) new_weight = 1.0
        print "sudo ceph osd reweight osd." osd " " new_weight " # Current util: " util
    }
}' > /tmp/reweight_commands.sh

echo "Suggested reweighting commands:"
cat /tmp/reweight_commands.sh

if [ -s /tmp/reweight_commands.sh ]; then
    read -p "Apply these reweighting changes? (y/N): " confirm
    if [[ $confirm == [yY] ]]; then
        bash /tmp/reweight_commands.sh
        echo "Reweighting applied. Current status:"
        sudo ceph -s
    else
        echo "Reweighting cancelled."
    fi
else
    echo "No OSDs exceed the reweighting thresholds. No action needed."
fi
