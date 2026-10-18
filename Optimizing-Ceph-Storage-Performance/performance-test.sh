#!/bin/bash

echo "Ceph Performance Validation Test"
echo "==============================="

sudo ceph osd pool create benchmark 128 128
sudo ceph osd pool application enable benchmark rbd

echo "1. Sequential Write Test (10 seconds):"
sudo rados bench -p benchmark 10 write --no-cleanup | grep -E "bandwidth|Average Latency"
echo ""

echo "2. Sequential Read Test (10 seconds):"
sudo rados bench -p benchmark 10 seq | grep -E "bandwidth|Average Latency"
echo ""

echo "3. Random Read Test (10 seconds):"
sudo rados bench -p benchmark 10 rand | grep -E "bandwidth|Average Latency"
echo ""

echo "Cleaning up test objects..."
sudo rados -p benchmark cleanup

sudo ceph osd pool delete benchmark benchmark --yes-i-really-really-mean-it

echo "Performance test completed."
