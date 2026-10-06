#!/bin/bash
set -e
SNAPSHOT_DIR="/.snapshots"
LOG_FILE="/var/log/pars-snapshot.log"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
SNAPSHOT_NAME="pars-pre-update-$TIMESTAMP"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }
if ! command -v btrfs &> /dev/null; then exit 0; fi
ROOT_FS=$(df -T / | tail -1 | awk '{print $2}')
if [ "$ROOT_FS" != "btrfs" ]; then exit 0; fi
mkdir -p "$SNAPSHOT_DIR"
if btrfs subvolume snapshot -r / "$SNAPSHOT_DIR/$SNAPSHOT_NAME" > /dev/null 2>&1; then
    log "Snapshot alindi: $SNAPSHOT_NAME"
else
    log "HATA: Snapshot alinamadi!"
    exit 1
fi
