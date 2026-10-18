#!/bin/bash

nodes=("ceph-mon-01" "ceph-osd-01" "ceph-osd-02" "ceph-osd-03" "ceph-mgr-01")

echo "Network Latency Test Results:"
echo "============================="

for source in "${nodes[@]}"; do
    for target in "${nodes[@]}"; do
        if [ "$source" != "$target" ]; then
            echo -n "$source -> $target: "
            ssh "$source" "ping -c 3 -q $target 2>/dev/null | tail -1 | awk -F'/' '{print \$5\" ms avg\"}'" || echo "Failed"
        fi
    done
done
