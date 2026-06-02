#!/usr/bin/env bash
set -u

MAX_RESTARTS=3
RESTART_DELAY=2
CRASH_WINDOW=30
LOCKFILE=/tmp/hyprlock-watchdog.lock

exec 9>"$LOCKFILE"
if ! flock -n 9; then
    exit 0
fi

cleanup() { rm -f "$LOCKFILE"; }
trap cleanup EXIT

pkill -9 -x hyprlock 2>/dev/null
sleep 0.3

crash_count=0
while [ $crash_count -lt $MAX_RESTARTS ]; do
    start_time=$(date +%s)
    hyprlock "$@"
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        exit 0
    fi
    end_time=$(date +%s)
    runtime=$((end_time - start_time))
    if [ $runtime -ge $CRASH_WINDOW ]; then
        crash_count=1
    else
        crash_count=$((crash_count + 1))
    fi
    logger -t hyprlock-watchdog "hyprlock crashed (exit $exit_code), restart $crash_count/$MAX_RESTARTS"
    notify-send -u critical "Lock Screen" "hyprlock crashed (exit $exit_code). Restarting... ($crash_count/$MAX_RESTARTS)"
    pkill -9 -x hyprlock 2>/dev/null
    sleep $RESTART_DELAY
done

logger -t hyprlock-watchdog "hyprlock crashed $MAX_RESTARTS times. Starting 10s countdown."
notify-send -u critical "Lock Screen" "hyprlock keeps crashing. Suspending in 10s."

if command -v yad >/dev/null 2>&1; then
    yad --title="Lock Screen Failure" \
        --text="hyprlock crashed 3 times.\nSuspending in 10 seconds.\n\nCancel to stay unlocked." \
        --button="Cancel":1 --timeout=10 --timeout-indicator=bottom \
        --center --on-top
    choice=$?
    if [ $choice -eq 1 ]; then
        logger -t hyprlock-watchdog "User cancelled suspend."
        exit 0
    fi
    if [ $choice -eq 70 ]; then
        logger -t hyprlock-watchdog "Timeout expired."
    fi
fi

logger -t hyprlock-watchdog "Suspending system."
sleep 2
systemctl suspend
