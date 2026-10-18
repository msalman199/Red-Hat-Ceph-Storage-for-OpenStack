#!/bin/bash

echo "Ceph Hotspot Monitoring Dashboard"
echo "================================="
echo "Timestamp: $(date)"
echo ""

# Cluster health overview
echo "1. Cluster Health:"
echo "-----------------"
sudo ceph health
echo ""

# OSD utilization variance
echo "2. OSD Utilization Variance:"
echo "---------------------------"
sudo ceph osd df | awk 'NR>1 && $8 ~ /^[0-9.]+$/ {
    util[count] = $8
    total += $8
    count++
}
END {
    if (count == 0) { print "No OSD utilization data available"; exit }
    avg = total/count
    variance = 0
    for (i=0; i<count; i++) {
        variance += (util[i] - avg)^2
    }
    variance = variance/count
    stddev = sqrt(variance)
    cv = (avg > 0) ? stddev/avg * 100 : 0

    print "Average utilization: " avg
    print "Standard deviation: " stddev
    print "Coefficient of variation: " cv "%"
    if (cv < 10) print "Status: GOOD - Low variance"
    else if (cv < 20) print "Status: MODERATE - Some imbalance"
    else print "Status: HIGH - Significant hotspots"
}'
echo ""

# Top and bottom OSDs by utilization
echo "3. OSD Utilization Extremes:"
echo "---------------------------"
echo "Highest utilized OSDs:"
sudo ceph osd df | awk 'NR>1 {print $1, $8}' | sort -k2 -nr | head -3 | awk '{print "  OSD." $1 ": " $2 "x average"}'
echo "Lowest utilized OSDs:"
sudo ceph osd df | awk 'NR>1 {print $1, $8}' | sort -k2 -n | head -3 | awk '{print "  OSD." $1 ": " $2 "x average"}'
echo ""

# PG distribution analysis
echo "4. PG Distribution Analysis:"
echo "---------------------------"
sudo ceph pg dump osds 2>/dev/null | awk 'NR>1 && $2 ~ /^[0-9]+$/ {print $2}' | sort -n | awk '
{
    pgs[NR] = $1
    total += $1
    count++
}
END {
    if (count == 0) { print "No PG data available"; exit }
    avg = total/count
    min = pgs[1]
    max = pgs[count]
    range = max - min

    print "Average PGs per OSD: " avg
    print "Min PGs: " min ", Max PGs: " max
    print "Range: " range " (" int(range/avg*100) "% of average)"

    if (range/avg < 0.1) print "PG Distribution: EXCELLENT"
    else if (range/avg < 0.2) print "PG Distribution: GOOD"
    else if (range/avg < 0.3) print "PG Distribution: MODERATE"
    else print "PG Distribution: NEEDS IMPROVEMENT"
}'
echo ""

# Recent slow operations
echo "5. Performance Issues:"
echo "---------------------"
slow_ops=$(sudo ceph health detail | grep -c "slow")
if [ "$slow_ops" -gt 0 ]; then
    echo "WARNING: $slow_ops slow operation warnings detected"
    sudo ceph health detail | grep slow | head -5
else
    echo "No slow operations detected"
fi
