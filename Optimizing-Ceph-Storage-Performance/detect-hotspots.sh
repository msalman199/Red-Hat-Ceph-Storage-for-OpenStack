#!/bin/bash

echo "Ceph Storage Hotspot Analysis"
echo "============================"
echo "Timestamp: $(date)"
echo ""

echo "OSD Utilization Analysis:"
echo "------------------------"
sudo ceph osd df | awk 'NR>1 && $8 ~ /^[0-9.]+$/ {
    if ($8 > 1.2) print "HOT: OSD." $1 " - Usage: " $8 "x average"
    else if ($8 < 0.8) print "COLD: OSD." $1 " - Usage: " $8 "x average"
}'
echo ""

echo "PG Distribution Analysis:"
echo "------------------------"
sudo ceph osd df | awk 'NR>1 {print $1, $2}' | sort -k2 -n | awk '
{total+=$2; count++; osds[count]=$1; pgs[count]=$2}
END {
    if (count == 0) { print "No data"; exit }
    avg=total/count
    print "Average PGs per OSD: " avg
    print "Hotspot OSDs (>120% of average):"
    for(i=1; i<=count; i++) {
        if(pgs[i] > avg*1.2) print "  OSD." osds[i] ": " pgs[i] " PGs (" int(pgs[i]/avg*100) "% of average)"
    }
}'
echo ""

echo "Slow Request Analysis:"
echo "---------------------"
sudo ceph health detail | grep -i slow || echo "No slow requests detected"
