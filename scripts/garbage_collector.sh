#!/bin/bash

set -e
set -o pipefail

LOG_FILE="/home/luisc/backups_homelab/maintenance.log"

log() {
    local TYPE=$1
    shift
    local MSG=$@
    local TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] [$TYPE] $MSG" | tee -a "$LOG_FILE"
}

error_handler() {
    log "ERROR" "Garbage collection failed unexpectedly on line $1."
    exit 1
}
trap 'error_handler $LINENO' ERR

log "INFO" "=== Starting Docker Garbage Collection ==="

if ! command -v docker &> /dev/null; then
    log "ERROR" "Docker daemon is not responding."
    exit 1
fi

log "INFO" "Pruning unused Docker images, networks, and stopped containers..."
docker system prune -a -f

log "INFO" "Pruning dangling Docker volumes..."
docker volume prune -f

log "INFO" "=== Garbage collection finished successfully! ==="