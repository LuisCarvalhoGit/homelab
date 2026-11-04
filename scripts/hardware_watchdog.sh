#!/bin/bash

set -e
set -o pipefail


LOG_FILE="/home/luisc/backups_homelab/hardware_health.log"

log() {
    local TYPE=$1
    shift
    local MSG=$@
    local TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] [$TYPE] $MSG" >> "$LOG_FILE"
}

error_handler() {
    log "ERROR" "Watchdog script failed unexpectedly on line $1."
    exit 1
}
trap 'error_handler $LINENO' ERR

# vcgencmd is the native tool to interact with the Raspberry Pi VideoCore GPU/Hardware
if ! command -v vcgencmd &> /dev/null; then
    log "ERROR" "vcgencmd not found. This script must run on a Raspberry Pi OS."
    exit 1
fi

# Get raw temperature (Format: temp=45.0'C)
TEMP_RAW=$(vcgencmd measure_temp)

# Extract only the float number using grep and regex
TEMP_VAL=$(echo "$TEMP_RAW" | grep -o -E '[0-9.]+')

# Convert float to integer for bash comparison (drops the decimal part)
TEMP_INT=${TEMP_VAL%.*}

# Get throttle state (Format: throttled=0x0 means all good)
THROTTLE_RAW=$(vcgencmd get_throttled)

# Check Temperature (Warning at 75C, Critical at 80C)
if [ "$TEMP_INT" -ge 80 ]; then
    log "CRITICAL" "CPU is dangerously hot! Temp: ${TEMP_VAL}°C."
elif [ "$TEMP_INT" -ge 75 ]; then
    log "WARNING" "CPU temperature is high. Temp: ${TEMP_VAL}°C."
fi

# Check Throttling and Under-voltage
# If the output is anything other than 0x0, the Pi is struggling physically
if [ "$THROTTLE_RAW" != "throttled=0x0" ]; then
    log "WARNING" "Hardware degradation detected! Status: $THROTTLE_RAW. Check power supply (under-voltage) or cooling."
fi