#!/bin/bash

BASELINE=~/baseline-metrics.txt
CURRENT=~/after-metrics.txt

if [ ! -f "$BASELINE" ]; then
    echo "ERROR: Baseline file $BASELINE not found."
    echo "Run Task 0 (./hotspot-monitor.sh | tee ~/baseline-metrics.txt) before comparing."
    exit 1
fi

if [ ! -f "$CURRENT" ]; then
    echo "Generating current metrics snapshot..."
    ./hotspot-monitor.sh | tee "$CURRENT"
fi

echo "Performance Optimization Results"
echo "==============================="
echo ""
echo "Baseline metrics (captured before optimization):"
echo "-------------------------------------------------"
grep -E "Coefficient of variation|Average PGs per OSD|WARNING|No slow operations" "$BASELINE"
echo ""
echo "Current metrics (after optimization):"
echo "--------------------------------------"
grep -E "Coefficient of variation|Average PGs per OSD|WARNING|No slow operations" "$CURRENT"
echo ""
echo "Full diff:"
echo "----------"
diff "$BASELINE" "$CURRENT" || echo "(no textual differences detected)"
