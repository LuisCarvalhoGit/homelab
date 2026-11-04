#!/bin/bash

# Makes the script exit immediately if any command fails,
# rather than continuing and potentially causing damage.
set -e
set -o pipefail

BACKUP_DIR="/home/luisc/backups_homelab"
RCLONE_REMOTE="cloudflare:homelab-backups"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
LOG_FILE="${BACKUP_DIR}/backup_routine.log"


# Function to write logs with timestamp and severity level.
# 'tee -a' outputs to the console and appends to the log file simultaneously.
log() {
    local TYPE=$1
    shift
    local MSG=$@
    local TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] [$TYPE] $MSG" | tee -a "$LOG_FILE"
}


# If the script fails (due to set -e), this function is automatically called.
error_handler() {
    log "ERROR" "Script failed unexpectedly on line $1."
    log "INFO" "Aborting execution to prevent data corruption."
    exit 1
}
trap 'error_handler $LINENO' ERR


mkdir -p "$BACKUP_DIR"

log "INFO" "=== Starting volume backup routine ==="

# Check if required binaries are installed before doing any work
if ! command -v docker &> /dev/null; then
    log "ERROR" "The 'docker' command was not found. The daemon might be down."
    exit 1
fi

if ! command -v rclone &> /dev/null; then
    log "ERROR" "The 'rclone' command was not found."
    exit 1
fi

backup_volume() {
    local VOL_NAME=$1
    local FILE_NAME="${VOL_NAME}_${DATE}.tar.gz"
    
    # Prevent "empty archive" errors: check if the volume actually exists in Docker
    if ! docker volume inspect "$VOL_NAME" &> /dev/null; then
        log "WARNING" "Volume '$VOL_NAME' does not exist in Docker. Skipping."
        return 0
    fi

    log "INFO" "Compressing volume: $VOL_NAME..."
    
    # Run tar without verbose to avoid flooding the log file.
    # If this fails, 'set -e' catches it and triggers the error_handler.
    docker run --rm \
      -v ${VOL_NAME}:/volume-data \
      -v ${BACKUP_DIR}:/backup-dir \
      alpine sh -c "cd /volume-data && tar -czf /backup-dir/${FILE_NAME} ."
      
    log "SUCCESS" "Volume '$VOL_NAME' saved as $FILE_NAME."
}


backup_volume "portainer_portainer_data"
backup_volume "monitoring_grafana-data"
backup_volume "monitoring_prometheus-data"

log "INFO" "Syncing backups with Cloudflare R2 ($RCLONE_REMOTE)..."
# Copy without verbose, relying on the trap to catch actual failures
rclone copy "$BACKUP_DIR" "$RCLONE_REMOTE"

log "INFO" "Running maintenance tasks..."

# Local cleanup
find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +7 -exec rm {} \;
log "INFO" "Local backups older than 7 days deleted."

# Cloud cleanup
rclone delete "$RCLONE_REMOTE" --min-age 30d
log "INFO" "Cloud backups older than 30 days deleted."

log "INFO" "=== Backup routine finished successfully! ==="