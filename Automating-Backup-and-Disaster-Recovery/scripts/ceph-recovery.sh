#!/bin/bash

# Ceph Disaster Recovery Script
RECOVERY_DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="$1"
RECOVERY_LOG="/opt/ceph-recovery/logs/recovery-$RECOVERY_DATE.log"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup-file.tar.gz>"
    exit 1
fi

mkdir -p /opt/ceph-recovery/logs
mkdir -p /opt/ceph-recovery/temp

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$RECOVERY_LOG"
}

log_message "Starting disaster recovery from backup: $BACKUP_FILE"

# Extract backup
log_message "Extracting backup file"
cd /opt/ceph-recovery/temp
tar -xzf "$BACKUP_FILE"

BACKUP_DIR=$(find . -maxdepth 1 -type d -name "20*" | head -1)

if [ -z "$BACKUP_DIR" ]; then
    log_message "ERROR: Could not find backup directory in archive"
    exit 1
fi

log_message "Found backup directory: $BACKUP_DIR"

# Stop Ceph services (if running)
log_message "Stopping Ceph services"
systemctl stop ceph-mon@$(hostname)
systemctl stop ceph-mgr@$(hostname)

# Restore configuration files
log_message "Restoring Ceph configuration"
if [ -d "$BACKUP_DIR/ceph-config" ]; then
    cp -r "$BACKUP_DIR/ceph-config/"* /etc/ceph/
    chown -R ceph:ceph /etc/ceph
fi

# Restore CRUSH map
log_message "Restoring CRUSH map"
if [ -f "$BACKUP_DIR/crushmap.bin" ]; then
    ceph osd setcrushmap -i "$BACKUP_DIR/crushmap.bin"
fi

# Display recovery information
log_message "Recovery information available:"
log_message "- Monitor dump: $BACKUP_DIR/mon-dump.txt"
log_message "- OSD dump: $BACKUP_DIR/osd-dump.txt"
log_message "- Configuration: $BACKUP_DIR/config-dump.txt"
log_message "- Health report: $BACKUP_DIR/health-detail.txt"

log_message "Manual steps required:"
log_message "1. Review cluster maps in backup directory"
log_message "2. Recreate OSDs if necessary"
log_message "3. Restart Ceph services"
log_message "4. Verify cluster health"

log_message "Disaster recovery preparation completed"

