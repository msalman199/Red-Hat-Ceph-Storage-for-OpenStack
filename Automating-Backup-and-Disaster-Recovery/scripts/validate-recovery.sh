#!/bin/bash

# Ceph Recovery Validation Script
VALIDATION_LOG="/opt/ceph-recovery/logs/validation-$(date +%Y-%m-%d_%H-%M-%S).log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$VALIDATION_LOG"
}

log_message "Starting recovery validation"

# Check cluster health
log_message "Checking cluster health"
HEALTH_STATUS=$(ceph health)
log_message "Cluster health: $HEALTH_STATUS"

# Check monitor status
log_message "Checking monitor status"
ceph mon stat | tee -a "$VALIDATION_LOG"

# Check OSD status
log_message "Checking OSD status"
ceph osd stat | tee -a "$VALIDATION_LOG"

# Check pool status
log_message "Checking pool status"
ceph df | tee -a "$VALIDATION_LOG"

# Test data operations
log_message "Testing data operations"
TEST_POOL="recovery-test-$(date +%s)"
ceph osd pool create "$TEST_POOL" 8 8

# Write test data
echo "Recovery test data" | rados -p "$TEST_POOL" put recovery-test-object -

# Read test data
RECOVERED_DATA=$(rados -p "$TEST_POOL" get recovery-test-object -)
if [ "$RECOVERED_DATA" = "Recovery test data" ]; then
    log_message "SUCCESS: Data operations working correctly"
else
    log_message "ERROR: Data operations failed"
fi

# Cleanup test pool
ceph osd pool delete "$TEST_POOL" "$TEST_POOL" --yes-i-really-really-mean-it

log_message "Recovery validation completed"
log_message "Check log file for detailed results: $VALIDATION_LOG"
